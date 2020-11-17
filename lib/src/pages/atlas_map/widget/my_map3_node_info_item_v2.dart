import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:titan/generated/l10n.dart';
import 'package:titan/src/basic/utils/hex_color.dart';
import 'package:titan/src/basic/widget/load_data_container/load_data_container.dart';
import 'package:titan/src/components/atlas/atlas_component.dart';
import 'package:titan/src/components/wallet/wallet_component.dart';
import 'package:titan/src/config/application.dart';
import 'package:titan/src/config/consts.dart';
import 'package:titan/src/pages/atlas_map/entity/enum_atlas_type.dart';
import 'package:titan/src/pages/atlas_map/entity/map3_info_entity.dart';
import 'package:titan/src/pages/atlas_map/map3/map3_node_collect_reward_page.dart';
import 'package:titan/src/pages/atlas_map/map3/map3_node_detail_page.dart';
import 'package:titan/src/pages/atlas_map/map3/map3_node_public_widget.dart';
import 'package:titan/src/pages/mine/about_me_page.dart';
import 'package:titan/src/pages/node/model/map3_node_util.dart';
import 'package:titan/src/plugins/wallet/wallet_util.dart';
import 'package:titan/src/routes/fluro_convert_utils.dart';
import 'package:titan/src/routes/routes.dart';
import 'package:titan/src/style/titan_sytle.dart';
import 'package:titan/src/utils/image_util.dart';
import 'package:titan/src/widget/wallet_widget.dart';
import 'package:web3dart/src/models/map3_node_information_entity.dart';
import 'package:web3dart/web3dart.dart';
import 'package:web3dart/credentials.dart';
import 'package:titan/src/utils/log_util.dart';

class MyMap3NodeInfoItemV2 extends StatefulWidget {
  final Map3InfoEntity _map3infoEntity;

  MyMap3NodeInfoItemV2(this._map3infoEntity);

  @override
  State<StatefulWidget> createState() {
    return _MyMap3NodeInfoItemV2State();
  }
}

