import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:titan/src/basic/http/entity.dart';
import 'package:titan/src/pages/red_pocket/api/rp_http.dart';
import 'package:titan/src/pages/red_pocket/entity/rp_release_info.dart';
import 'package:titan/src/pages/red_pocket/entity/rp_staking_info.dart';
import 'package:titan/src/pages/red_pocket/entity/rp_statistics.dart';

class RPApi {
  ///
  Future<RPStatistics> getRPStatistics(String address) async {
    return RPHttpCore.instance.getEntity(
        "/v1/rp/statistics/$address",
        EntityFactory<RPStatistics>(
          (json) => RPStatistics.fromJson(json),
        ),
        options: RequestOptions(contentType: "application/json"));
  }

  Future<List<RPReleaseInfo>> getRPReleaseInfoList(
    String address, {
    int page = 1,
    int size = 20,
  }) async {
    return await RPHttpCore.instance.getEntity(
      '/v1/rp/release/$address',
      EntityFactory<List<RPReleaseInfo>>(
        (data) {
          var listData = data['data'];
          return (listData as List).map((dataItem) => RPReleaseInfo.fromJson(dataItem)).toList();
        },
      ),
      params: {
        'page': page,
        'size': size,
      },
      options: RequestOptions(
        contentType: "application/json",
      ),
    );
  }

  Future<List<RPStakingInfo>> getRPStakingInfoList(
    String address, {
    int page = 1,
    int size = 20,
  }) async {
    return await RPHttpCore.instance.getEntity(
      '/v1/rp/staking/$address',
      EntityFactory<List<RPStakingInfo>>((data) {
        var listData = data['data'];
        return (listData as List).map((dataItem) => RPStakingInfo.fromJson(dataItem)).toList();
      }),
      params: {
        'page': page,
        'size': size,
      },
      options: RequestOptions(
        contentType: "application/json",
      ),
    );
  }
}
