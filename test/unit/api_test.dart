import 'package:flutter_test/flutter_test.dart';
import 'package:matcher/matcher.dart';
import 'package:titan/src/model/update.dart';
import 'package:titan/src/resource/api/api.dart';

void main() {
  test('update app api', () async {
    Api api = Api();
    var data = await api.update('official', 'zh');
    expect(data, TypeMatcher<UpdateEntity>());
  });
}