class _MyMap3NodeInfoItemV2State extends State<MyMap3NodeInfoItemV2>
    with AutomaticKeepAliveClientMixin {
  bool _isLoading = true;
  Map3NodeInformationEntity _map3nodeInformationEntity;
  var nodeName = '';
  var nodeId = '';
  Map3InfoStatus status;

  var _isNodeCreator = false;

  var stateDescText = '';

  Microdelegations _microDelegations;
  bool _isShowBorderHint = false;

  final _client = WalletUtil.getWeb3Client(true);

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _initData();
  }

  _initData() async {
    try {
      nodeName = widget._map3infoEntity?.name ?? '';
      nodeId = widget._map3infoEntity?.nodeId ?? '';
      status = Map3InfoStatus.values[widget._map3infoEntity?.status ?? 0];
      stateDescText = Map3NodeUtil.stateDescText(status);

      var activatedWallet =
          WalletInheritedModel.of(Keys.rootKey.currentContext).activatedWallet;
      var wallet = activatedWallet?.wallet;

      var map3Address = EthereumAddress.fromHex(
        widget._map3infoEntity?.address ?? '',
      );
      var walletAddress = EthereumAddress.fromHex(
        wallet?.getAtlasAccount()?.address ?? '',
      );

      _map3nodeInformationEntity = await _client.getMap3NodeInformation(
        map3Address,
      );

      String _nodeCreatorAddress = widget._map3infoEntity?.creator ??
          _map3nodeInformationEntity?.map3Node?.operatorAddress ??
          '';

      _isNodeCreator =
          _nodeCreatorAddress == wallet?.getAtlasAccount()?.address ?? '';

      _microDelegations = await _client.getMap3NodeDelegation(
        map3Address,
        walletAddress,
      );

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _initData();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Application.router.navigateTo(
          context,
          Routes.map3node_contract_detail_page +
              '?info=${FluroConvertUtils.object2string(
                widget._map3infoEntity.toJson(),
              )}',
        );
      },
      child: Container(
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.only(
              top: 8.0, right: 8.0, left: 8.0, bottom: 8.0),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              border: _isShowBorderHint
                  ? Border.all(
                      color: HexColor('#FFFF4C3B').withOpacity(
                      0.5,
                    ))
                  : null,
              borderRadius: BorderRadius.circular(6),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey[200],
                  blurRadius: 15.0,
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 12.0,
                vertical: 8.0,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  iconMap3Widget(widget._map3infoEntity),
                  SizedBox(
                    width: 8,
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          '$nodeName',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                        Container(
                          height: 2,
                        ),
                        Row(
                          children: <Widget>[
                            Text(
                              '${S.of(context).node_num}: ${nodeId}',
                              style: TextStyle(
                                color: DefaultColors.color999,
                                fontSize: 10,
                              ),
                            )
                          ],
                        )
                      ],
                    ),
                  ),
                  _isLoading
                      ? Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Center(
                            child: SizedBox(
                              height: 16,
                              width: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                              ),
                            ),
                          ),
                        )
                      : Expanded(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Spacer(),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 4.0),
                                child: Container(
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Map3NodeUtil.statusColor(status),
                                    border: Border.all(
                                      color: Map3NodeUtil.statusBorderColor(
                                          status),
                                      width: 1.0,
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: 8,
                              ),
                              Container(
                                constraints: BoxConstraints(
                                  maxWidth: 100,
                                ),
                                child: _reminderTextWidget(),
                              )
                            ],
                          ),
                        )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _reminderTextWidget() {
    setState(() {
      _isLoading = true;
    });
    var _content = '';

    var _isJoiner = !_isNodeCreator;

    var _currentEpoch = AtlasInheritedModel.of(context).currentEpoch;
    var _releaseEpoch = (widget._map3infoEntity?.endEpoch ?? 0);

    var _creatorCanEditEpoch = _releaseEpoch - 14 + 1;
    var _joinerCanEditEpoch = _releaseEpoch - 7 + 1;

    bool _creatorCanEdit = (_currentEpoch >= _creatorCanEditEpoch) &&
        (_currentEpoch < _joinerCanEditEpoch);

    bool _joinerCanEdit = (_currentEpoch >= _joinerCanEditEpoch) &&
        (_currentEpoch < _releaseEpoch);

    bool _hasRenew = (_microDelegations?.renewal?.status ?? 0) != 0;

    var _hasReDelegation =
        (_map3nodeInformationEntity?.redelegationReference ?? '') !=
            '0x0000000000000000000000000000000000000000';

    setState(() {
      _isLoading = false;
    });

    ///not show hint
    if (!(status == Map3InfoStatus.CONTRACT_HAS_STARTED)) {
      _isShowBorderHint = false;
      return Text(
        stateDescText,
        style: TextStyle(
          color: Map3NodeUtil.statusColor(status),
          fontSize: 11,
        ),
      );
    }

    ///creator edit hint
    if (_isNodeCreator && _currentEpoch < _creatorCanEditEpoch) {
      _content = '距离可以设置下期续约还有${_creatorCanEditEpoch - _currentEpoch}纪元';
    }

    if (!_hasRenew && _isNodeCreator && _creatorCanEdit) {
      _isShowBorderHint = true;
      _content = '节点即将结束，请尽快设置下期续约';
    }

    ///Joiner edit hin
    if (_isJoiner && _currentEpoch < _joinerCanEditEpoch) {
      _content = '距离可以设置下期续约还有${_joinerCanEditEpoch - _currentEpoch}纪元';
    }

    if (!_hasRenew && _isJoiner && _joinerCanEdit) {
      _isShowBorderHint = true;
      _content = '节点即将结束，请尽快设置下期是否跟随续约';
    }

    if (!_hasReDelegation) {
      _isShowBorderHint = true;
      _content = _isNodeCreator ? '尚未复投Atlas节点' : '请节点主尽快复抵押至atlas节点以享受出块奖励';
    }

    if (_content.isNotEmpty) {
      return Text(
        _content,
        textAlign: TextAlign.right,
        style: TextStyle(
          color: DefaultColors.color999,
          fontSize: 11,
        ),
      );
    } else {
      _isShowBorderHint = false;
      return Text(
        stateDescText,
        style: TextStyle(
          color: Map3NodeUtil.statusColor(status),
          fontSize: 11,
        ),
      );
    }
  }
}
