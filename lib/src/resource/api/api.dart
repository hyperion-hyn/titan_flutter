import 'package:titan/src/basic/http/entity.dart';
import 'package:titan/src/basic/http/http.dart';
import 'package:titan/src/model/update.dart';

class Api {
  Future<UpdateEntity> update(String channel, String lang) async {
    var data = await HttpCore.instance.getEntity('api/v1/titan/app/update', EntityFactory<UpdateEntity>(
        (json) => UpdateEntity.fromJson(json)
    ));

    return data;
  }
}
