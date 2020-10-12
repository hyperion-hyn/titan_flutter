import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_pickers/Media.dart';
import 'package:titan/src/basic/http/entity.dart';
import 'package:titan/src/components/setting/setting_component.dart';
import 'package:titan/src/components/wallet/wallet_component.dart';
import 'package:titan/src/config/application.dart';
import 'package:titan/src/config/consts.dart';
import 'package:titan/src/pages/atlas_map/api/atlas_http.dart';
import 'package:titan/src/pages/atlas_map/entity/atlas_info_entity.dart';
import 'package:titan/src/pages/atlas_map/entity/bls_key_sign_entity.dart';
import 'package:titan/src/pages/atlas_map/entity/committee_info_entity.dart';
import 'package:titan/src/pages/atlas_map/entity/create_atlas_entity.dart';
import 'package:titan/src/pages/atlas_map/entity/create_map3_entity.dart';
import 'package:titan/src/pages/atlas_map/entity/map3_info_entity.dart';
import 'package:titan/src/pages/atlas_map/entity/map3_introduce_entity.dart';
import 'package:titan/src/pages/atlas_map/entity/map3_staking_log_entity.dart';
import 'package:titan/src/pages/atlas_map/entity/pledge_atlas_entity.dart';
import 'package:titan/src/pages/atlas_map/entity/pledge_map3_entity.dart';
import 'package:titan/src/pages/atlas_map/entity/test_post_entity.dart';
import 'package:titan/src/pages/atlas_map/entity/tx_hash_entity.dart';
import 'package:titan/src/pages/atlas_map/entity/user_map3_entity.dart';
import 'package:titan/src/pages/atlas_map/entity/user_reward_entity.dart';
import 'package:titan/src/routes/fluro_convert_utils.dart';
import 'package:titan/src/routes/routes.dart';
import 'package:titan/src/utils/log_util.dart';

import '../../../../config.dart';

class AtlasApi {
  static goToAtlasMap3HelpPage(BuildContext context) {
    String webUrl = FluroConvertUtils.fluroCnParamsEncode(
        "http://ec2-46-137-195-189.ap-southeast-1.compute.amazonaws.com/helpPage");
    String webTitle = FluroConvertUtils.fluroCnParamsEncode("帮助页面");
    Application.router.navigateTo(context,
        Routes.toolspage_webview_page + '?initUrl=$webUrl&title=$webTitle');
  }

  Map<String, dynamic> getOptionHeader(
      {hasLang = false, hasAddress = false, hasSign = false}) {
    if (!hasLang && !hasAddress && !hasSign) {
      return null;
    }
    Map<String, dynamic> headMap = Map();

    headMap.putIfAbsent("appSource", () => Config.APP_SOURCE);

    var activeWalletVo =
        WalletInheritedModel.of(Keys.rootKey.currentContext).activatedWallet;
    if (hasAddress && activeWalletVo != null) {
      headMap.putIfAbsent(
          "Address", () => activeWalletVo.wallet.getEthAccount().address);
    }

    if (hasLang) {
      var language =
          SettingInheritedModel.of(Keys.rootKey.currentContext).netLanguageCode;
      headMap.putIfAbsent("Lang", () => language);
    }

    if (hasSign) {
      headMap.putIfAbsent("Sign", () => "Sign");
    }

    return headMap;
  }

  //测试post签名
  Future<TestPostEntity> postTest(TestPostEntity entity) async {
    return AtlasHttpCore.instance.postEntity(
        "/v1/test",
        EntityFactory<TestPostEntity>(
          (json) => TestPostEntity.fromJson(json),
        ),
        data: entity.toJson(),
        options: RequestOptions(
          headers: getOptionHeader(hasSign: true),
          contentType: "application/json",
        ));
  }

  // 创建Atlas节点
  Future<TxHashEntity> postCreateAtlasNode(CreateAtlasEntity entity) async {
    return AtlasHttpCore.instance.postEntity(
        "/v1/atlas/create",
        EntityFactory<TxHashEntity>(
          (json) => TxHashEntity.fromJson(json),
        ),
        data: entity.toJson(),
        options: RequestOptions(contentType: "application/json"));
  }

  // 编辑Atlas节点
  Future<TxHashEntity> postEditAtlasNode(CreateAtlasEntity entity) async {
    return AtlasHttpCore.instance.postEntity(
        "/v1/atlas/mod",
        EntityFactory<TxHashEntity>(
          (json) => TxHashEntity.fromJson(json),
        ),
        data: entity.toJson(),
        options: RequestOptions(contentType: "application/json"));
  }

