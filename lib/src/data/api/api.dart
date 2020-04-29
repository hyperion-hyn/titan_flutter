import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';
import 'package:titan/src/basic/http/entity.dart';
import 'package:titan/src/basic/http/http.dart';
import 'package:titan/src/pages/global_data/model/map3_node_vo.dart';
import 'package:titan/src/pages/global_data/model/signal_daily_vo.dart';
import 'package:titan/src/pages/global_data/model/signal_total_vo.dart';
import 'package:titan/src/pages/global_data/model/signal_weekly_vo.dart';
import 'package:titan/src/pages/me/api/map_rich_http.dart';
import '../../domain/model/photo_poi_list_model.dart';
import 'package:titan/src/global.dart';
import '../entity/poi/photo_simple_poi.dart';
import '../entity/update.dart';
import 'package:titan/src/pages/contribution/signal_scan/vo/signal_collector.dart';

class Api {
  ///附近可以分享的位置
  Future<PhotoPoiListResultModel> searchByGaode({
    @required double lat,
    @required double lon,
    int type,
    double radius = 2000,
    int page = 1,
    CancelToken cancelToken,
  }) async {
    return await HttpCore.instance.getEntity(
      'map/around',
      EntityFactory<PhotoPoiListResultModel>((json) {
        var data = (json['data'] as List).map((map) {
          return SimplePoiWithPhoto.fromJson(map);
        }).toList();
        var gaodeModel = PhotoPoiListResultModel(page: json['page'], totalPage: json['total_pages'], data: data);
        return gaodeModel;
      }),
      params: {
        "lat": lat,
        "lon": lon,
        "radius": radius,
        "type": type,
        "page": page,
      },
      options: RequestOptions(cancelToken: cancelToken),
    );
  }

  ///附近可以分享的位置
  Future<PhotoPoiListResultModel> searchNearByHyn({
    @required double lat,
    @required double lon,
    String type,
    double radius = 2000,
    int page = 1,
    String language,
    CancelToken cancelToken,
  }) async {
    var json = await HttpCore.instance.get(
      'titan-map/api/place/nearbysearch/json',
      params: {"location": "$lat,$lon", "radius": radius, "type": type, "language": language},
      options: RequestOptions(cancelToken: cancelToken),
    );

    var data = (json['results'] as List).map((map) {
      return SimplePoiWithPhoto.fromGJson(map);
    }).toList();

    var gaodeModel = PhotoPoiListResultModel(page: 1, totalPage: 1, data: data);
    return gaodeModel;
  }

  Future<UpdateEntity> update(String channel, String lang, String platform) async {
    var data = await MapRichHttpCore.instance
        .getEntity('apps/update', EntityFactory<UpdateEntity>((json) => UpdateEntity.fromJson(json)), params: {
      'channel': channel,
      'lang': lang,
      "platform": platform,
    });

    return data;
  }

  Future<Map<String, dynamic>> searchPoiByMapbox(String query, String proximity, String language,
      {String types = 'poi', int limit = 10}) async {
    var data = await HttpCore.instance.get('geocoding/v1/hyperion.places/$query.json',
        params: {'proximity': proximity, 'language': language, 'types': types, 'limit': limit});
    return data;
  }

  Future<Map<String, dynamic>> searchPoiByTitan(String keyword, String lon, String lat,
      {String language = "zh-Hans", int radius = 500}) async {
    var data = await HttpCore.instance.get('map-collector/poi/search',
//        params: {'lon': 113.322201, 'lat': 23.121072, 'language': 'zh-Hans', 'keyword': "高地", 'radius': "500"});
        params: {'lon': lon, 'lat': lat, 'language': language, 'keyword': keyword, 'radius': radius});
    return data;
  }

  Future<Map<String, dynamic>> getReEncryptPubKey() async {
    var data = await HttpCore.instance.get('re/');
    return data;
  }

  Future<dynamic> storeCls(
      {@required String commitment, @required String ciphertext, @required int expiracy, @required String kid}) async {
    var data = await HttpCore.instance.post('re/cls', params: {
      'commitment': commitment,
      'ciphertext': ciphertext,
      'expiracy': expiracy,
      'kid': kid,
    });
    return data;
  }

