import 'package:meta/meta.dart';
import 'package:titan/src/model/update.dart';
import 'package:titan/src/resource/api/api.dart';

class Repository {
  Api _api;

  Repository({@required Api api}) : _api = api;

  Future<UpdateEntity> update(String channel, String lang) {
    return _api.update(channel, lang);
  }
}
