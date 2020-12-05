import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:titan/generated/l10n.dart';
import 'package:titan/src/basic/utils/hex_color.dart';
import 'package:titan/src/config/application.dart';
import 'package:titan/src/pages/atlas_map/entity/enum_atlas_type.dart';
import 'package:titan/src/pages/atlas_map/entity/map3_info_entity.dart';
import 'package:titan/src/pages/atlas_map/map3/map3_node_public_widget.dart';
import 'package:titan/src/pages/node/model/map3_node_util.dart';
import 'package:titan/src/routes/fluro_convert_utils.dart';
import 'package:titan/src/routes/routes.dart';
import 'package:titan/src/widget/wallet_widget.dart';

class NodeActiveContractWidget extends StatefulWidget {
  final List<Map3InfoEntity> contractList;

  NodeActiveContractWidget({this.contractList});

  @override
  State<StatefulWidget> createState() {
    return _NodeActiveContractState();
  }
}

class _NodeActiveContractState extends State<NodeActiveContractWidget> {
  @override
  void initState() {
    super.initState();
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
    return activeContractWidget();
  }

  Widget activeContractWidget() {
    return Container(
      color: Colors.white,
      height: 168,
      child: Column(
        children: <Widget>[
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
              separatorBuilder: (context, index) {
                return SizedBox(
                  width: 16,
                );
              },
              itemBuilder: (context, index) {
                var i = index;
                var item = widget.contractList[i];
                return _item(item, index: index);
              },
              itemCount: widget.contractList.length > 3 ? 3 : widget.contractList.length,
              scrollDirection: Axis.horizontal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _item(Map3InfoEntity infoEntity, {int index = 0}) {

    var width = (MediaQuery.of(context).size.width - 4.0 * 16) / 3.0;
    var nodeName = infoEntity.name;
    var nodeId = "${S.of(context).node_num}: ${infoEntity.nodeId}";

    //print("[object] item.nodeId:${item.nodeId}");

    var status = Map3InfoStatus.values[infoEntity?.status ?? 0];
    var statusColor = Map3NodeUtil.statusColor(status);
    var statusBorderColor = Map3NodeUtil.statusBorderColor(status);
    
    return InkWell(
      onTap: () {

        Application.router.navigateTo(
          context,
          Routes.map3node_contract_detail_page + '?info=${FluroConvertUtils.object2string(infoEntity.toJson())}',
        );

       },
      child: Container(
        padding: EdgeInsets.only(top: 4, bottom: 4.0),
        width: width,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 8.0,
            ),
          ],
        ),
        child: Stack(
          alignment: Alignment.center,
          children: <Widget>[
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                iconMap3Widget(infoEntity),
                SizedBox(
                  height: 12,
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 5.0, right: 5),
                  child: Text(nodeName,
                      style: TextStyle(fontSize: 12, color: HexColor("#333333"), fontWeight: FontWeight.w600)),
                ),
                SizedBox(
                  height: 4,
                ),
                Text(nodeId, style: TextStyle(fontSize: 10, color: HexColor("#9B9B9B"))),
              ],
            ),
            Positioned(
              right: 12,
              top: 12,
              child: Container(
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
            )
          ],
        ),
      ),
    );
  }
}
