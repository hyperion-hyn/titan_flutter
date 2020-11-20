import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:titan/generated/l10n.dart';
import 'package:titan/src/basic/utils/hex_color.dart';
import 'package:titan/src/basic/widget/base_app_bar.dart';
import 'package:titan/src/basic/widget/base_state.dart';
import 'package:titan/src/components/atlas/atlas_component.dart';
import 'package:titan/src/components/wallet/wallet_component.dart';
import 'package:titan/src/config/consts.dart';
import 'package:titan/src/pages/atlas_map/api/atlas_api.dart';
import 'package:titan/src/pages/atlas_map/entity/atlas_message.dart';
import 'package:titan/src/pages/atlas_map/entity/enum_atlas_type.dart';
import 'package:titan/src/pages/atlas_map/entity/map3_user_entity.dart';
import 'package:titan/src/pages/atlas_map/map3/map3_node_public_widget.dart';
import 'package:titan/src/pages/wallet/model/hyn_transfer_history.dart';
import 'package:titan/src/plugins/wallet/wallet_util.dart';
import 'package:web3dart/src/models/map3_node_information_entity.dart';
import 'package:titan/src/pages/atlas_map/entity/map3_info_entity.dart';
import 'package:titan/src/plugins/wallet/convert.dart';
import 'package:titan/src/style/titan_sytle.dart';
import 'package:titan/src/utils/format_util.dart';
import 'package:titan/src/utils/log_util.dart';
import 'package:titan/src/utils/utile_ui.dart';
import 'package:titan/src/widget/loading_button/click_oval_button.dart';
import 'package:titan/src/widget/wallet_widget.dart';
import 'package:web3dart/web3dart.dart';
import '../../../global.dart';
import 'map3_node_confirm_page.dart';
import 'package:titan/src/basic/widget/load_data_container/bloc/bloc.dart';
import 'package:titan/src/basic/widget/load_data_container/load_data_container.dart';

class Map3NodeExitPage extends StatefulWidget {
  final Map3InfoEntity map3infoEntity;

  Map3NodeExitPage({this.map3infoEntity});

  @override
  State<StatefulWidget> createState() {
    return _Map3NodeExitState();
  }
}

class _Map3NodeExitState extends BaseState<Map3NodeExitPage> {
  LoadDataBloc _loadDataBloc = LoadDataBloc();
  Map3InfoEntity _map3infoEntity;
  Map3NodeInformationEntity _map3nodeInformationEntity;
  AtlasApi _atlasApi = AtlasApi();

  String get _nodeId => _map3infoEntity?.nodeId ?? _map3nodeInformationEntity?.map3Node?.description?.identity ?? '';
  String get _nodeAddress => _map3infoEntity?.address ?? _map3nodeInformationEntity?.map3Node?.map3Address ?? '';

  var _walletName = "";
  var _walletAddress = "";
  Microdelegations _microDelegationsJoiner;
  final _client = WalletUtil.getWeb3Client(true);
  List<Map3UserEntity> _map3UserList = [];


  double get _unlockEpoch => double.tryParse(_microDelegationsJoiner?.pendingDelegation?.unlockedEpoch ?? '0') ?? 0;
  int _currentEpoch = 0;

  int get _remainEpochInt {
    var remain = _unlockEpoch - _currentEpoch.toDouble();
    if (remain >= 1) {
      return remain.toInt();
    } else if (remain > 0 && remain < 1) {
      return 1;
    }
    return 0;
  }

  int _status = 0;
  bool _isHaveExit = false;

  get _canExit =>
      (_map3infoEntity.status == Map3InfoStatus.FUNDRAISING_NO_CANCEL.index) &&
      (_remainEpochInt <= 0) &&
      (_map3infoEntity?.isCreator() ?? false) &&
      (_map3UserList?.isNotEmpty ?? false) &&
      (!_isHaveExit);

  String get _notification {
    var notification = '';
    switch (_status) {
      case TransactionStatus.pending:
        notification = '终止请求处理中...';

        break;

      case TransactionStatus.success:
        notification = '节点已终止，抵押金额已返回您的钱包';

        //notification = '终止请求已完成, 请前往【钱包】查看退款情况!';
        break;
    }
    return notification;
  }

  @override
  void initState() {
    _setupData();

    super.initState();
  }

  @override
  void onCreated() {
    getNetworkData();

    super.onCreated();
  }

