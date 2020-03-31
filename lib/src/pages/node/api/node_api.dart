
import 'package:dio/dio.dart';
import 'package:titan/src/basic/http/http.dart';
import 'package:titan/src/basic/http/entity.dart';
import 'package:titan/src/pages/node/model/contract_detail_item.dart';
import 'package:titan/src/pages/node/model/contract_node_item.dart';

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
        EntityFactory<ContractDetailItem>((data) => ContractDetailItem.fromJson(data)),
        options: RequestOptions(headers: {"Address": "kkkkkeo904o3jfi0joitqjjfli"})
    );
  }

}