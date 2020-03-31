


import 'package:titan/src/basic/http/entity.dart';
import 'package:titan/src/basic/http/http.dart';
import 'package:titan/src/pages/node/model/node_item.dart';

class NodeApi {

  Future<List<NodeItem>> getContractList() async {
    var contractsList = await HttpCore.instance
        .getEntity("contracts/list", EntityFactory<List<NodeItem>>((data){
          return (data as List).map((dataItem)=>NodeItem.fromJson(dataItem)).toList();
        }));

    return contractsList;
  }

  Future<NodeItem> getContractItem() async {
    var contractsItem = await HttpCore.instance
        .getEntity("contracts/detail/1", EntityFactory<NodeItem>((data){
      return NodeItem.fromJson(data);
    }));

    return contractsItem;
  }

}