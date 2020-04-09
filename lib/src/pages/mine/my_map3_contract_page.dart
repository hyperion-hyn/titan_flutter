import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:titan/generated/i18n.dart';
import 'package:titan/src/basic/utils/hex_color.dart';
import 'package:titan/src/basic/widget/load_data_container/bloc/bloc.dart';
import 'package:titan/src/basic/widget/load_data_container/load_data_container.dart';
import 'package:titan/src/components/quotes/quotes_component.dart';
import 'package:titan/src/components/wallet/wallet_component.dart';
import 'package:titan/src/config/application.dart';
import 'package:titan/src/pages/node/api/node_api.dart';
import 'package:titan/src/pages/node/map3page/map3_node_create_contract_page.dart';
import 'package:titan/src/pages/node/model/contract_node_item.dart';
import 'package:titan/src/plugins/wallet/wallet.dart';
import 'package:titan/src/plugins/wallet/wallet_const.dart';
import 'package:titan/src/plugins/wallet/wallet_util.dart';
import 'package:titan/src/routes/routes.dart';
import 'package:titan/src/style/titan_sytle.dart';
import 'package:titan/src/utils/format_util.dart';
import 'package:titan/src/widget/enter_wallet_password.dart';
import 'package:web3dart/json_rpc.dart';
import '../../global.dart';
import 'node_contract_detail_page.dart';

class MyMap3ContractPage extends StatefulWidget {
  final String title;
  MyMap3ContractPage(this.title);

  @override
  State<StatefulWidget> createState() {
    return _MyMap3ContractState();
  }
}

class _MyMap3ContractState extends State<MyMap3ContractPage> {
  List<ContractNodeItem> _dataArray = [];
  LoadDataBloc loadDataBloc = LoadDataBloc();
  var _currentPage = 0;
  Wallet _wallet;
  bool isTransferring = false;

  var api = NodeApi();

  @override
  void initState() {
    super.initState();

  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    _wallet = WalletInheritedModel.of(context).activatedWallet?.wallet;

    loadDataBloc.add(LoadingEvent());
    _loadData();
  }

  @override
  void dispose() {
    loadDataBloc.close();
    super.dispose();
  }

  _loadMoreData() async {

    List<ContractNodeItem> dataList = [];
    if (widget.title.contains("发起")) {
      List<ContractNodeItem> createContractList = await api.getMyCreateNodeContract(page: _currentPage);
      dataList  = createContractList;
    } else {
      List<ContractNodeItem> joinContractList = await api.getMyJoinNodeContract(page: _currentPage);
      dataList = joinContractList;
    }

    if (dataList.length == 0) {
      loadDataBloc.add(LoadMoreEmptyEvent());
    } else {
      _currentPage += 1;
      loadDataBloc.add(LoadingMoreSuccessEvent());

      setState(() {
        _dataArray.addAll(dataList);
      });
    }

    print('[map3] _loadMoreData, list.length:${dataList.length}');

  }