  _setupData() {
    var activatedWallet = WalletInheritedModel.of(Keys.rootKey.currentContext).activatedWallet;
    var _wallet = activatedWallet?.wallet;
    _walletAddress = _wallet?.getEthAccount()?.address ?? "";
    _walletName = _wallet?.keystore?.name ?? "";

    _map3infoEntity = widget.map3infoEntity;
  }

  @override
  void dispose() {
    print("[${widget.runtimeType}] dispose");

    _loadDataBloc.close();
    super.dispose();
  }

  Future getNetworkData() async {
    try {
      var map3Address = EthereumAddress.fromHex(_nodeAddress);
      _map3infoEntity = await _atlasApi.getMap3Info(_walletAddress, _nodeId);

      List<HynTransferHistory> list = await AtlasApi().getTxsList(
        _walletAddress,
        type: [MessageType.typeTerminateMap3],
        map3Address: _nodeAddress,
      );
      var isNotEmpty = list?.isNotEmpty ?? false;
      if (isNotEmpty) {
        _status = list.first.status;
        _isHaveExit = _status >= TransactionStatus.pending && _status <= TransactionStatus.success;
      }

      _map3UserList = await _atlasApi.getMap3UserList(_nodeId, size: 0);

      _map3nodeInformationEntity = await _client.getMap3NodeInformation(map3Address);
      _setupMicroDelegations();

      if (mounted) {
        setState(() {
          _loadDataBloc.add(RefreshSuccessEvent());
        });
      }
    } catch (e) {
      logger.e(e);
      LogUtil.toastException(e);

      if (mounted) {
        setState(() {
          _loadDataBloc.add(RefreshFailEvent());
        });
      }
    }
  }

