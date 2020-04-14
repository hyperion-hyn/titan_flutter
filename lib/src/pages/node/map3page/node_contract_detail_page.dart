import 'package:esys_flutter_share/esys_flutter_share.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:titan/generated/i18n.dart';
import 'package:titan/src/basic/utils/hex_color.dart';
import 'package:titan/src/basic/widget/load_data_container/bloc/bloc.dart';
import 'package:titan/src/basic/widget/load_data_container/bloc/load_data_bloc.dart';
import 'package:titan/src/basic/widget/load_data_container/load_data_container.dart';
import 'package:titan/src/components/quotes/quotes_component.dart';
import 'package:titan/src/components/wallet/wallet_component.dart';
import 'package:titan/src/config/application.dart';
import 'package:titan/src/global.dart';
import 'package:titan/src/pages/node/map3page/my_map3_contract_page.dart';
import 'package:titan/src/pages/node/api/node_api.dart';
import 'package:titan/src/pages/node/map3page/map3_node_create_contract_page.dart';
import 'package:titan/src/pages/node/model/contract_delegator_item.dart';
import 'package:titan/src/pages/node/model/contract_detail_item.dart';
import 'package:titan/src/pages/node/model/contract_node_item.dart';
import 'package:titan/src/plugins/wallet/wallet.dart';
import 'package:titan/src/plugins/wallet/wallet_const.dart';
import 'package:titan/src/routes/fluro_convert_utils.dart';
import 'package:titan/src/routes/routes.dart';
import 'package:titan/src/style/titan_sytle.dart';
import 'package:titan/src/utils/format_util.dart';
import 'package:titan/src/utils/utils.dart';
import 'package:titan/src/widget/enter_wallet_password.dart';
import 'package:web3dart/json_rpc.dart';

class NodeContractDetailPage extends StatefulWidget {

  final ContractNodeItem contractNodeItem;
  NodeContractDetailPage(this.contractNodeItem);

  @override
  State<StatefulWidget> createState() {
    return _NodeContractDetailState();
  }
}

class _NodeContractDetailState extends State<NodeContractDetailPage> {

  LoadDataBloc loadDataBloc = LoadDataBloc();
  var api = NodeApi();
  ContractDetailItem _contractDetailItem;
  List<ContractDelegatorItem> _delegatorList = [];
  int _currentPage = 0;
  Wallet _wallet;

  @override
  void initState() {
    super.initState();


  }


  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    _wallet = WalletInheritedModel.of(context).activatedWallet?.wallet;

    loadDataBloc.add(LoadingEvent());