  _loadData() async {

    _currentPage = 0;

    List<ContractNodeItem> dataList = [];
    if (widget.title.contains("发起")) {
      List<ContractNodeItem> createContractList = await api.getMyCreateNodeContract(address: _wallet.getEthAccount().address);
      dataList  = createContractList;
    } else {
      List<ContractNodeItem> joinContractList = await api.getMyJoinNodeContract(address: _wallet.getEthAccount().address);
      dataList = joinContractList;
    }

    if (dataList.length == 0) {
      loadDataBloc.add(LoadEmptyEvent());
    } else {
      _currentPage ++;
      loadDataBloc.add(RefreshSuccessEvent());

      // todo: 测试写死
      dataList.first.state = "Running";

      setState(() {
        _dataArray = dataList;
      });
    }

    print('[map3] widget.title:${widget.title}, _loadData, dataList.length:${dataList.length}');
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: Container(
        padding: const EdgeInsets.fromLTRB(0, 8, 0, 8),
        color: HexColor('#E2E0E3'),
        child: LoadDataContainer(
          bloc: loadDataBloc,
          onLoadData: _loadData,
          onRefresh: _loadData,
          // todo: 服务器暂时没支持page分页
          //onLoadingMore: _loadMoreData,
          child: ListView.separated(
              itemBuilder: (context, index) {
                return _buildInfoItem(_dataArray[index]);
              },
              separatorBuilder: (context, index) {
                return Container(
                  height: 8,
                  color: Colors.white10,
                );
              },
              itemCount: _dataArray.length),
        ),
      ),
    );
  }

  HexColor _getStatusColor(String stateString) {
    var state = enumContractStateFromString(stateString);
    var statusColor = HexColor('#EED097');

    switch (state) {
      case ContractState.PENDING:
        statusColor = HexColor('#EED097');
        break;

      case ContractState.Running:
        statusColor = HexColor('#3FF78C');
        break;

      case ContractState.Expired:
        statusColor = HexColor('#867B7B');
        break;

      case ContractState.Withdrawal:
        statusColor = HexColor('#867B7B');
        break;

      case ContractState.FailRun:
        statusColor = HexColor('#F22504');
        break;

      default:
        break;
    }
    return statusColor;
  }

  Widget _buildInfoItem(ContractNodeItem contractNodeItem) {
    String startAccount = "${contractNodeItem.owner}";
    startAccount = startAccount.substring(0,startAccount.length > 25 ? 25 : startAccount.length);
    startAccount = startAccount + "...";
    String clickTitle = "增加";
    if (contractNodeItem.remainDelegation == "0") {
      clickTitle = isTransferring?S.of(context).please_waiting:"提币";
    }

    return Container(
      color: Colors.white,
      child: Padding(
        padding:
        const EdgeInsets.only(left: 20.0, right: 13, top: 7, bottom: 7),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                Text("${contractNodeItem.ownerName}",
                    style: TextStyles.textCcc000000S14),
                Expanded(
                    child: Text(" $startAccount",
                        style: TextStyles.textC9b9b9bS12)),
                Text("剩余时间：${contractNodeItem.remainDay}天", style: TextStyles.textC9b9b9bS12)
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(top:8,bottom: 16),
              child: Divider(height: 1,color: DefaultColors.color1177869e),
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Image.asset(
                  "res/drawable/ic_map3_node_item_contract.png",
                  width: 42,
                  height: 42,
                  fit:BoxFit.cover,
                ),
                SizedBox(width: 6,),
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: <Widget>[
                          Expanded(
                              child: Text("${contractNodeItem.contract.nodeName}",
                                  style: TextStyles.textCcc000000S14))
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 3.0),
                        child: Row(
                          children: <Widget>[
                            Text("最高 ${FormatUtil.formatTenThousand(contractNodeItem.contract.minTotalDelegation)}",
                                style: TextStyles.textC99000000S10,maxLines:1,softWrap: true),
                            Text("  |  ",style: TextStyles.textC9b9b9bS12),
                            Text("${contractNodeItem.contract.duration}天",style: TextStyles.textC99000000S10)
                          ],
                        ),
                      ),
                      Text("${FormatUtil.formatDate(contractNodeItem.instanceStartTime)}", style: TextStyles.textCfffS12),
                    ],
                  ),
                ),
                Column(
                  children: <Widget>[
                    Text("${FormatUtil.formatPercent(contractNodeItem.contract.annualizedYield)}", style: TextStyles.textCff4c3bS18),
                    Text("年化奖励", style: TextStyles.textC99000000S10)
                  ],
                )
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(top:9,bottom: 9),
              child: Divider(height: 1,color: DefaultColors.color1177869e),
            ),
            Row(
              children: <Widget>[
                Expanded(
                  child: RichText(
                    text: TextSpan(
                        text: "还差",
                        style: TextStyles.textC9b9b9bS12,
                        children: <TextSpan>[
                          TextSpan(
                              text: "${FormatUtil.formatNum(int.parse(contractNodeItem.remainDelegation))}",
                              style: TextStyles.textC7c5b00S12),
                          TextSpan(
                              text: "HYN",
                              style: TextStyles.textC9b9b9bS12),
                        ]),
                  ),
                ),
                SizedBox(
                  height: 24,
                  width: 78,
                  child: FlatButton(
                    color: DefaultColors.colorffdb58,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24)),
                    onPressed: () {

                     if (contractNodeItem.remainDelegation == "0") {
                       _collectAction(contractNodeItem);
                     } else {
                       _navigationAction(contractNodeItem);
                     }
                    },

                    child: Text(clickTitle, style: TextStyles.textC906b00S13),
                  ),
                )
              ],
            )
          ],
        ),
      ),
    );
  }

  Future _navigationAction(ContractNodeItem contractNodeItem) {
    Application.router.navigateTo(context, Routes.map3node_join_contract_page
        + "?contractId=${contractNodeItem.id}");
  }

  Future _collectAction(ContractNodeItem contractNodeItem) async {

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
          isTransferring = true;
        });

        ///创建节点合约的钱包地址
        var createNodeWalletAddress = contractNodeItem.owner;
        var gasPriceRecommend = QuotesInheritedModel.of(context, aspect: QuotesAspect.gasPrice).gasPriceRecommend;
        var gasPrice = BigInt.from(gasPriceRecommend.average.toInt());
        var gasLimit = EthereumConst.ERC20_APPROVE_GAS_LIMIT;
        var signedHex = await _wallet.signCollectMap3Node(
          createNodeWalletAddress: createNodeWalletAddress,
          gasPrice: gasPrice,
          gasLimit: gasLimit,
          password: walletPassword,
        );
        var ret = await WalletUtil.postToEthereumNetwork(method: 'eth_sendRawTransaction', params: [signedHex]);

        logger.i('map3 collect, result: $ret');

        Application.router.navigateTo(context,Routes.map3node_broadcase_success_page + "?pageType=${Map3NodeCreateContractPage.CONTRACT_PAGE_TYPE_COLLECT}");
      } catch (_) {
        logger.e(_);
        setState(() {
          isTransferring = false;
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

enum ContractState { PENDING, Running, Expired, Withdrawal, FailRun }

ContractState enumContractStateFromString(String fruit) {
  fruit = 'ContractState.$fruit';
  return ContractState.values.firstWhere((f)=> f.toString() == fruit, orElse: () => null);
}
