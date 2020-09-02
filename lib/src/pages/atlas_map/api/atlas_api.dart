import 'package:dio/dio.dart';
import 'package:titan/src/basic/http/entity.dart';
import 'package:titan/src/components/setting/setting_component.dart';
import 'package:titan/src/components/wallet/wallet_component.dart';
import 'package:titan/src/config/consts.dart';
import 'package:titan/src/pages/atlas_map/api/atlas_http.dart';
import 'package:titan/src/pages/atlas_map/entity/atlas_info_entity.dart';
import 'package:titan/src/pages/atlas_map/entity/committee_info_entity.dart';
import 'package:titan/src/pages/atlas_map/entity/create_atlas_entity.dart';
import 'package:titan/src/pages/atlas_map/entity/create_map3_entity.dart';
import 'package:titan/src/pages/atlas_map/entity/map3_info_entity.dart';
import 'package:titan/src/pages/atlas_map/entity/pledge_atlas_entity.dart';
import 'package:titan/src/pages/atlas_map/entity/pledge_map3_entity.dart';
import 'package:titan/src/pages/atlas_map/entity/test_post_entity.dart';
import 'package:titan/src/pages/atlas_map/entity/tx_hash_entity.dart';

import '../../../../config.dart';

class AtlasApi {
  Map<String, dynamic> getOptionHeader({hasLang = false, hasAddress = false, hasSign = false}) {
    if (!hasLang && !hasAddress && !hasSign) {
      return null;
    }
    Map<String, dynamic> headMap = Map();

    headMap.putIfAbsent("appSource", () => Config.APP_SOURCE);

    var activeWalletVo = WalletInheritedModel.of(Keys.rootKey.currentContext).activatedWallet;
    if (hasAddress && activeWalletVo != null) {
      headMap.putIfAbsent("Address", () => activeWalletVo.wallet.getEthAccount().address);
    }

    if (hasLang) {
      var language = SettingInheritedModel.of(Keys.rootKey.currentContext).netLanguageCode;
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
        options: RequestOptions(headers: getOptionHeader(hasSign: true),contentType: "application/json",));

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
  Future<List<Map3InfoEntity>> postAtlasMap3NodeList(String nodeId, {int page = 0, int size = 0}) async {
    return AtlasHttpCore.instance.postEntity(
        "/v1/atlas/map3_list",
        EntityFactory<List<Map3InfoEntity>>(
                (list) => (list as List).map((item) => Map3InfoEntity.fromJson(item)).toList()),
        params: {
          "node_id": nodeId,
          "page": page,
          "size": size,
        },
        options: RequestOptions(contentType: "application/json"));
  }

  // 查询Atlas节点列表
  Future<List<AtlasInfoEntity>> postAtlasNodeList(String address, {int page = 0, int size = 0}) async {
    return AtlasHttpCore.instance.postEntity(
        "/v1/atlas/node_list",
        EntityFactory<List<AtlasInfoEntity>>(
                (list) => (list as List).map((item) => AtlasInfoEntity.fromJson(item)).toList()),

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
  Future<TxHashEntity> activeAtlasNode(PledgeAtlasEntity entity) async {
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

  // 查询map3节点详情
  Future<Map3InfoEntity> postMap3Info(String address, String nodeId) async {
    return AtlasHttpCore.instance.postEntity(
        "/v1/map3/info",
        EntityFactory<Map3InfoEntity>(
              (json) => Map3InfoEntity.fromJson(json),
        ),
        params: {
          "address": address,
          "node_id": nodeId,
        },
        options: RequestOptions(contentType: "application/json"));

  }

  // 查询查询Map3节点列表
  Future<List<Map3InfoEntity>> postMap3NodeList(String address, {int page = 0, int size = 0}) async {
    return AtlasHttpCore.instance.postEntity(
        "/v1/map3/node_list",
        EntityFactory<List<Map3InfoEntity>>(
                (list) => (list as List).map((item) => Map3InfoEntity.fromJson(item)).toList()),
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

}