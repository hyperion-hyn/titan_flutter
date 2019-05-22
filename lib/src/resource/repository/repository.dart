import 'package:meta/meta.dart';
import 'package:titan/src/resource/api/api.dart';

class Repository {
  Api _api;

  Repository({@required Api api}) : _api = api;
}