  // 查询atlas节点详情
  Future<AtlasInfoEntity> postAtlasInfo(String address, String nodeId) async {
    return AtlasHttpCore.instance.postEntity(
        "/v1/atlas/info",
        EntityFactory<AtlasInfoEntity>(
          (json) => AtlasInfoEntity.fromJson(json),
        ),
        params: {
          "address": address,
          "node_id": nodeId,
        },
        options: RequestOptions(contentType: "application/json"));
  }

  // 查询Atlas节点下的所有map3节点列表
  Future<List<Map3InfoEntity>> postAtlasMap3NodeList(String nodeId,
      {int page = 0, int size = 0}) async {
    return AtlasHttpCore.instance.postEntity(
        "/v1/atlas/map3_list",
        EntityFactory<List<Map3InfoEntity>>((list) => (list as List)
            .map((item) => Map3InfoEntity.fromJson(item))
            .toList()),
        params: {
          "node_id": nodeId,
          "page": page,
          "size": size,
        },
        options: RequestOptions(contentType: "application/json"));
  }

  // 查询Atlas节点列表
  Future<List<AtlasInfoEntity>> postAtlasNodeList(String address,
      {int page = 0, int size = 0}) async {
    return AtlasHttpCore.instance.postEntity(
        "/v1/atlas/node_list",
        EntityFactory<List<AtlasInfoEntity>>((list) => (list as List)
            .map((item) => AtlasInfoEntity.fromJson(item))
            .toList()),
        params: {
          "address": address,
          "page": page,
          "size": size,
        },
        options: RequestOptions(contentType: "application/json"));
  }

  // 查询atlas概览数据
  Future<CommitteeInfoEntity> postAtlasOverviewData() async {
    return AtlasHttpCore.instance.postEntity(
        "/v1/atlas/outline",
        EntityFactory<CommitteeInfoEntity>(
          (json) => CommitteeInfoEntity.fromJson(json),
        ),
        options: RequestOptions(contentType: "application/json"));
  }

  // 领取atlas奖励
  Future<TxHashEntity> getAtlasReward(PledgeAtlasEntity entity) async {
    return AtlasHttpCore.instance.postEntity(
        "/v1/atlas/reward",
        EntityFactory<TxHashEntity>(
          (json) => TxHashEntity.fromJson(json),
        ),
        data: entity.toJson(),
        options: RequestOptions(contentType: "application/json"));
  }

  // 重新激活atlas节点
  Future<TxHashEntity> activeAtlasNode(CreateAtlasEntity entity) async {
    return AtlasHttpCore.instance.postEntity(
        "/v1/atlas/active",
        EntityFactory<TxHashEntity>(
          (json) => TxHashEntity.fromJson(json),
        ),
        data: entity.toJson(),
        options: RequestOptions(contentType: "application/json"));
  }

  // 抵押atlas节点
  Future<TxHashEntity> postPledgeAtlas(PledgeAtlasEntity entity) async {
    return AtlasHttpCore.instance.postEntity(
        "/v1/atlas/pledge",
        EntityFactory<TxHashEntity>(
          (json) => TxHashEntity.fromJson(json),
        ),
        data: entity.toJson(),
        options: RequestOptions(contentType: "application/json"));
  }

  // 创建/分裂-map3节点
  Future<TxHashEntity> postCreateMap3Node(CreateMap3Entity entity) async {
    return AtlasHttpCore.instance.postEntity(
        "/v1/map3/create",
        EntityFactory<TxHashEntity>(
          (json) => TxHashEntity.fromJson(json),
        ),
        data: entity.toJson(),
        options: RequestOptions(contentType: "application/json"));
  }

  // 编辑Map3节点
  Future<TxHashEntity> postEditMap3Node(CreateMap3Entity entity) async {
    return AtlasHttpCore.instance.postEntity(
        "/v1/map3/mod",
        EntityFactory<TxHashEntity>(
          (json) => TxHashEntity.fromJson(json),
        ),
        data: entity.toJson(),
        options: RequestOptions(contentType: "application/json"));
  }

  // 查询map3节点详情
  Future<Map3InfoEntity> getMap3Info1(
      String address, String nodeAddress) async {
    return AtlasHttpCore.instance.postEntity(
        "/v1/map3/info",
        EntityFactory<Map3InfoEntity>(
          (json) => Map3InfoEntity.fromJson(json),
        ),
        params: {
          "address": address,
          "node_address": nodeAddress,
        },
        options: RequestOptions(contentType: "application/json"));
  }

  Future<Map3InfoEntity> getMap3Info(String address, String nodeAddress) async {
    return AtlasHttpCore.instance.postEntity("/v1/map3/info",
        EntityFactory<Map3InfoEntity>(
      (json) {
        if (json != null) {
          return Map3InfoEntity.fromJson(json);
        }
        return null;
      },
    ), params: {
      "address": address,
      "node_address": nodeAddress,
    }, options: RequestOptions(contentType: "application/json"));
  }

