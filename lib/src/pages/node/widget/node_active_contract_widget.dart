import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:titan/src/basic/utils/hex_color.dart';
import 'package:titan/src/config/application.dart';
import 'package:titan/src/pages/node/model/contract_node_item.dart';
import 'package:titan/src/routes/routes.dart';

class NodeActiveContractWidget extends StatefulWidget {
  final List<ContractNodeItem> contractList;

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
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
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

  Widget _item(ContractNodeItem item, {int index = 0}) {
    // todo: test_jison_0813
    var width = (MediaQuery.of(context).size.width - 4.0 * 16) / 3.0;
    var nodeName = "大道至简";
    var nodeId = "节点号 ${item.id + 1}";

    return InkWell(
      onTap: () {
        Application.router.navigateTo(context, Routes.map3node_contract_detail_page + "?contractId=${item.id}");
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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Image.asset(
              "res/drawable/map3_node_default_avatar.png",
              //"res/drawable/ic_map3_node_item_contract.png",
              width: 42,
              height: 42,
              fit: BoxFit.cover,
            ),
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
      ),
    );
  }
}
