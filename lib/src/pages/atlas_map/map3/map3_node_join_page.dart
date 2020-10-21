import 'package:decimal/decimal.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:rxdart/rxdart.dart';
import 'package:titan/generated/l10n.dart';
import 'package:titan/src/basic/utils/hex_color.dart';
import 'package:titan/src/basic/widget/base_app_bar.dart';
import 'package:titan/src/basic/widget/base_state.dart';
import 'package:titan/src/basic/widget/load_data_container/bloc/load_data_bloc.dart';
import 'package:titan/src/basic/widget/load_data_container/bloc/load_data_event.dart';
import 'package:titan/src/basic/widget/load_data_container/load_data_container.dart';
import 'package:titan/src/components/wallet/wallet_component.dart';
import 'package:titan/src/config/consts.dart';
import 'package:titan/src/pages/atlas_map/api/atlas_api.dart';
import 'package:titan/src/pages/atlas_map/entity/atlas_message.dart';
import 'package:titan/src/pages/atlas_map/entity/enum_atlas_type.dart';
import 'package:titan/src/pages/atlas_map/entity/map3_info_entity.dart';
import 'package:titan/src/pages/atlas_map/entity/pledge_map3_entity.dart';
import 'package:titan/src/pages/node/model/contract_node_item.dart';
import 'package:titan/src/pages/node/model/map3_node_util.dart';
import 'package:titan/src/pages/node/model/node_item.dart';
import 'package:titan/src/plugins/wallet/wallet_util.dart';
import 'package:titan/src/style/titan_sytle.dart';
import 'package:titan/src/utils/format_util.dart';
import 'package:titan/src/utils/log_util.dart';
import 'package:titan/src/utils/utils.dart';
import 'package:titan/src/widget/loading_button/click_oval_button.dart';
import 'package:web3dart/crypto.dart';
import 'package:web3dart/web3dart.dart';
import '../../../global.dart';
import 'map3_node_confirm_page.dart';
import 'map3_node_public_widget.dart';

import 'package:titan/src/widget/all_page_state/all_page_state.dart';
import 'package:titan/src/widget/all_page_state/all_page_state_container.dart';
import 'package:titan/src/widget/all_page_state/all_page_state.dart'
    as all_page_state;
import 'package:web3dart/src/models/map3_node_information_entity.dart';

class Map3NodeJoinPage extends StatefulWidget {
  final Map3InfoEntity map3infoEntity;

  Map3NodeJoinPage(this.map3infoEntity);

  @override
  _Map3NodeJoinState createState() => new _Map3NodeJoinState();
}

class _Map3NodeJoinState extends BaseState<Map3NodeJoinPage> {
  TextEditingController _joinCoinController = new TextEditingController();
  final _joinCoinFormKey = GlobalKey<FormState>();

  LoadDataBloc _loadDataBloc = LoadDataBloc();
  AllPageState _currentState = LoadingState();
  AtlasApi _atlasApi = AtlasApi();
  var _address = "";
  var _nodeId = "";

  //ContractNodeItem contractItem;
  PublishSubject<String> _filterSubject = PublishSubject<String>();
  String endProfit = "";
  String spendManager = "";

  List<String> _suggestList = [];
  String originInputStr = "";

  final client = WalletUtil.getWeb3Client(true);
  Map3NodeInformationEntity _map3nodeInformationEntity;

  @override
  void initState() {
    //todo
    widget.map3infoEntity.address = "0xe106d68990CB7153ff46F6428337C4d372729060";

    _joinCoinController.addListener(textChangeListener);

    _filterSubject.debounceTime(Duration(milliseconds: 500)).listen((text) {
      getCurrentSpend(text);
    });

    // getNetworkData();
    super.initState();
  }

  @override
  void dispose() {
    print("[Join] dispose");

    _filterSubject.close();
    _loadDataBloc.close();
    super.dispose();
  }

