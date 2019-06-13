import 'dart:convert';

import 'package:titan/src/data/repository/repository.dart';
import 'package:titan/src/model/history_search.dart';
import 'package:titan/src/model/search_poi.dart';

class SearchInteractor {
  Repository repository;

  SearchInteractor(this.repository);

  Future<HistorySearchEntity> addSearchPoi(SearchPoiEntity poiEntity) {
    var entity = HistorySearchEntity(
        searchText: json.encode(poiEntity.toJson()), time: DateTime.now().millisecondsSinceEpoch, type: poiEntity.runtimeType.toString());
    return repository.searchHistoryDao.insertOrUpdate(entity);
  }

  Future<HistorySearchEntity> addSearchText(String text) async {
    HistorySearchEntity entity = HistorySearchEntity(searchText: text, type: ''.runtimeType.toString(), time: DateTime.now().millisecondsSinceEpoch);
    return repository.searchHistoryDao.insertOrUpdate(entity);
  }

  Future<List<dynamic>> searchHistoryList() async {
    var list = await repository.searchHistoryDao.getList();
    return list.map<dynamic>((item) {
      print(item);
      if (item.type == SearchPoiEntity().runtimeType.toString()) {
        var parsedJson = json.decode(item.searchText);
        var entity = SearchPoiEntity.fromJson(parsedJson);
        entity.isHistory = true;
        return entity;
      }
      return item.searchText;
    }).toList();
  }

  Future<int> deleteAllHistory() {
    return repository.searchHistoryDao.deleteAll();
  }

  Future<List<SearchPoiEntity>> searchPoiByMapbox(String query, String proximity, String language, {String types = 'poi', int limit = 10}) async {
    var ret = await repository.api.searchPoiByMapbox(query, proximity, language, types: types, limit: limit);
    List<dynamic> features = ret['features'];
    List<SearchPoiEntity> pois = [];
    for (var feature in features) {
      var name = feature['text'] ?? 'Unknown Location';
      var loc = [feature['center'][0] as double, feature['center'][1] as double];
      String address;
      if (feature['address'] != null) {
        address = feature['address'];
      } else if (feature['properties']['address'] != null) {
        address = feature['properties']['address'];
      } else if (feature['place_name'] != null) {
        address = feature['place_name'];
      } else {
        address = "${loc[0]},${loc[1]}";
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

      SearchPoiEntity poiEntity = SearchPoiEntity(name: name, address: address, loc: loc, tags: tags, phone: tel);
      pois.add(poiEntity);
    }
    return pois;
  }
}
