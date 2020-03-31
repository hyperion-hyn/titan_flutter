
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:titan/src/basic/http/http.dart';
import 'package:titan/src/basic/http/entity.dart';
import 'package:titan/src/pages/node/model/contract_delegator_item.dart';
import 'package:titan/src/pages/node/model/contract_detail_item.dart';
import 'package:titan/src/pages/node/model/contract_node_item.dart';

import 'package:titan/src/pages/node/model/node_head_entity.dart';
import 'package:titan/src/pages/node/model/node_item.dart';
import 'package:titan/src/pages/node/model/node_page_entity_vo.dart';
import 'package:titan/src/pages/node/model/start_join_instance.dart';

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

  Future<ContractDetailItem> getContractDetail(int contractNodeItemId) async {
    return await HttpCore.instance
        .getEntity("delegations/instance/$contractNodeItemId",
        EntityFactory<ContractDetailItem>((data) =>
            ContractDetailItem.fromJson(data)),
        options: RequestOptions(
            headers: {"Address": "kkkkkeo904o3jfi0joitqjjfli"})
    );
  }

  Future<List<ContractDelegatorItem>> getContractDelegator(int contractNodeItemId) async {
    return await HttpCore.instance
        .getEntity("delegations/instance/$contractNodeItemId/delegators",
        EntityFactory<List<ContractDelegatorItem>>((list) => (list as List).map((item) => ContractDelegatorItem.fromJson(item)).toList()),
        options: RequestOptions(headers: {"Address": "kkkkkeo904o3jfi0joitqjjfli"})
    );
  }

  Future<List<NodeItem>> getContractList(int page) async {
    var contractsList = await HttpCore.instance
        .getEntity("contracts/list?page=$page", EntityFactory<List<NodeItem>>((data){
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

  Future<String> startContractInstance(StartJoinInstance startJoinInstance) async {
    String postData = json.encode(startJoinInstance.toJson());
    var data = await HttpCore.instance
        .post("contracts/create/1", data: postData,
        options: RequestOptions(contentType: "application/json"));
    return data['msg'];
  }

  Future<String> joinContractInstance(StartJoinInstance startJoinInstance) async {
    String postData = json.encode(startJoinInstance.toJson());
    var data = await HttpCore.instance
        .post("instances/delegate/8", data: postData,
        options: RequestOptions(contentType: "application/json"));
    return data['msg'];
  }

  Future<NodePageEntityVo> getNodePageEntityVo() async {
    var nodeHeadEntity = await HttpCore.instance
        .getEntity("nodes/intro", EntityFactory<NodeHeadEntity>((data){
      return NodeHeadEntity.fromJson(data);
    }));

    var pendingList = await getContractPendingList(0);

    return NodePageEntityVo(nodeHeadEntity, pendingList);
  }

  Future<List<ContractNodeItem>> getContractPendingList(int page) async {
    var contractsList = await HttpCore.instance
        .getEntity("instances/pending?page=$page", EntityFactory<List<ContractNodeItem>>((data){
      return (data as List).map((dataItem)=>ContractNodeItem.fromJson(dataItem)).toList();
    }));

    return contractsList;
  }


}