  Future<dynamic> requestDianping(double lat, double lon) async {
    return HttpCore.instance.post('index/api/module',
        params: {
          'moduleInfoList[0][version]': 0,
          'moduleInfoList[0][moduleName]': 'cnxh',
          'moduleInfoList[0][config][bord]': true,
          'moduleInfoList[0][config][hideWelfare]': false,
          'moduleInfoList[0][config][adId]': 'm_dacu_banner',
          'moduleInfoList[0][config][categoryType]': 'standard',
          'moduleInfoList[0][config][mainwelfare_utm]': 'ulink_mainwelfare',
          'moduleInfoList[0][query][startNum]': 1,
          'moduleInfoList[0][lat]': lat,
          'moduleInfoList[0][lng]': lon,
          'originUrl': 'https://m.dianping.com/',
          'pageEnName': 'index',
        },
        options: RequestOptions(baseUrl: 'https://m.dianping.com/', headers: {
          'User-Agent':
          'Mozilla/5.0 (Linux; Android 8.0; Pixel 2 Build/OPD3.170816.012) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/77.0.3865.90 Mobile Safari/537.36',
          'Referer': 'https://m.dianping.com/',
        }));
  }

  Future<Map<String, dynamic>> getCls(
      {@required String commitment, @required String pubkey, @required String kid}) async {
    var data = await HttpCore.instance.get('re/cls', params: {
      'commitment': commitment,
      'pubkey': pubkey,
      'kid': kid,
    });
    return data;
  }

  ///collect signal
  Future<bool> signalCollector(String platform, String address, SignalCollector signalCollector) async {
    try {
      var res = await HttpCore.instance.post("map-collector/signal/collector",
          params: signalCollector.toJson(),
          options: RequestOptions(headers: {"platform": platform, "UUID": address}, contentType: "application/json"));
      var responseEntity = ResponseEntity<String>.fromJson(res, factory: EntityFactory((json) => json));
      if (responseEntity.code == 0) {
        return true;
      } else {
        return false;
      }
    } catch (_) {
      logger.e(_);
      return false;
    }
  }

  /// signal total
  Future<SignalTotalVo> getSignalTotal() async {
    var model = await HttpCore.instance.getEntity(
      'map-collector/signal/count',
      EntityFactory<SignalTotalVo>((json) => SignalTotalVo.fromJson(json)),
    );

    //print('[api] getSignalTotal, total:${model.blueToothTotal}');
    return model;
  }

  /// signal daily
  Future<List<SignalDailyVo>> getSignalDaily({String language = "zh-Hans"}) async {
    var list = await HttpCore.instance.getEntity(
        'map-collector/signal/count/daily',
        EntityFactory<List<SignalDailyVo>>((json) {
          return (json as List).map((levelInfoJson) {
            return SignalDailyVo.fromJson(levelInfoJson);
          }).toList();
        }), options: RequestOptions(headers: {"Lang": language}));

    //print('[api] getSignalDaily, length:${list.length}');

    return list;
  }

  Future<List<Signal>> getPoiDaily({String language = "zh-Hans"}) async {
    var list = await HttpCore.instance.getEntity(
        'map-collector/poi/count/daily',
        EntityFactory<List<Signal>>((json) {
          return (json as List).map((levelInfoJson) {
            return Signal.fromJson(levelInfoJson);
          }).toList();
        }), options: RequestOptions(headers: {"Lang": language})
    );

    //print('[api] getSignalDaily, length:${list.length}');

    return list;
  }

  /// signal weekly
  Future<List<SignalWeeklyVo>> getSignalWeekly({String language = "zh-Hans"}) async {
    var list = await HttpCore.instance.getEntity(
        'map-collector/signal/count/weekly',
        EntityFactory<List<SignalWeeklyVo>>((json) {
          return (json as List).map((levelInfoJson) {
            return SignalWeeklyVo.fromJson(levelInfoJson);
          }).toList();
        }), options: RequestOptions(headers: {"Lang": language}));

    //print('[api] getSignalWeekly, length:${list.length}');

    return list;
  }

  //https://api.hyn.space/api/v1/dashboard
  /// node
  Future<Map3NodeVo> getMap3NodeData() async {
    var model = await HttpCore.instance.getEntity(
      'api/v1/dashboard',
      EntityFactory<Map3NodeVo>((json) => Map3NodeVo.fromJson(json)),
    );

    print('[api] getMap3NodeData, length:${model.tiles.length}');

    return model;
  }

}
