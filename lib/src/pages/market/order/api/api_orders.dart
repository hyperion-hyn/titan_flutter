import 'package:titan/src/basic/http/entity.dart';
import 'package:titan/src/basic/http/http.dart';
import 'package:titan/src/pages/market/order/entity/order_entity.dart';

class OrdersApi {
  Future<List<OrderEntity>> getOrderList(
    String type,
    int page,
  ) async {
    List dataList = await HttpCore.instance.get(
      "wp-json/wp/v2/orders",
      params: {"page": page, "type": type},
    ) as List;

    return dataList.map((json) => OrderEntity.fromJson(json)).toList();
  }

  Future<OrderEntity> getOrderDetail(int id) async {
    var data = await HttpCore.instance.get(
      "wp-json/wp/v2/orders/$id",
    ) as Map;

    return OrderEntity.fromJson(data);
  }

  Future<ResponseEntity<String>> cancelOrder(String orderId) async {
    var data = await HttpCore.instance.post(
      "wp-json/wp/v2/orders/$orderId",
      params: {'action': 'cancel'},
    ) as Map;

    var responseEntity = ResponseEntity<String>.fromJson(data,
        factory: EntityFactory((json) => json));

    return responseEntity;
  }
}
