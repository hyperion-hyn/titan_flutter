import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';
import 'package:titan/src/basic/http/entity.dart';
import 'package:titan/src/basic/http/http.dart';
import 'package:titan/src/domain/gaode_model.dart';
import 'package:titan/src/global.dart';
import 'package:titan/src/model/gaode_poi.dart';
import 'package:titan/src/model/update.dart';
import 'package:titan/src/business/contribution/vo/signal_collector.dart';

class Api {
  ///附近可以分享的位置
  Future<GaodeModel> searchByGaode({
    @required double lat,
    @required double lon,
    int type,
    double radius = 2000,
    int page = 1,
    CancelToken cancelToken,
  }) async {
    return await HttpCore.instance.getEntity(
      'map/around',
      EntityFactory<GaodeModel>((json) {
        var data = (json['data'] as List).map((map) {
          return GaodePoi.fromJson(map);
        }).toList();
        var gaodeModel = GaodeModel(page: json['page'], totalPage: json['total_pages'], data: data);
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
  Future<GaodeModel> searchNearByHyn({
    @required double lat,
    @required double lon,
    String type,
    double radius = 2000,
    int page = 1,
    CancelToken cancelToken,
  }) async {
    var json = await HttpCore.instance.get(
      'titan-map/api/place/nearbysearch/json',
      params: {"location": "$lat,$lon", "radius": radius, "type": type, "language": appLocale.languageCode},
      options: RequestOptions(cancelToken: cancelToken),
    );

    var data = (json['results'] as List).map((map) {
      return GaodePoi.fromGJson(map);
    }).toList();

    var gaodeModel = GaodeModel(page: 1, totalPage: 1, data: data);
    return gaodeModel;
  }

  Future<UpdateEntity> update(String channel, String lang, String platform) async {
    var data = await HttpCore.instance.getEntity(
        'api/v1/titan/app/update', EntityFactory<UpdateEntity>((json) => UpdateEntity.fromJson(json)),
        params: {
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
  Future signalCollector(String platform, String address, SignalCollector signalCollector) async {
     await HttpCore.instance.post("map-collector/signal/collector",
        params: signalCollector.toJson(),
        options: RequestOptions(headers: {"platform": platform, "UUID": address}, contentType: "application/json"));
  }
}
