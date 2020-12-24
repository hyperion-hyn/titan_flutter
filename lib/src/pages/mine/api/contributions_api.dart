import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:titan/src/basic/http/entity.dart';
import 'package:titan/src/components/setting/setting_component.dart';
import 'package:titan/src/components/wallet/wallet_component.dart';
import 'package:titan/src/config/consts.dart';
import 'package:titan/src/pages/contribution/signal_scan/vo/check_in_model.dart';
import 'package:titan/src/pages/mine/model/account_bind_info_entity.dart';
import 'package:titan/src/pages/mine/model/page_response.dart';
import 'package:titan/src/pages/mine/model/user_info.dart';
import 'contributions_http.dart';

class ContributionsApi {

  String getRequestLang() {
    var locale = SettingInheritedModel.of(Keys.rootKey.currentContext)?.languageModel?.locale;
    if (locale == null) {
      return "zh";
    } else if (locale.countryCode == null || locale.countryCode == "") {
      return locale.languageCode;
    } else {
      return "${locale.languageCode}_${locale.countryCode}";
    }
  }

  String get _address =>
      WalletInheritedModel.of(Keys.rootKey.currentContext)?.activatedWallet?.wallet?.getEthAccount()?.address ?? "";

  Future postCheckIn(String type, List<double> coordinates, List<String> optLogIDs,) async {

    var isEmpty = false;
    List<String> newOptLogIDs = [];
    if (type == "confirmPOIV2" && optLogIDs != null) {
      newOptLogIDs = optLogIDs;
      isEmpty = newOptLogIDs.isEmpty;
    }

    Map<String, dynamic> params = {
      'type': type,
      "optLogIDs": optLogIDs,
      "coordinates": coordinates,
      "isEmpty": isEmpty
    };
    //print("[map_rich] checkInV3, params:$params");
    await ContributionsHttpCore.instance.postEntity(
      "/v1/titan/checkin/$_address",
      EntityFactory((json) => json),
      options: RequestOptions(headers: {"Lang": getRequestLang()}),
      params: params,
    );
  }

  Future<CheckInModel> checkInCountV3() async {
    return await ContributionsHttpCore.instance.getEntity(
      "/v1/titan/checkin/$_address/stats",
      EntityFactory((json) => CheckInModel.fromJson(json)),
      options: RequestOptions(headers: {"Lang": getRequestLang()}),
    );
  }

  ///获取checkinhistory
  Future<PageResponse<CheckInModel>> getHistoryListV3(int page) async {
    return await ContributionsHttpCore.instance.getEntity(
      "/v1/titan/checkin/$_address/history",
      EntityFactory<PageResponse<CheckInModel>>((json) {
        var currentPage = json["page"] as int;
        var totalPages = json["totalPages"] as int;
        var dataList = json["history"] as List;
        print("[map_rich] getHistory, dataList:$dataList");

        var historyList = dataList?.map((itemMap) {
              return CheckInModel.fromJson(itemMap);
            })?.toList() ??
            [];
        return PageResponse<CheckInModel>(currentPage, totalPages, historyList);
      }),
      params: {"page": page},
      options: RequestOptions(headers: {"Lang": getRequestLang()}),
    );
  }

  ///打卡关联信息
  Future<AccountBindInfoEntity> getMrInfo() async {
    return await ContributionsHttpCore.instance.getEntity(
      '/v1/titan/mr/$_address/info',
      EntityFactory<AccountBindInfoEntity>((json) => AccountBindInfoEntity.fromJson(json)),
    );
  }

  // 打卡关联-设置成主账号
  Future<ResponseEntity<dynamic>> postMrSetMaster() async {
    return await ContributionsHttpCore.instance.postResponseEntity(
      'v1/titan/mr/$_address/set-master',
      null,
    );
  }

  // 打卡关联-设置成子账号
  Future<ResponseEntity<dynamic>> postMrRequest({
    @required String email,
  }) async {
    return await ContributionsHttpCore.instance.postResponseEntity(
      '/v1/titan/mr/$_address/request ',
      null,
      params: {
        "email": email,
      },
    );
  }

  // 主账号取消某个（或者是多个）子账号的关联
  // 子账号取消与主账号的关联
  Future<ResponseEntity<dynamic>> postMrReset({
    @required List<int> userIDs,
  }) async {
    Map<String, dynamic> params;
    dynamic data;
    if (userIDs?.isNotEmpty ?? false) {
      params = {
        'userIDs': userIDs,
      };
      data = null;
    } else {
      params = {};
      data = {};
    }

    return await ContributionsHttpCore.instance.postResponseEntity(
      '/v1/titan/mr/$_address/reset',
      null,
      data: data,
      params: params,
    );
  }

  // 打卡关联-审核申请
  // approved: 通过
  // refund: 拒绝
  Future<ResponseEntity<dynamic>> postMrOperation({
    @required int id,
    @required String optType,
  }) async {
    return await ContributionsHttpCore.instance.postResponseEntity(
      '/v1/titan/mr/$_address/operation',
      null,
      params: {
        "ID": id,
        "optType": optType,
      },
    );
  }

  // 打卡关联-取消申请
  Future<ResponseEntity<dynamic>> postCancelRequest({
    @required int id,
  }) async {
    return await ContributionsHttpCore.instance.postResponseEntity(
      '/v1/titan/mr/$_address/cancel-request',
      null,
      params: {
        "ID": id,
      },
    );
  }

  // 打卡关联-子账号申请列表
  // 0: 等待审核
  // -1: 已拒绝
  // 1: 已批准
  Future<ResponseEntity<dynamic>> getMrRequestList({
    @required int page,
  }) async {
    return await ContributionsHttpCore.instance.getResponseEntity(
      'v1/titan/mr/$_address/list-request',
      null,
      params: {
        "page": page,
      },
    );
  }

  ///是否有加速量：effective_acceleration > 0 表示有加速量
  Future<UserInfo> getAcceleration() async {
    return await ContributionsHttpCore.instance.getEntity(
        "/v1/titan/account/$_address/acceleration",
        EntityFactory<UserInfo>(
          (json) => UserInfo.fromJson(json),
        ),
        options: RequestOptions(contentType: "application/json"));
  }
}