  // 查询查询Map3节点列表
  Future<List<Map3InfoEntity>> getMap3NodeList(
    String address, {
    int page = 0,
    int size = 0,
  }) async {
    return AtlasHttpCore.instance.postEntity(
        "/v1/map3/node_list",
        EntityFactory<List<Map3InfoEntity>>((list) => (list as List)
            .map((item) => Map3InfoEntity.fromJson(item))
            .toList()),
        params: {
          "address": address,
          "page": page,
          "size": size,
        },
        options: RequestOptions(contentType: "application/json"));
  }

  // 抵押/撤销抵押/终止-map3节点
  Future<TxHashEntity> postPledgeMap3(PledgeMap3Entity entity) async {
    return AtlasHttpCore.instance.postEntity(
        "/v1/map3/pledge",
        EntityFactory<TxHashEntity>(
          (json) => TxHashEntity.fromJson(json),
        ),
        data: entity.toJson(),
        options: RequestOptions(contentType: "application/json"));
  }

  // 领取map3节点奖励
  Future<TxHashEntity> getMap3Reward(PledgeMap3Entity entity) async {
    return AtlasHttpCore.instance.postEntity(
        "/v1/map3/reward",
        EntityFactory<TxHashEntity>(
          (json) => TxHashEntity.fromJson(json),
        ),
        data: entity.toJson(),
        options: RequestOptions(contentType: "application/json"));
  }

  // 获取节点的简介
  Future<Map3IntroduceEntity> getMap3Introduce() async {
    return AtlasHttpCore.instance.postEntity(
        "/v1/map3/introduce",
        EntityFactory<Map3IntroduceEntity>(
          (json) => Map3IntroduceEntity.fromJson(json),
        ),
        options: RequestOptions(contentType: "application/json"));
  }

  // 获取bls key sign
  Future<BlsKeySignEntity> getMap3Bls() async {
    return AtlasHttpCore.instance.postEntity(
        "/v1/map3/bls",
        EntityFactory<BlsKeySignEntity>(
          (json) => BlsKeySignEntity.fromJson(json),
        ),
        options: RequestOptions(contentType: "application/json"));
  }

  // 获取用户的未领取总收益
  Future<UserRewardEntity> getRewardInfo(String address) async {
    return AtlasHttpCore.instance.postEntity(
        "/v1/map3/reward_info",
        EntityFactory<UserRewardEntity>(
          (json) => UserRewardEntity.fromJson(json),
        ),
        params: {
          "address": address,
        },
        options: RequestOptions(contentType: "application/json"));
  }

  // 获取节点的抵押流水
  Future<List<Map3StakingLogEntity>> getMap3StakingLogList(String nodeAddress,
      {int page = 1, int size = 10}) async {
    return AtlasHttpCore.instance.postEntity(
        "/v1/map3/staking_log",
        EntityFactory<List<Map3StakingLogEntity>>((list) => (list as List)
            .map((item) => Map3StakingLogEntity.fromJson(item))
            .toList()),
        params: {
          "node_address": nodeAddress,
          "page": page,
          "size": size,
        },
        options: RequestOptions(contentType: "application/json"));
  }

  // 获取节点的抵押人地址列表
  Future<List<UserMap3Entity>> getMap3UserList(String nodeAddress,
      {int page = 1, int size = 10}) async {
    return AtlasHttpCore.instance.postEntity(
        "/v1/map3/user_list",
        EntityFactory<List<UserMap3Entity>>((list) => (list as List)
            .map((item) => UserMap3Entity.fromJson(item))
            .toList()),
        params: {
          "node_address": nodeAddress,
          "page": page,
          "size": size,
        },
        options: RequestOptions(contentType: "application/json"));
  }

  // 上传图片
  Future<String> postUploadImageFile(
      String path, ProgressCallback onSendProgress) async {
    try {
      Map<String, dynamic> params = {};
      params["file"] = MultipartFile.fromFileSync(path);
      FormData formData = FormData.fromMap(params);

      var res = await AtlasHttpCore.instance.post(
        "/v1/map3/upload",
        data: formData,
        options: RequestOptions(contentType: "multipart/form-data"),
        onSendProgress: onSendProgress,
      );

      var responseEntity = ResponseEntity<String>.fromJson(
        res,
        factory: EntityFactory((json) => json),
      );
      print(
        '[AtlasApi], postUploadImageFile, responseEntity:${responseEntity.code}, msg:${responseEntity.msg}',
      );

      if (responseEntity.data.isNotEmpty) {
        return responseEntity.data;
      } else {
        Fluttertoast.showToast(msg: responseEntity.msg);
        return null;
      }
    } catch (_) {
      Fluttertoast.showToast(msg: '图片上传失败');
      LogUtil.uploadException("[Atlas] upload image", 'post upload fail');
      return null;
    }
  }
}
