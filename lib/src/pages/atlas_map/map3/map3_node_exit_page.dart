import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:titan/src/basic/utils/hex_color.dart';
import 'package:titan/src/basic/widget/base_app_bar.dart';
import 'package:titan/src/basic/widget/base_state.dart';
import 'package:titan/src/components/wallet/wallet_component.dart';
import 'package:titan/src/config/consts.dart';

import 'package:titan/src/pages/atlas_map/api/atlas_api.dart';
import 'package:titan/src/pages/atlas_map/entity/atlas_message.dart';
import 'package:titan/src/pages/atlas_map/entity/enum_atlas_type.dart';
import 'package:titan/src/pages/atlas_map/entity/map3_user_entity.dart';
import 'package:titan/src/plugins/wallet/wallet_util.dart';
import 'package:web3dart/src/models/map3_node_information_entity.dart';
import 'package:titan/src/pages/atlas_map/entity/map3_info_entity.dart';
import 'package:titan/src/pages/atlas_map/entity/pledge_map3_entity.dart';
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
import 'package:titan/src/widget/all_page_state/all_page_state_container.dart';
import 'package:titan/src/widget/all_page_state/all_page_state.dart' as all_page_state;

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
  all_page_state.AllPageState _currentState = all_page_state.LoadingState();
  Map3InfoEntity _map3infoEntity;
  AtlasApi _atlasApi = AtlasApi();

  var _nodeId = "";
  var _walletName = "";
  var _walletAddress = "";
  Microdelegations _microDelegationsJoiner;
  final _client = WalletUtil.getWeb3Client(true);
  List<Map3UserEntity> _map3UserList = [];
  Map3NodeInformationEntity _map3nodeInformationEntity;

  @override
  void onCreated() {
    var activatedWallet = WalletInheritedModel.of(Keys.rootKey.currentContext).activatedWallet;
    var _wallet = activatedWallet?.wallet;
    _walletAddress = _wallet?.getEthAccount()?.address ?? "";
    _walletName = _wallet?.keystore?.name ?? "";
    _nodeId = widget?.map3infoEntity?.nodeId ?? "";

    getNetworkData();

    super.onCreated();
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    print("[${widget.runtimeType}] dispose");

    _loadDataBloc.close();
    super.dispose();
  }

  _setupMicroDelegations() {
    if (_map3nodeInformationEntity?.microdelegations?.isEmpty ?? true) {
      return;
    }

    var joinerAddress = _walletAddress.toLowerCase();

    for (var item in _map3nodeInformationEntity.microdelegations) {
      if (item.delegatorAddress.isNotEmpty && item.delegatorAddress == joinerAddress) {
        if (item.delegatorAddress.toLowerCase() == joinerAddress) {
          _microDelegationsJoiner = item;
          break;
        }
      }
    }
  }

  Future getNetworkData() async {
    try {
      var map3Address = EthereumAddress.fromHex(widget.map3infoEntity.address);

      _map3infoEntity = await _atlasApi.getMap3Info(_walletAddress, _nodeId);

      _map3nodeInformationEntity = await _client.getMap3NodeInformation(map3Address);
      _setupMicroDelegations();

      _map3UserList = await _atlasApi.getMap3UserList(widget.map3infoEntity.nodeId, size: 0);

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

  @override
  Widget build(BuildContext context) {
    if (_currentState != null || _map3infoEntity == null) {
      return Scaffold(
        appBar: BaseAppBar(
          baseTitle: '终止节点',
        ),
        body: AllPageStateContainer(_currentState, () {
          setState(() {
            _currentState = all_page_state.LoadingState();
          });
          getNetworkData();
        }),
      );
    }

    var walletAddressStr =
        "钱包地址 ${UiUtil.shortEthAddress(WalletUtil.ethAddressToBech32Address(_walletAddress) ?? "***", limitLength: 9)}";

    var nodeName = _map3infoEntity?.name ?? "***";
    var oldYear = double.parse(_map3nodeInformationEntity?.map3Node?.age ?? "0").toInt();
    var oldYearValue = oldYear > 0 ? "  节龄: ${FormatUtil.formatPrice(oldYear.toDouble())}" : "";
    var nodeAddress =
        "${UiUtil.shortEthAddress(WalletUtil.ethAddressToBech32Address(_map3infoEntity?.address) ?? "***", limitLength: 9)}";

    return Scaffold(
      appBar: BaseAppBar(
        baseTitle: '终止节点',
      ),

      //backgroundColor: Color(0xffF3F0F5),
      body: Container(
        color: Colors.white,
        child: Column(
          children: <Widget>[
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
                                  _map3infoEntity.name,
                                  isShowShape: false,
                                  address: _map3infoEntity.address,
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
                              Text("到账钱包", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
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
                              "终止后无法再次激活，请谨慎操作！",
//                            "撤销抵押将会影响节点进度，剩余抵押不足20%节点将会被取消",
                              style: TextStyle(fontSize: 14, color: HexColor("#333333"), height: 1.5),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ])),
              ),
            ),
            _confirmButtonWidget(),
          ],
        ),
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
            "确认终止",
            () {
              //print("_map3infoEntity.status:${_map3infoEntity.status}");
              var isPending = (_map3infoEntity.status == Map3InfoStatus.FUNDRAISING_NO_CANCEL.index);
              if (isPending) {
                var entity = PledgeMap3Entity(
                    payload: Payload(
                  userName: _walletName,
                  userIdentity: widget.map3infoEntity.nodeId,
                ));

                var message = ConfirmTerminateMap3NodeMessage(
                  entity: entity,
                  map3NodeAddress: widget.map3infoEntity.address,
                );

                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Map3NodeConfirmPage(
                        message: message,
                      ),
                    ));
              }
            },
            height: 46,
            width: MediaQuery.of(context).size.width - 37 * 2,
            fontSize: 18,
          ),
        ),
      ),
    );
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
              title = "创建日期";
              detail = FormatUtil.formatUTCDateStr(widget.map3infoEntity.createdAt, isSecond: true);

              break;

            case 2:
              title = "参与地址";
              detail = "${_map3UserList?.length ?? 0}个";
              break;

            case 3:
              title = "节点总抵押";
              detail = FormatUtil.stringFormatNum(ConvertTokenUnit.weiToEther(
                  weiBigInt: BigInt.parse(
                widget.map3infoEntity?.staking ?? "0",
              )).toString());

              break;

            case 4:
              title = "我的抵押";
              detail = ConvertTokenUnit.weiToEther(
                      weiBigInt: BigInt.parse(
                          '${FormatUtil.clearScientificCounting(_microDelegationsJoiner?.pendingDelegation?.amount ?? 0)}'))
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
