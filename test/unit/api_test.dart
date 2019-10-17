import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mapbox_gl/mapbox_gl.dart';
import 'package:matcher/matcher.dart';
import 'package:titan/env.dart';
import 'package:titan/src/domain/domain.dart';
import 'package:titan/src/model/poi.dart';
import 'package:titan/src/model/update.dart';
import 'package:titan/src/data/api/api.dart';
import 'package:titan/src/data/db/search_history_dao.dart';
import 'package:titan/src/data/repository/repository.dart';

void main() {
  BuildEnvironment.init(channel: BuildChannel.OFFICIAL, buildType: BuildType.DEV);

  test('update app api', () async {
    Api api = Api();
    var data = await api.update('official', 'zh', Platform.isAndroid ? "android" : "ios");
    expect(data, TypeMatcher<UpdateEntity>());
  });

  test('mapbox search api', () async {
    SearchInteractor interactor = SearchInteractor(Repository(api: Api(), searchHistoryDao: SearchHistoryDao()));
    var data = await interactor.searchPoiByMapbox('台湾高雄', LatLng(23.108317, 113.316121), 'zh');
    expect(data, TypeMatcher<List<PoiEntity>>());
  });

  test('mapbox reverse geo search', () async {
    SearchInteractor interactor = SearchInteractor(Repository(api: Api(), searchHistoryDao: SearchHistoryDao()));
    var entity = await interactor.reverseGeoSearch(LatLng(23.108317, 113.316121), 'zh');
    expect(entity, TypeMatcher<PoiEntity>());
  });
}