    _loadLastData();
  }

  _loadMoreData() async {
    var list = await api.getContractDelegator(widget.contractNodeItem.id, page: _currentPage);
    if (list.length == 0) {
      loadDataBloc.add(LoadMoreEmptyEvent());
    } else {
      _currentPage += 1;
      loadDataBloc.add(LoadingMoreSuccessEvent());

      if (this.mounted) {
        setState(() {
          _delegatorList.addAll(list);
        });
      }
    }

    print('[map3] _loadMoreData, list.length:${list.length}');

  }

  void _loadLastData() async {
    try{
      _currentPage = 0;
      List<ContractDelegatorItem> list = [];
      var address = _wallet.getEthAccount().address;
      list = await api.getContractDelegator(widget.contractNodeItem.id, page: _currentPage, address: address);
      var item = await api.getContractDetail("${widget.contractNodeItem.id}", address: address);

      if (list.length == 0 || item == null) {
        loadDataBloc.add(LoadEmptyEvent());
      } else {
        if (list.isNotEmpty) {
          _currentPage += 1;
        }
        loadDataBloc.add(RefreshSuccessEvent());
        list.insert(0, ContractDelegatorItem("0x","0","0",0));

        if (this.mounted) {
          setState(() {
            print('[map3] _loadLastData, list.length:${list.length}, id:${item.instance.id}');

            _delegatorList = list;
            _contractDetailItem = item;
          });
        }
      }
    }catch(e){
      print(e);
      loadDataBloc.add(LoadFailEvent());
    }
  }


  @override
  void dispose() {
    loadDataBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(centerTitle: true, title: Text("节点抵押合约详情")),
      body: Container(
        color: HexColor("#f5f5f5"),
        child: LoadDataContainer(
          bloc: loadDataBloc,
          onLoadData: _loadLastData,
          onRefresh: _loadLastData,
          onLoadingMore: _loadMoreData,
          child: CustomScrollView(
            slivers: <Widget>[
              _contractIntroductionRow(context, 3),
              _Divider(),
              _contractStatusRow(context, 3),
              _Divider(),
              _contractJoinerListRow(context, 10),
            ],
          ),
        ),
      ),
    );
  }

  Widget _Divider({height = 10.0, bool isSimple = false}) {
    return isSimple
        ? Container(
            height: height,
          )
        : SliverToBoxAdapter(
            child: Container(
            height: height,
          ));
  }

  Widget _contractIntroductionRow(BuildContext context, int index) {
    bool hasRemind = (index == 3) ? true : false;
    return SliverToBoxAdapter(
      child: Container(
        padding: EdgeInsets.only(left: 10.0, right: 10, top: 5, bottom: 10),
        color: Colors.white,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(right: 10.0),
                  child: Image.asset(
                    "res/drawable/ic_map3_node_item.png",
                    width: 70,
                    height: 70,
                  ),
                ),
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Container(
                        height: 4,
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Expanded(child: Text(widget.contractNodeItem.contract.nodeName, style: TextStyles.textC333S14)),
                        ],
                      ),
                      Container(
                        height: 2,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Text("启动共需${FormatUtil.stringFormatNum(widget.contractNodeItem.contract.minTotalDelegation)}HYN", style: TextStyles.textC333S14),
                      )
                    ],
                  ),
                )
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Row(
                children: [1, 2, 3].map((value) {
                  String title = "";
                  String detail = "";
                  switch (value) {
                    case 1:
                      title = "期满年化奖励";
                      detail = "${FormatUtil.formatPercent(widget.contractNodeItem.contract.annualizedYield)}";
                      break;

                    case 2:
                      title = "合约期限";
                      detail = "${widget.contractNodeItem.contract.duration}月";
                      break;

                    case 3:
                      title = "管理费";
                      detail = "${FormatUtil.formatPercent(widget.contractNodeItem.contract.commission)}";
                      break;
                  }
                  return Expanded(
                    child: Center(
                        child: Column(
                      children: <Widget>[
                        Text(title, style: TextStyles.textC9b9b9bS12),
                        Container(
                          height: 4,
                        ),
                        Text(detail, style: TextStyles.textC333S14)
                      ],
                    )),
                  );
                }).toList(),
              ),
            ),
            if (hasRemind)
              Padding(
                padding: const EdgeInsets.only(top: 16.0, bottom: 4.0),
                child: Text("注：合约生效满3个月后，即可提取50%奖励", style: TextStyles.textCf29a6eS12),
              )
          ],
        ),
      ),
    );
  }

  Widget _contractStatusRow(BuildContext context, int index) {
    return SliverToBoxAdapter(
      child: Column(
        children: <Widget>[
          _nodeProgressWidget(),
          _contractActionsWidget(),
          _Divider(height: 4.0, isSimple: true),
          _contractProgressWidget(),
        ],
      ),
    );
  }

  Widget _contractActionsWidget() {
    return Container(
      color: Colors.white,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Container(
                  color: HexColor('#FDFBEA'),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  child: Text("正在创建中，等待区块链网络验证", style: TextStyles.textC9b9b9bS12),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(top: 12.0, bottom: 12.0),
            child: Row(
              children: [1, 2, 3].map((value) {
                String title = "";
                String detail = "";
                TextStyle style = TextStyle(fontSize: 12, color: Colors.grey);
                switch (value) {
                  case 1:
                    title = "你已投入(HYN)";
                    detail = "20,000";
                    style = TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.bold);
                    break;

                  case 2:
                    title = "预期产出(HYN)";
                    detail = "21,000";
                    style = TextStyle(fontSize: 14, color: Colors.red, fontWeight: FontWeight.bold);
                    break;

                  case 3:
                    title = "获得管理费(HYN)";
                    detail = "100";
                    style = TextStyle(fontSize: 12, color: Colors.red, fontWeight: FontWeight.bold);
                    break;
                }
                return Expanded(
                  child: Center(
                      child: Column(
                        children: <Widget>[
                          Text(detail, style: style),
                          Container(
                            height: 8,
                          ),
                          Text(title, style: TextStyles.textC9b9b9bS12),
                        ],
                      )),
                );
              }).toList(),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 4.0, bottom: 4.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [1, 2, 3, 4].map((value) {
                String title = "";
                String detail = "";
                TextStyle style = TextStyle(fontSize: 12, color: Colors.grey);
                Function onPressed = (){};
                switch (value) {
                  case 1:
                    title = "取回资金";
                    detail = "20,000";
                    style = TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.bold);
                    break;

                  case 2:
                    title = "增加投入";
                    detail = "21,000";
                    style = TextStyle(fontSize: 14, color: Colors.red, fontWeight: FontWeight.bold);
                    onPressed = () {
                      Application.router.navigateTo(context, Routes.map3node_join_contract_page + "?pageType=${Map3NodeCreateContractPage.CONTRACT_PAGE_TYPE_JOIN}" + "&contractId=${widget.contractNodeItem.id}");
                    };
                    break;

                  case 3:
                    title = "我要投入";
                    detail = "100";
                    style = TextStyle(fontSize: 12, color: Colors.red, fontWeight: FontWeight.bold);
                    onPressed = () {
                      Application.router.navigateTo(context, Routes.map3node_join_contract_page + "?pageType=${Map3NodeCreateContractPage.CONTRACT_PAGE_TYPE_JOIN}" + "&contractId=${widget.contractNodeItem.id}");
                    };
                    break;

                  case 4:
                    title = "分享好友";
                    detail = "100";
                    style = TextStyle(fontSize: 12, color: Colors.red, fontWeight: FontWeight.bold);
                    onPressed = () {
                      Share.text(S.of(context).share, "http://baidu.com", 'text/plain');
                    };
                    break;
                }
                return MaterialButton(
                  height: 30,
                  minWidth: 20,
                  color: Colors.white,
                  onPressed: onPressed,
                  child: Text(title, style: TextStyle(fontSize: 12, color: Colors.black)),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _contractJoinerListRow(BuildContext context, int index) {
    if (_contractDetailItem == null || _contractDetailItem.instance == null) return _Divider();
    return SliverToBoxAdapter(
        child: Column(
      children: <Widget>[
        Container(
          padding: const EdgeInsets.all(12.0),
          color: Colors.white,
          child: Column(
            children: [1, 2].map((int value) {
              String title = "";
              String detail = "";
              double bottom = 0.0;
              switch (value) {
                case 1:
                  title = "创建时间:";
                  detail = "${FormatUtil.formatDate(_contractDetailItem?.instance?.instanceStartTime)}";
                  bottom = 4.0;
                  break;

                case 2:
                  title = "参与账户:";
                  detail = "${FormatUtil.formatNum(int.parse(_contractDetailItem?.instance?.amountDelegation))}";
                  break;
              }
              return Padding(
                padding: EdgeInsets.only(bottom: bottom),
                child: Row(
                  children: <Widget>[
                    Text(title, style: TextStyle(fontSize: 14, color: Colors.grey, fontWeight: FontWeight.normal)),
                    Spacer(),
                    Text(detail, style: TextStyle(fontSize: 12, color: Colors.black, fontWeight: FontWeight.normal)),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
        _Divider(height: 4.0, isSimple: true),
        if (_delegatorList.isNotEmpty) Container(
          color: Colors.white,
          child: Column(
            children: _delegatorList.map((value) {
              return value == _delegatorList.first
                  ? Container(
                padding: const EdgeInsets.all(12.0),
                color: Colors.white,
                child: Row(
                  //
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,

                  children: [
                    Expanded(
                      child: Text("参与账户", style: TextStyles.textC9b9b9bS12),
                    ),
                    Expanded(child: Text("投入(HYN)", style: TextStyles.textC9b9b9bS12)),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: <Widget>[
                        Text("时间", style: TextStyles.textC9b9b9bS12),
                      ],
                    ),
                  ],
                ),
              )
                  : Container(
                padding: const EdgeInsets.all(12.0),
                color: Colors.white,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(value == _delegatorList[1] ? "${value.userName}（发起人）" : value.userName,
                            style: TextStyle(fontSize: 12, color: Colors.black, fontWeight: FontWeight.w500)),
                        Container(
                          height: 4.0,
                        ),
                        Container(
                            width: 100,
                            child: Text(shortBlockChainAddress(value.userAddress, limitCharsLength: 6), style: TextStyle(fontSize: 12, color: Colors.grey))),
                      ],
                    ),
                    Text("${FormatUtil.formatNum(int.parse(value.amountDelegation))}",
                        style: TextStyle(fontSize: 12, color: Colors.black, fontWeight: FontWeight.w500)),
                    Text("${FormatUtil.formatDate(value.createAt)}", style: TextStyle(fontSize: 12, color: Colors.grey)),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    ));
  }

  Widget _nodeProgressWidget() {

    double horizontal = 25;
    double sectionWidth = (MediaQuery.of(context).size.width - horizontal * 2.0) * 0.2;
    return Container(
      color: Colors.white,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Container(
                    width: 10,
                    height: 10,
                    //color: Colors.red,
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _getStatusColor(ContractState.ACTIVE),
                        border: Border.all(color: Colors.grey, width: 1.0)),
                  ),
                ),
                Text.rich(TextSpan(children: [
                  TextSpan(text: "节点正在运行", style: TextStyle(fontSize: 12, color: Colors.grey)),
                  TextSpan(
                    text: " ",
                    style: TextStyle(fontSize: 14, color: Colors.black, fontWeight: FontWeight.w500),
                  ),
                ])),
                Spacer(),
                InkWell(
                  onTap: (){
                    String webUrl = FluroConvertUtils.fluroCnParamsEncode("https://www.map3.network");
                    String webTitle = FluroConvertUtils.fluroCnParamsEncode("Map3节点详情");
                    Application.router.navigateTo(context, Routes.toolspage_webview_page
                        + '?initUrl=$webUrl&title=$webTitle');
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(right: 10.0),
                    child: Text("点击查看详情", style: TextStyle(fontSize: 12, color: Theme.of(context).primaryColor)),
                  ),
                )
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.only(left: 10.0, right: 10.0),
            child: Image.asset(
              "res/drawable/ic_map3_node_item.png",
//              width: 70,
              height: 80,
              width: double.infinity,
              fit: BoxFit.fill,
            ),
          ),

          Padding(
            padding: const EdgeInsets.only(left: 10.0, right: 10.0, bottom: 8.0, top: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                Text("阿里云", style: TextStyle(fontSize: 12, color: Colors.grey)),
                Padding(
                  padding: const EdgeInsets.only(left: 10.0),
                  child: Text("中国深圳", style: TextStyle(fontSize: 12, color: Colors.grey)),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _contractProgressWidget() {

    double horizontal = 25;
    double sectionWidth = (MediaQuery.of(context).size.width - horizontal * 2.0) * 0.2;
    return Container(
      color: Colors.white,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Container(
                    width: 10,
                    height: 10,
                    //color: Colors.red,
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _getStatusColor(ContractState.PENDING),
                        border: Border.all(color: Colors.grey, width: 1.0)),
                  ),
                ),
                Text.rich(TextSpan(children: [
                  TextSpan(text: "等待启动，剩余", style: TextStyle(fontSize: 12, color: Colors.grey)),
                  TextSpan(
                    text: "2天",
                    style: TextStyle(fontSize: 14, color: Colors.black, fontWeight: FontWeight.w500),
                  ),
                ])),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 48),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Text("7天", style: TextStyle(fontSize: 14, color: Colors.grey, fontWeight: FontWeight.normal)),
                Container(width: sectionWidth,),
                Text("90天", style: TextStyle(fontSize: 14, color: Colors.grey, fontWeight: FontWeight.normal)),
                Container(width: sectionWidth*0.5,),
                Text("90天", style: TextStyle(fontSize: 14, color: Colors.grey, fontWeight: FontWeight.normal)),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal:horizontal),
            child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    border: Border.all(color: Colors.blue, width: 1.0)),
              ),
              Container(
                height: 2.5,
                width: sectionWidth,
                color: Colors.green,
              ),
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    border: Border.all(color: Colors.grey, width: 1.0)),
              ),
                  Container(
                    height: 2.5,
                    width: sectionWidth,
                    color: Colors.green,
                  ),
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                        border: Border.all(color: Colors.grey, width: 1.0)),
                  ),
                  Container(
                    height: 2.5,
                    width: sectionWidth,
                    color: Colors.green,
                  ),
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                        border: Border.all(color: Colors.grey, width: 1.0)),
                  ),
                  Container(
                    height: 2.5,
                    width: sectionWidth,
                    color: Colors.green,
                  ),
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                        border: Border.all(color: Colors.grey, width: 1.0)),
                  ),

            ]),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text("待启动", style: TextStyle(fontSize: 14, color: Colors.grey, fontWeight: FontWeight.normal)),
                Text("启动", style: TextStyle(fontSize: 14, color: Colors.grey, fontWeight: FontWeight.normal)),
                Padding(
                  padding: const EdgeInsets.only(top: 0),
                  child: Text("中期可取50%奖励",
                      style: TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.normal)),
                ),
                Text("到期", style: TextStyle(fontSize: 14, color: Colors.grey, fontWeight: FontWeight.normal)),
                Text("已提取", style: TextStyle(fontSize: 14, color: Colors.grey, fontWeight: FontWeight.normal)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  HexColor _getStatusColor(ContractState status) {
    var statusColor = HexColor('#EED097');

    switch (status) {
      case ContractState.PENDING:
        statusColor = HexColor('#EED097');
        break;

      case ContractState.ACTIVE:
        statusColor = HexColor('#3FF78C');
        break;

      case ContractState.DUE:
        statusColor = HexColor('#867B7B');
        break;

      case ContractState.CANCELLED:
        statusColor = HexColor('#F22504');
        break;

      default:
        break;
    }
    return statusColor;
  }

  bool isTransferring = false;

  Future _collectAction(ContractNodeItem contractNodeItem) async {

    var btnTitle = isTransferring?S.of(context).please_waiting:"查看合约";

    if (_wallet == null) {
      return;
    }

    showModalBottomSheet(
        isScrollControlled: true,
        context: context,
        builder: (BuildContext context) {
          return EnterWalletPasswordWidget();
        }).then((walletPassword) async {

      if (walletPassword == null) {
        return;
      }

      try {
        setState(() {
          if (mounted) {
            isTransferring = true;
          }
        });

        ///创建节点合约的钱包地址
        var createNodeWalletAddress = contractNodeItem.owner;
        var gasPriceRecommend = QuotesInheritedModel.of(context, aspect: QuotesAspect.gasPrice).gasPriceRecommend;
        var gasPrice = BigInt.from(gasPriceRecommend.average.toInt());
        //TODO 如果创建者，使用COLLECT_MAP3_NODE_CREATOR_GAS_LIMIT，如果中期取币 COLLECT_HALF_MAP3_NODE_GAS_LIMIT, 如果参与者 COLLECT_MAP3_NODE_PARTNER_GAS_LIMIT
        var gasLimit = EthereumConst.COLLECT_MAP3_NODE_CREATOR_GAS_LIMIT;

        /*var signedHex = await _wallet.signCollectMap3Node(
          createNodeWalletAddress: createNodeWalletAddress,
          gasPrice: gasPrice,
          gasLimit: gasLimit,
          password: walletPassword,
        );
        var ret = await WalletUtil.postToEthereumNetwork(method: 'eth_sendRawTransaction', params: [signedHex]);

        logger.i('map3 collect, result: $ret');

       */

        var collectHex = await _wallet.sendCollectMap3Node(
          createNodeWalletAddress: createNodeWalletAddress,
          gasPrice: gasPrice,
          gasLimit: gasLimit,
          password: walletPassword,
        );
        logger.i('map3 collect, collectHex: $collectHex');

        Application.router.navigateTo(context,Routes.map3node_broadcase_success_page + "?pageType=${Map3NodeCreateContractPage.CONTRACT_PAGE_TYPE_COLLECT}");
      } catch (_) {
        logger.e(_);
        setState(() {
          if (mounted) {
            isTransferring = false;
          }
        });
        if (_ is PlatformException) {
          if (_.code == WalletError.PASSWORD_WRONG) {
            Fluttertoast.showToast(msg: S.of(context).password_incorrect);
          } else {
            Fluttertoast.showToast(msg: S.of(context).transfer_fail);
          }
        } else if (_ is RPCError) {
          if (_.errorCode == -32000) {
            Fluttertoast.showToast(msg: S.of(context).eth_balance_not_enough_for_gas_fee);
          } else {
            Fluttertoast.showToast(msg: S.of(context).transfer_fail);
          }
        } else {
          Fluttertoast.showToast(msg: S.of(context).transfer_fail);
        }
      }
    });
  }

}
