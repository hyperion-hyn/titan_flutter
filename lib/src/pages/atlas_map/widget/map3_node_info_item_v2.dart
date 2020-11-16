import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:titan/generated/l10n.dart';
import 'package:titan/src/basic/utils/hex_color.dart';
import 'package:titan/src/components/atlas/atlas_component.dart';
import 'package:titan/src/components/wallet/wallet_component.dart';
import 'package:titan/src/config/application.dart';
import 'package:titan/src/config/consts.dart';
import 'package:titan/src/pages/atlas_map/entity/enum_atlas_type.dart';
import 'package:titan/src/pages/atlas_map/entity/map3_info_entity.dart';
import 'package:titan/src/pages/atlas_map/map3/map3_node_collect_reward_page.dart';
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

class Map3NodeInfoItemV2 extends StatefulWidget {
  final Map3InfoEntity _map3infoEntity;

  Map3NodeInfoItemV2(this._map3infoEntity);

  @override
  State<StatefulWidget> createState() {
    return _Map3NodeInfoItemV2State();
  }
}

class _Map3NodeInfoItemV2State extends State<Map3NodeInfoItemV2> {
  var nodeName = '';
  var nodeId = '';
  var status;

  var stateDescText = '';
  var statusColor = HexColor('#999999');
  var statusBorderColor = HexColor('#F2F2F2');

  Microdelegations _microDelegations;
  var hasReDelegation;
  var isShowHint;

  final _client = WalletUtil.getWeb3Client(true);

  @override
  void initState() {
    super.initState();
    _initData();
  }

  _initData() async {
    nodeName = widget._map3infoEntity?.name ?? '';
    nodeId = widget._map3infoEntity?.nodeId ?? '';
    status = Map3InfoStatus.values[widget._map3infoEntity?.status ?? 0];
    stateDescText = Map3NodeUtil.stateDescText(status);
    statusColor = Map3NodeUtil.statusColor(status);
    statusBorderColor = Map3NodeUtil.statusBorderColor(status);
    hasReDelegation = widget._map3infoEntity?.atlas != null;

    isShowHint = false;

    var activatedWallet =
        WalletInheritedModel.of(Keys.rootKey.currentContext).activatedWallet;
    var wallet = activatedWallet?.wallet;

    var map3Address = EthereumAddress.fromHex(
      widget._map3infoEntity?.address ?? '',
    );
    var walletAddress = EthereumAddress.fromHex(
      wallet?.getAtlasAccount()?.address ?? '',
    );

    _microDelegations = await _client.getMap3NodeDelegation(
      map3Address,
      walletAddress,
    );
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
    return Padding(
      padding: const EdgeInsets.only(
        top: 16.0,
        right: 16.0,
        left: 16.0,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: isShowHint ? Border.all(color: HexColor('#FFFF4C3B')) : null,
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
                Container(
                  width: 8,
                  height: 8,
                  //color: Colors.red,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: statusColor,
                    border: Border.all(
                      color: statusBorderColor,
                      width: 1.0,
                    ),
                  ),
                ),
                SizedBox(
                  width: 8,
                ),
                isShowHint
                    ? Text('')
                    : Text(
                        stateDescText,
                        style: TextStyle(fontSize: 13, color: statusColor),
                      )
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _reminderText() {
    var isJoiner = widget._map3infoEntity.isJoiner;
    var isCreator = widget._map3infoEntity.isCreator();
    var currentEpoch = AtlasInheritedModel.of(context).currentEpoch;
    var preEditRemainEpochIfCreator = '';

    if (!hasReDelegation) {
      return '暂未复投Atlas节点，复投Atlas节点可以获得出块奖励';
    }
  }
}
