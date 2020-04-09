

import 'package:titan/src/pages/node/model/contract_node_item.dart';
import 'package:titan/src/pages/node/model/node_head_entity.dart';

class NodePageEntityVo{
  NodeHeadEntity nodeHeadEntity;
  List<ContractNodeItem> contractNodeList;
  NodePageEntityVo(this.nodeHeadEntity,this.contractNodeList);
}