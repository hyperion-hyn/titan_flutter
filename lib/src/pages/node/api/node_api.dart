
import 'package:dio/dio.dart';
import 'package:titan/src/basic/http/http.dart';
import 'package:titan/src/basic/http/entity.dart';
import 'package:titan/src/pages/node/model/contract_detail_item.dart';
import 'package:titan/src/pages/node/model/contract_node_item.dart';

import 'package:titan/src/basic/http/entity.dart';
import 'package:titan/src/basic/http/http.dart';
import 'package:titan/src/pages/node/model/node_item.dart';

class NodeApi {

 
  Future<List<ContractNodeItem>> getMyCreateNodeContract() async {
    return await HttpCore.instance
        .getEntity("delegations/my-create",
        EntityFactory<List<ContractNodeItem>>((list) => (list as List).map((item) => ContractNodeItem.fromJson(item)).toList()),
        options: RequestOptions(headers: {"Address": "jifijfkeo904o3jfi0joitqjjfli"})
    );
  }

  Future<List<ContractNodeItem>> getMyJoinNodeContract() async {
    return await HttpCore.instance
        .getEntity("delegations/my-join",
      EntityFactory<List<ContractNodeItem>>((list) => (list as List).map((item) => ContractNodeItem.fromJson(item)).toList()),
        options: RequestOptions(headers: {"Address": "kkkkkeo904o3jfi0joitqjjfli"})
    );
  }

  Future<ContractDetailItem> getContractDetail(int contractId) async {
    return await HttpCore.instance
        .getEntity("delegations/instance/$contractId",
        EntityFactory<ContractDetailItem>((data) =>
            ContractDetailItem.fromJson(data)),
        options: RequestOptions(
            headers: {"Address": "kkkkkeo904o3jfi0joitqjjfli"})
    );
  }
 
  Future<List<NodeItem>> getContractList() async {
    var contractsList = await HttpCore.instance
        .getEntity("contracts/list", EntityFactory<List<NodeItem>>((data){
          return (data as List).map((dataItem)=>NodeItem.fromJson(dataItem)).toList();
        }));

    return contractsList;
  }

  Future<ContractNodeItem> getContractItem() async {
    var nodeItem = await HttpCore.instance
        .getEntity("contracts/detail/1", EntityFactory<NodeItem>((data){
      return NodeItem.fromJson(data);
    }));

    return ContractNodeItem.onlyNodeItem(nodeItem);
  }

  Future<ContractNodeItem> getContractInstanceItem() async {
    var contractsItem = await HttpCore.instance
        .getEntity("instances/detail/8", EntityFactory<ContractNodeItem>((data){
      return ContractNodeItem.fromJson(data);
    }));

    return contractsItem;
   }

}