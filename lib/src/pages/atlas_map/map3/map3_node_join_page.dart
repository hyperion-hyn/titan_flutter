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
import 'package:titan/src/pages/atlas_map/api/atlas_api.dart';
import 'package:titan/src/pages/atlas_map/entity/atlas_message.dart';
import 'package:titan/src/pages/atlas_map/entity/map3_info_entity.dart';
import 'package:titan/src/pages/atlas_map/entity/map3_introduce_entity.dart';
import 'package:titan/src/pages/atlas_map/entity/pledge_map3_entity.dart';
import 'package:titan/src/plugins/wallet/convert.dart';
import 'package:titan/src/plugins/wallet/wallet_util.dart';
import 'package:titan/src/style/titan_sytle.dart';
import 'package:titan/src/utils/format_util.dart';
import 'package:titan/src/utils/log_util.dart';
import 'package:titan/src/utils/utile_ui.dart';

import 'package:titan/src/widget/loading_button/click_oval_button.dart';
import 'package:web3dart/web3dart.dart';
import '../../../global.dart';
import 'map3_node_confirm_page.dart';
import 'map3_node_public_widget.dart';

import 'package:titan/src/widget/all_page_state/all_page_state.dart';
import 'package:titan/src/widget/all_page_state/all_page_state_container.dart';
import 'package:titan/src/widget/all_page_state/all_page_state.dart' as all_page_state;
import 'package:web3dart/src/models/map3_node_information_entity.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:titan/src/components/wallet/bloc/bloc.dart';
import 'package:titan/src/components/wallet/bloc/wallet_cmp_event.dart';

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

  PublishSubject<String> _filterSubject = PublishSubject<String>();
  String endProfit = "";
  String spendManager = "";

  List<String> _suggestList = [];
  String originInputStr = "";

  final client = WalletUtil.getWeb3Client(true);
  Map3NodeInformationEntity _map3nodeInformationEntity;
  Map3IntroduceEntity _map3introduceEntity;

  @override
  void initState() {
    _joinCoinController.addListener(textChangeListener);

    _filterSubject.debounceTime(Duration(milliseconds: 500)).listen((text) {
      getCurrentSpend(text);
    });

    super.initState();
  }


  @override
  void didChangeDependencies() {

    super.didChangeDependencies();

    if (context != null) {
      BlocProvider.of<WalletCmpBloc>(context).add(UpdateActivatedWalletBalanceEvent());
    }
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
    getNetworkData();

    super.onCreated();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      //backgroundColor: Color(0xffF3F0F5),
      appBar: BaseAppBar(
        baseTitle: '抵押Map3节点',
      ),
      body: _pageView(context),
    );
  }

  Future getNetworkData() async {
    try {
      var requestList = await Future.wait([
        _atlasApi.getMapRecStaking(),
        AtlasApi.getIntroduceEntity(),
      ]);

      _suggestList = requestList[0];
      _map3introduceEntity = requestList[1];

      if ((widget?.map3infoEntity?.address ?? "").isNotEmpty) {
        var map3Address = EthereumAddress.fromHex(widget.map3infoEntity.address);

        print('map3Address: $map3Address');

        _map3nodeInformationEntity = await client.getMap3NodeInformation(map3Address);
      }

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

    if (mounted) {
      setState(() {
        _joinCoinController.value = TextEditingValue(
            // 设置内容
            text: inputText,
            // 保持光标在最后
            selection:
                TextSelection.fromPosition(TextPosition(affinity: TextAffinity.downstream, offset: inputText.length)));
      });
    }
  }

  Widget _pageView(BuildContext context) {
    if (_currentState != null || widget.map3infoEntity == null || _map3introduceEntity == null) {
      return Scaffold(
        body: AllPageStateContainer(_currentState, () {
          setState(() {
            _currentState = LoadingState();
          });
          getNetworkData();
        }),
      );
    }

    var spaceWidget = Container(
      height: 8,
      color: HexColor("#F8F8F8"),
    );
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
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                _nodeWidget(context),
                spaceWidget,
                getHoldInNum(
                  context,
                  widget.map3infoEntity,
                  _joinCoinFormKey,
                  _joinCoinController,
                  endProfit,
                  spendManager,
                  isJoin: true,
                  suggestList: _suggestList,
                  map3introduceEntity: _map3introduceEntity,
                ),
                spaceWidget,
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
    var startMin = FormatUtil.formatPrice(double.parse(_map3introduceEntity.startMin));
    var delegateMin = FormatUtil.formatPrice(double.parse(_map3introduceEntity.delegateMin));
    return Container(
      color: Colors.white,
      //height: MediaQuery.of(context).size.height-50,
      padding: const EdgeInsets.only(left: 20.0, right: 20, bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(top: 16.0, bottom: 8),
            child: Text("注意事项", style: TextStyle(color: HexColor("#333333"), fontSize: 16)),
          ),
          rowTipsItem("抵押7天内不可撤销", top: 0),
          rowTipsItem("需要总抵押满${startMin}HYN才能正式启动，每次参与抵押数额不少于${delegateMin}HYN"),
          rowTipsItem("节点主在到期前倒数第二周设置下一周期是否继续运行，或调整管理费率。抵押者在到期前最后一周可选择是否跟随下一周期"),
          /*rowTipsItem("如果节点主扩容节点，你的抵押也会分布在扩容的节点里面。", subTitle: "关于扩容", onTap: () {
            AtlasApi.goToAtlasMap3HelpPage(context);
          }),*/
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
    var totalPendingDelegation = _map3nodeInformationEntity?.totalPendingDelegation?.toDouble()??0;
    print("totalPendingDelegation: $totalPendingDelegation");

    var totalPendingDelegationValue = ConvertTokenUnit.weiToEther(
            weiBigInt: BigInt.parse('${FormatUtil.clearScientificCounting(totalPendingDelegation)}'))
        .toDouble();

    return Padding(
      padding: const EdgeInsets.only(top: 20.0, bottom: 16.0, left: 16, right: 16),
      child: profitListBigWidget(
        [
          {"总抵押": FormatUtil.formatPrice(double.parse(_map3introduceEntity.startMin))},
          {"当前抵押": FormatUtil.formatPrice(totalPendingDelegationValue)},
          {"管理费": FormatUtil.formatPercent(double.parse(widget.map3infoEntity.getFeeRate()))},
          {"最低抵押": FormatUtil.formatPrice(double.parse(_map3introduceEntity.delegateMin))}
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
              if (!(_joinCoinFormKey.currentState?.validate() ?? false)) {
                return;
              }

              if (_joinCoinController?.text?.isEmpty ?? true) {
                Fluttertoast.showToast(msg: S.of(context).please_input_hyn_count);
                return;
              }

              var amount = _joinCoinController?.text;
              var delegateMin = double.parse(_map3introduceEntity.delegateMin);
              var inputValue = double.parse(amount);
              if (delegateMin > inputValue && inputValue > 0) {
                Fluttertoast.showToast(msg: S.of(context).mintotal_buy(FormatUtil.formatNumDecimal(delegateMin)));
                return;
              }

              //if (_map3nodeInformationEntity == null) return;

              var entity = PledgeMap3Entity(
                  payload: Payload(
                userIdentity: widget.map3infoEntity.nodeId,
              ));
              var message = ConfirmDelegateMap3NodeMessage(
                entity: entity,
                map3NodeAddress: widget.map3infoEntity.address,
                amount: amount,
                pendingAmount: _map3nodeInformationEntity?.totalPendingDelegation?.toString()??"0",
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
    var oldYear = double.parse(_map3nodeInformationEntity?.map3Node?.age ?? "0").toInt();
    var oldYearValue = oldYear > 0 ? "  节龄: ${FormatUtil.formatPrice(oldYear.toDouble())}" : "";
    var nodeAddress =
        "${UiUtil.shortEthAddress(WalletUtil.ethAddressToBech32Address(widget?.map3infoEntity?.address??"") ?? "***", limitLength: 9)}";

    return Padding(
      padding: const EdgeInsets.only(left: 16.0, top: 18, right: 18, bottom: 18),
      child: Row(
        children: <Widget>[
          iconMap3Widget(widget.map3infoEntity),
          SizedBox(
            width: 10,
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text.rich(TextSpan(children: [
                TextSpan(text: widget?.map3infoEntity?.name??"", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                TextSpan(text: oldYearValue, style: TextStyle(fontSize: 13, color: HexColor("#333333"))),
              ])),
              Container(
                height: 4,
              ),
              Text(nodeAddress, style: TextStyles.textC9b9b9bS12),
            ],
          ),
          Spacer(),
        ],
      ),
    );
  }
}