  @override
  void onCreated() {
    var _wallet = WalletInheritedModel.of(Keys.rootKey.currentContext)
        .activatedWallet
        ?.wallet;
    _address = _wallet.getAtlasAccount().address;
    // todo: test_1007
    _nodeId = widget.map3infoEntity.nodeId;

    getNetworkData();

    super.onCreated();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffF3F0F5),
      appBar: BaseAppBar(
        baseTitle: '抵押Map3节点',
      ),
      body: _pageView(context),
    );
  }

  Future getNetworkData() async {
    try {
      var map3Address = EthereumAddress.fromHex(widget.map3infoEntity.address);
      var requestList = await Future.wait([
//        _atlasApi.getMap3Info(_address, _nodeId),
        _atlasApi.getMapRecStaking(),
        client.getMap3NodeInformation(map3Address)
      ]);

      _suggestList = requestList[0];
      _map3nodeInformationEntity = requestList[1];
      if (mounted) {
        setState(() {
          _currentState = null;
          _loadDataBloc.add(RefreshSuccessEvent());
        });
      }
    } catch (e) {
      logger.e(e);
      LogUtil.toastException(e);

      if (mounted) {
        setState(() {
          _currentState = all_page_state.LoadFailState();
        });
      }
    }
  }

  void textChangeListener() {
    _filterSubject.sink.add(_joinCoinController.text);
  }

  void getCurrentSpend(String inputText) {
    if (widget.map3infoEntity == null || !mounted || originInputStr == inputText) {
      return;
    }

    originInputStr = inputText;
    _joinCoinFormKey.currentState?.validate();

    if (inputText == null || inputText == "") {
      setState(() {
        endProfit = "";
        spendManager = "";
      });
      return;
    }
    double inputValue = double.parse(inputText);
    //endProfit = Map3NodeUtil.getEndProfit(contractItem.contract, inputValue);
    //spendManager = Map3NodeUtil.getManagerTip(contractItem.contract, inputValue);

    if (mounted) {
      setState(() {
        _joinCoinController.value = TextEditingValue(
            // 设置内容
            text: inputText,
            // 保持光标在最后
            selection: TextSelection.fromPosition(TextPosition(
                affinity: TextAffinity.downstream, offset: inputText.length)));
      });
    }
  }

  Widget _pageView(BuildContext context) {
    if (_currentState != null || widget.map3infoEntity == null) {
      return Scaffold(
        body: AllPageStateContainer(_currentState, () {
          setState(() {
            _currentState = LoadingState();
          });
          getNetworkData();
        }),
      );
    }

    return Column(
      children: <Widget>[
        Expanded(
          child: LoadDataContainer(
            bloc: _loadDataBloc,
            enablePullUp: false,
            onRefresh: getNetworkData,
            child: BaseGestureDetector(
              context: context,
              child: SingleChildScrollView(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                    _nodeWidget(context),
                    SizedBox(height: 8),
                    getHoldInNum(
                      context,
                      widget.map3infoEntity,
                      _joinCoinFormKey,
                      _joinCoinController,
                      endProfit,
                      spendManager,
                      false,
                      suggestList: _suggestList,
                    ),
                    SizedBox(height: 8),
                    _tipsWidget(),
                  ])),
            ),
          ),
        ),
        _confirmButtonWidget(),
      ],
    );
  }

  Widget _tipsWidget() {
    return Container(
      color: Colors.white,
      //height: MediaQuery.of(context).size.height-50,
      padding: const EdgeInsets.only(left: 20.0, right: 20, bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(top: 16.0, bottom: 8),
            child: Text("注意事项",
                style: TextStyle(color: HexColor("#333333"), fontSize: 16)),
          ),
          rowTipsItem("抵押7天内不可撤销", top: 0),
          rowTipsItem("需要总抵押满100万HYN才能正式启动，每次参与抵押数额不少于10000HYN"),
          rowTipsItem(
              "节点主在到期前倒数第二周设置下一周期是否继续运行，或调整管理费率。抵押者在到期前最后一周可选择是否跟随下一周期"),
          rowTipsItem("如果节点主扩容节点，你的抵押也会分布在扩容的节点里面。", subTitle: "关于扩容",
              onTap: () {
            AtlasApi.goToAtlasMap3HelpPage(context);
          }),
        ],
      ),
    );
  }

  Widget _nodeWidget(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Column(
        children: <Widget>[
          _nodeOwnerWidget(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Divider(
              height: 2,
            ),
          ),
          _delegateCountWidget(),
        ],
      ),
    );
  }

  Widget _delegateCountWidget() {
    return Padding(
      padding:
          const EdgeInsets.only(top: 20.0, bottom: 16.0, left: 16, right: 16),
      child: profitListWidget(
        [
          {"总抵押": widget.map3infoEntity.staking},
          {"管理费": '${widget.map3infoEntity.feeRate}%'},
          {"最低抵押": ''}
        ],
      ),
    );
  }

  Widget _confirmButtonWidget() {
    return Container(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 18.0, top: 10),
        child: Center(
          child: ClickOvalButton(
            "确定",
            () {
              // if (!(_joinCoinFormKey.currentState?.validate()??false)) {
              //   return;
              // };

              if (_joinCoinController?.text?.isEmpty ?? true) {
                Fluttertoast.showToast(
                    msg: S.of(context).please_input_hyn_count);
                return;
              }

              var amount = _joinCoinController?.text ?? "200000";
              var entity =
                  PledgeMap3Entity.onlyType(AtlasActionType.JOIN_DELEGATE_MAP3);
              entity.payload = PledgeMap3Payload("abc", amount);
              entity.amount = amount;
              var message = ConfirmDelegateMap3NodeMessage(
                entity: entity,
                map3NodeAddress: "xxx",
              );
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Map3NodeConfirmPage(
                      message: message,
                    ),
                  ));
            },
            height: 46,
            width: MediaQuery.of(context).size.width - 37 * 2,
            fontSize: 18,
          ),
        ),
      ),
    );
  }

  Widget _nodeOwnerWidget() {
    return Padding(
      padding:
          const EdgeInsets.only(left: 16.0, top: 18, right: 18, bottom: 18),
      child: Row(
        children: <Widget>[
          Image.asset(
            "res/drawable/ic_map3_node_default_icon.png",
            width: 42,
            height: 42,
            fit: BoxFit.cover,
          ),
          SizedBox(
            width: 10,
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text.rich(TextSpan(children: [
                TextSpan(
                    text: widget.map3infoEntity.name,
                    style:
                        TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                TextSpan(
                    text: "  币龄: ${FormatUtil.truncateDecimalNum(Decimal.parse(_map3nodeInformationEntity.map3Node.age), 0)}天",
                    style: TextStyle(fontSize: 13, color: HexColor("#333333"))),
              ])),
              Container(
                height: 4,
              ),
              Text("节点地址 ${shortBlockChainAddress(widget.map3infoEntity.address)}", style: TextStyles.textC9b9b9bS12),
            ],
          ),
          Spacer(),
//          Column(
//            crossAxisAlignment: CrossAxisAlignment.end,
//            children: <Widget>[
//              Container(
//                color: HexColor("#1FB9C7").withOpacity(0.08),
//                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//                child: Text("第一期",
//                    style: TextStyle(fontSize: 12, color: HexColor("#5C4304"))),
//              ),
//              Container(
//                height: 4,
//              ),
//            ],
//          ),
        ],
      ),
    );
  }
}
