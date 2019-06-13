import 'package:flutter_test/flutter_test.dart';
import 'package:matcher/matcher.dart';
import 'package:titan/env.dart';
import 'package:titan/src/domain/domain.dart';
import 'package:titan/src/model/search_poi.dart';
import 'package:titan/src/model/update.dart';
import 'package:titan/src/data/api/api.dart';
import 'package:titan/src/data/db/search_history_dao.dart';
import 'package:titan/src/data/repository/repository.dart';

void main() {
  BuildEnvironment.init(flavor: BuildFlavor.official, buildType: BuildType.dev);

  test('update app api', () async {
    Api api = Api();
    var data = await api.update('official', 'zh');
    expect(data, TypeMatcher<UpdateEntity>());
  });

  test('mapbox search api', () async {
    SearchInteractor interactor = SearchInteractor(Repository(api: Api(), searchHistoryDao: SearchHistoryDao()));
    var data = await interactor.searchPoiByMapbox('台湾高雄', '113.316121,23.108317', 'zh');
    expect(data, TypeMatcher<List<SearchPoiEntity>>());
  });
}
