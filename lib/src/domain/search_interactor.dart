import 'dart:convert';

import 'package:mapbox_gl/mapbox_gl.dart';
import 'package:titan/src/data/repository/repository.dart';
import 'package:titan/src/model/history_search.dart';
import 'package:titan/src/model/poi.dart';
import 'package:titan/src/model/poi_interface.dart';

class SearchInteractor {
  Repository repository;

  SearchInteractor(this.repository);

  Future<HistorySearchEntity> addHistorySearchPoi(PoiEntity poiEntity) {
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
          if (item.type == PoiEntity().runtimeType.toString()) {
            try {
              var parsedJson = json.decode(item.searchText);
              var entity = PoiEntity.fromJson(parsedJson);
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
    List<PoiEntity> pois = [];
    for (var feature in features) {
      var entity = _featureToEntity(feature);
      if (entity != null) {
        pois.add(entity);
      }
    }
    return pois;
  }

  Future<PoiEntity> reverseGeoSearch(LatLng latLng, String lang, {String types = 'poi', int limit = 1}) async {
    var query = '${latLng.longitude},${latLng.latitude}';
    var proximity = "${latLng.longitude},${latLng.latitude}";
    var ret = await repository.api.searchPoiByMapbox(query, proximity, lang, types: types, limit: limit);
    List<dynamic> features = ret['features'];
    if (features.length > 0) {
      return _featureToEntity(features[0]);
    }
    return null;
  }

  PoiEntity _featureToEntity(dynamic feature) {
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
          address = '$address 中国';
        }
      }
      String tel = feature['properties']['tel'] ?? '';

      return PoiEntity(name: name, address: address, latLng: latLng, tags: tags, phone: tel);
    } catch (err) {
      print(err);
    }
    return null;
  }
}
