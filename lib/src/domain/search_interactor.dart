import 'dart:convert';

import 'package:mapbox_gl/mapbox_gl.dart';
import 'package:titan/src/data/repository/repository.dart';
import '../data/entity/history_search.dart';
import '../data/entity/poi/mapbox_poi.dart';
import '../data/entity/poi/poi_interface.dart';
import 'package:titan/generated/i18n.dart';
import 'package:titan/src/config/consts.dart';

import 'package:titan/src/data/entity/poi/user_contribution_poi.dart';

class SearchInteractor {
  Repository repository;

  SearchInteractor(this.repository);

  Future<HistorySearchEntity> addHistorySearchPoi(MapBoxPoi poiEntity) {
    var entity = HistorySearchEntity(
        searchText: json.encode(poiEntity.toJson()),
        time: DateTime.now().millisecondsSinceEpoch,
        type: poiEntity.runtimeType.toString());
    return repository.searchHistoryDao.insertOrUpdate(entity);
  }

  Future<HistorySearchEntity> addHistorySearchPoiByTitan(UserContributionPoi poiEntity) {
    var entity = HistorySearchEntity(
        searchText: json.encode(poiEntity.toJson()),
        time: DateTime.now().millisecondsSinceEpoch,
        type: poiEntity.runtimeType.toString());
    return repository.searchHistoryDao.insertOrUpdate(entity);
  }

  Future<HistorySearchEntity> addHistorySearchText(String text) async {
    HistorySearchEntity entity = HistorySearchEntity(
        searchText: text, type: ''.runtimeType.toString(), time: DateTime.now().millisecondsSinceEpoch);
    return repository.searchHistoryDao.insertOrUpdate(entity);
  }

  Future<List<dynamic>> searchHistoryList() async {
    var list = await repository.searchHistoryDao.getList();
    return list
        .map<dynamic>((item) {
          if (item.type == MapBoxPoi().runtimeType.toString()) {
            try {
              var parsedJson = json.decode(item.searchText);
              var entity = MapBoxPoi.fromJson(parsedJson);
              entity.isHistory = true;
              return entity;
            } catch (err) {
              print(err);
              return null;
            }
          } else if (item.type == UserContributionPoi.empty().runtimeType.toString()) {
            try {
              var parsedJson = json.decode(item.searchText);
              var entity = UserContributionPoi.fromJson(parsedJson);
              entity.isHistory = true;
              return entity;
            } catch (err) {
              print(err);
              return null;
            }
          }
          return item.searchText;
        })
        .where((i) => i != null)
        .toList();
  }

  Future<int> deleteAllHistory() {
    return repository.searchHistoryDao.deleteAll();
  }

  Future<List<IPoi>> searchPoiByMapbox(String query, LatLng center, String language,
      {String types = 'poi', int limit = 10}) async {
    var proximity = "${center.longitude},${center.latitude}";
    var ret = await repository.api.searchPoiByMapbox(query, proximity, language, types: types, limit: limit);
    List<dynamic> features = ret['features'];
    List<MapBoxPoi> pois = [];
    for (var feature in features) {
      var entity = _featureToEntity(feature);
      if (entity != null) {
        pois.add(entity);
      }
    }
    return pois;
  }

  Future<List<IPoi>> searchPoiByTitan(String keyword, LatLng center, String language, {int radius = 2000}) async {
//    var language = (appLocale ?? defaultLocale).languageCode;
    if (language.startsWith('zh')) language = "zh-Hans";
    var ret = await repository.api.searchPoiByTitan(keyword, center.longitude.toString(), center.latitude.toString(),
        language: language, radius: radius);
    List<dynamic> features = ret['data'];
    List<UserContributionPoi> pois = [];
    for (var feature in features) {
      var entity = UserContributionPoi.fromJson(feature);
      if (entity != null) {
        pois.add(entity);
      }
    }
    return pois;
  }

  Future<MapBoxPoi> reverseGeoSearch(LatLng latLng, String lang, {String types = 'poi', int limit = 1}) async {
    var query = '${latLng.longitude},${latLng.latitude}';
    var proximity = "${latLng.longitude},${latLng.latitude}";
    var ret = await repository.api.searchPoiByMapbox(query, proximity, lang, types: types, limit: limit);
    List<dynamic> features = ret['features'];
    if (features.length > 0) {
      return _featureToEntity(features[0]);
    }
    return null;
  }

  MapBoxPoi _featureToEntity(dynamic feature) {
    try {
      var name = feature['text'] ?? 'Unknown Location';
      var latLng = LatLng(feature['center'][1] as double, feature['center'][0] as double);
      var loc = [feature['center'][0] as double, feature['center'][1] as double];
      String address;
      if (feature['address'] != null) {
        address = feature['address'];
      } else if (feature['properties']['address'] != null) {
        address = feature['properties']['address'];
      } else if (feature['place_name'] != null) {
        address = feature['place_name'];
      } else {
        address = "${latLng.latitude},${latLng.longitude}";
      }
      String tags = feature['properties']['category'] ?? '';
      if (feature['context'] != null) {
        var contexts = feature['context'];
        if (contexts is List<dynamic> && contexts.length > 0 && contexts.last['id'] == 'country.6316601538527180') {
          // 台湾id
          address = '$address '+ S.of(Keys.rootKey.currentContext).china;
        }
      }
      String tel = feature['properties']['tel'] ?? '';

      return MapBoxPoi(name: name, address: address, latLng: latLng, tags: tags, phone: tel);
    } catch (err) {
      print(err);
    }
    return null;
  }
}
