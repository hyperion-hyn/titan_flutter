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

class _MyMap3NodeInfoItemV2State extends State<MyMap3NodeInfoItemV2> {
  bool _isLoading = true;
  Map3NodeInformationEntity _map3nodeInformationEntity;
  var nodeName = '';
  var nodeId = '';
  Map3InfoStatus status;

  var _isNodeCreator = false;

  var stateDescText = '';

  Microdelegations _microDelegations;
  bool hasReDelegation = false;
  bool _isShowBorderHint = false;
  String _reminderText = '';

  final _client = WalletUtil.getWeb3Client(true);

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
      hasReDelegation = widget._map3infoEntity?.atlas != null;

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
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? Padding(
            padding: const EdgeInsets.all(16.0),
            child: Center(
              child: SizedBox(
                height: 40,
                width: 40,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                ),
              ),
            ),
          )
        : InkWell(
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Map3NodeDetailPage(
                      widget._map3infoEntity,
                    ),
                  ));
            },
            child: Padding(
              padding: const EdgeInsets.only(
                top: 16.0,
                right: 16.0,
                left: 16.0,
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: _isShowBorderHint
                      ? Border.all(color: HexColor('#FFFF4C3B'))
                      : null,
                  borderRadius: BorderRadius.circular(6),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey[200],
                      blurRadius: 15.0,
                    ),
                  ],
                ),
                child: InkWell(
                  onTap: () {},
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
                        Expanded(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Spacer(),
                              Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Map3NodeUtil.statusColor(status),
                                  border: Border.all(
                                    color:
                                        Map3NodeUtil.statusBorderColor(status),
                                    width: 1.0,
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

    bool _creatorCanEdit = (_currentEpoch > _creatorCanEditEpoch) &&
        (_currentEpoch < _joinerCanEditEpoch);

    bool _joinerCanEdit = (_currentEpoch > _joinerCanEditEpoch) &&
        (_currentEpoch < _releaseEpoch);

    bool _hasRenew = (_microDelegations?.renewal?.status ?? 0) != 0;

    var _hasReDelegation = widget._map3infoEntity?.atlas != null;

    _isShowBorderHint = !_hasRenew || !_hasReDelegation;

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

//    if (!_hasReDelegation) {
//    _isShowBorderHint = true;
//      _content = _isNodeCreator
//          ? '暂未复投Atlas节点，复投Atlas节点可以获得出块奖励'
//          : '请节点主尽快复抵押至atlas节点以享受出块奖励';
//    }

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