  _setupMicroDelegations() {
    if (_map3nodeInformationEntity?.microdelegations?.isEmpty ?? true) {
      return;
    }

    var joinerAddress = _walletAddress.toLowerCase();

    for (var item in _map3nodeInformationEntity.microdelegations) {
      var delegatorAddress = item.delegatorAddress;
      if (delegatorAddress.isNotEmpty && (delegatorAddress.toLowerCase()) == joinerAddress) {
        _microDelegationsJoiner = item;
        break;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    _currentEpoch = AtlasInheritedModel.of(context).currentEpoch;

    var walletAddressStr =
        "${S.of(context).wallet_address} ${UiUtil.shortEthAddress(WalletUtil.ethAddressToBech32Address(_walletAddress) ?? "***", limitLength: 9)}";

    var nodeName = _map3infoEntity?.name ?? "***";
    var oldYearValue = '';
    var nodeAddress =
        "${UiUtil.shortEthAddress(WalletUtil.ethAddressToBech32Address(_nodeAddress) ?? "***", limitLength: 9)}";



    return Scaffold(
      appBar: BaseAppBar(
        baseTitle: S.of(context).terminate_node,
      ),

      //backgroundColor: Color(0xffF3F0F5),
      body: Container(
        color: Colors.white,
        child: Column(
          children: <Widget>[
            topNotifyWidget(
              notification: _notification,
              isWarning: false,
            ),
            Expanded(
              child: LoadDataContainer(
                bloc: _loadDataBloc,
                enablePullUp: false,
                onRefresh: getNetworkData,
                child: SingleChildScrollView(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Container(
                    color: Colors.white,
                    child: Column(
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.only(left: 16.0, top: 18, right: 18),
                          child: Row(
                            children: <Widget>[
                              SizedBox(
                                width: 42,
                                height: 42,
                                child: walletHeaderWidget(
                                  _map3infoEntity?.name ?? '',
                                  isShowShape: false,
                                  address: _map3infoEntity?.address ?? '',
                                  isCircle: false,
                                ),
                              ),
                              SizedBox(
                                width: 8,
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text.rich(TextSpan(children: [
                                    TextSpan(
                                        text: nodeName, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                                    TextSpan(
                                        text: oldYearValue, style: TextStyle(fontSize: 12, color: HexColor("#999999"))),
                                  ])),
                                  Container(
                                    height: 4,
                                  ),
                                  Text(nodeAddress, style: TextStyles.textC9b9b9bS12),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 16.0, top: 16, right: 16),
                          child: Container(
                            color: HexColor("#F2F2F2"),
                            height: 0.5,
                          ),
                        ),
                        _nodeServerWidget(),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 10,
                    child: Container(
                      color: HexColor("#F4F4F4"),
                    ),
                  ),
                  Container(
                    color: Colors.white,
                    child: Column(
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.only(left: 16.0, top: 18),
                          child: Row(
                            children: <Widget>[
                              Text(S.of(context).receive_wallet,
                                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 16.0, top: 16, right: 8, bottom: 18),
                          child: Row(
                            children: <Widget>[
                              SizedBox(
                                width: 42,
                                height: 42,
                                child: walletHeaderWidget(
                                  _walletName,
                                  isShowShape: false,
                                  address: _walletAddress,
                                  isCircle: true,
                                ),
                              ),
                              SizedBox(
                                width: 6,
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text.rich(TextSpan(children: [
                                    TextSpan(
                                        text: _walletName, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                                    TextSpan(text: "", style: TextStyles.textC333S14bold),
                                  ])),
                                  Container(
                                    height: 4,
                                  ),
                                  Text(walletAddressStr, style: TextStyles.textC9b9b9bS12),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 10,
                    child: Container(
                      color: HexColor("#F4F4F4"),
                    ),
                  ),
                  Container(
                    color: Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 16.0, top: 12, bottom: 12, right: 12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.only(top: 3),
                            child: Text(
                              "*",
                              style: TextStyle(fontSize: 22, color: HexColor("#FF4C3B")),
                            ),
                          ),
                          SizedBox(
                            width: 12,
                          ),
                          Expanded(
                            child: Text(
                              S.of(context).cant_active_node_after_terminate,
//                            "撤销抵押将会影响节点进度，剩余抵押不足20%节点将会被取消",
                              style: TextStyle(fontSize: 14, color: HexColor("#333333"), height: 1.5),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  _epochHint(),
                ])),
              ),
            ),
            _confirmButtonWidget(),
          ],
        ),
      ),
    );
  }

  _epochHint() {
    if (_remainEpochInt == 0) return Container();

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 32.0),
        child: Column(
          children: [
            Text(S.of(context).cant_cancel_staking),
            SizedBox(
              height: 9,
            ),
            Text(
              S.of(context).unlock_remain_epoch(_remainEpochInt),
              style: TextStyle(
                color: DefaultColors.color999,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _confirmButtonWidget() {
    if (_map3UserList?.isEmpty ?? true) return Container();

    return Container(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 18.0, top: 10),
        child: Center(
          child: ClickOvalButton(
            S.of(context).confirm_terminate,
            _confirmAction,
            height: 46,
            width: MediaQuery.of(context).size.width - 37 * 2,
            fontSize: 18,
            isLoading: !_canExit,
          ),
        ),
      ),
    );
  }

  _confirmAction() async {
    if (!_canExit || (_nodeAddress?.isEmpty ?? true)) {
      return;
    }

    var entity = await createPledgeMap3Entity(
      context,
      _nodeId,
      action: 'exit',
    );

    var message = ConfirmTerminateMap3NodeMessage(
      entity: entity,
      map3NodeAddress: _nodeAddress,
    );

    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => Map3NodeConfirmPage(
            message: message,
          ),
        ));
  }

  Widget _nodeServerWidget() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [1, 0, 2, 0, 3, 0, 4].map((value) {
          var title = "";
          var detail = "";
          var subDetail = "";
          switch (value) {
            case 1:
              title = S.of(context).create_date;
              detail = FormatUtil.newFormatUTCDateStr(_map3infoEntity.createdAt, isSecond: true);

              break;

            case 2:
              title = S.of(context).join_address;
              detail = "${_map3UserList?.length ?? 0}个";
              break;

            case 3:
              title = S.of(context).node_total_staking;
              detail = FormatUtil.stringFormatCoinNum(_map3infoEntity?.getStaking());

              break;

            case 4:
              title = S.of(context).my_staking;

              var isStart = _map3infoEntity.status == Map3InfoStatus.CONTRACT_HAS_STARTED.index;
              var pendingAmount = _microDelegationsJoiner?.pendingDelegation?.amount;
              var activeAmount = _microDelegationsJoiner?.amount;
              var myAmount = isStart ? activeAmount : pendingAmount;

              detail = ConvertTokenUnit.weiToEther(
                      weiBigInt: BigInt.parse('${FormatUtil.clearScientificCounting(myAmount?.toDouble() ?? 0)}'))
                  .toString();
              break;

            default:
              return SizedBox(
                height: 12,
              );
              break;
          }

          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(
                child: RichText(
                  text: TextSpan(
                    text: title,
                    style: TextStyle(fontSize: 14, color: HexColor("#92979A")),
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: RichText(
                  text: TextSpan(
                    text: detail,
                    style: TextStyle(fontSize: 14, color: HexColor("#333333")),
                    children: [
                      TextSpan(
                        text: subDetail,
                        style: TextStyle(fontSize: 12, color: HexColor("#999999")),
                      )
                    ],
                  ),
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }
}
