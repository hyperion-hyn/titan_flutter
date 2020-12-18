import 'dart:convert';

import 'package:decimal/decimal.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:titan/generated/l10n.dart';
import 'package:titan/src/basic/http/entity.dart';
import 'package:titan/src/components/setting/setting_component.dart';
import 'package:titan/src/components/setting/system_config_entity.dart';
import 'package:titan/src/components/wallet/wallet_component.dart';
import 'package:titan/src/config/application.dart';
import 'package:titan/src/config/consts.dart';
import 'package:titan/src/pages/atlas_map/api/atlas_http.dart';
import 'package:titan/src/pages/atlas_map/entity/atlas_home_entity.dart';
import 'package:titan/src/pages/atlas_map/entity/atlas_info_entity.dart';
import 'package:titan/src/pages/atlas_map/entity/atlas_message.dart';
import 'package:titan/src/pages/atlas_map/entity/bls_key_sign_entity.dart';
import 'package:titan/src/pages/atlas_map/entity/burn_history.dart';
import 'package:titan/src/pages/atlas_map/entity/committee_info_entity.dart';
import 'package:titan/src/pages/atlas_map/entity/create_atlas_entity.dart';
import 'package:titan/src/pages/atlas_map/entity/create_map3_entity.dart';
import 'package:titan/src/pages/atlas_map/entity/enum_atlas_type.dart';
import 'package:titan/src/pages/atlas_map/entity/map3_home_entity.dart';
import 'package:titan/src/pages/atlas_map/entity/map3_info_entity.dart';
import 'package:titan/src/pages/atlas_map/entity/map3_introduce_entity.dart';
import 'package:titan/src/pages/atlas_map/entity/map3_staking_entity.dart';
import 'package:titan/src/pages/atlas_map/entity/map3_user_entity.dart';
import 'package:titan/src/pages/atlas_map/entity/pledge_map3_entity.dart';
import 'package:titan/src/pages/atlas_map/entity/reward_history_entity.dart';
import 'package:titan/src/pages/atlas_map/entity/test_post_entity.dart';
import 'package:titan/src/pages/atlas_map/entity/tx_hash_entity.dart';
import 'package:titan/src/pages/atlas_map/entity/user_payload_with_address_entity.dart';
import 'package:titan/src/pages/atlas_map/entity/user_reward_entity.dart';
import 'package:titan/src/pages/wallet/model/hyn_transfer_history.dart';
import 'package:titan/src/plugins/wallet/convert.dart';
import 'package:titan/src/plugins/wallet/token.dart';
import 'package:titan/src/routes/fluro_convert_utils.dart';
import 'package:titan/src/routes/routes.dart';
import 'package:titan/src/utils/log_util.dart';
import 'package:web3dart/web3dart.dart';
import 'package:titan/src/plugins/wallet/wallet_util.dart';

import '../../../../config.dart';
import '../../../../env.dart';

class AtlasApi {
  Future<List<HynTransferHistory>> queryHYNHistory(
      String address, int page) async {
    Map result = await AtlasHttpCore.instance.post(
      "v1/wallet/account_txs_all",
      data: "{\"address\": \"$address\",\"page\": $page,\"size\": 20}",
    );

    if (result["code"] == 0) {
      var dataList = result["data"]["data"];
      if (dataList == null || (dataList as List).length == 0) {
        return [];
      }
      List resultList = dataList as List;
      return resultList
          .map((json) => HynTransferHistory.fromJson(json))
          .toList();
    } else {
      throw new Exception();
    }
  }

  Future<List<InternalTransactions>> queryHYNHrc30History(
      String address, int page, String contractAddress) async {
    Map result = await AtlasHttpCore.instance.post(
      "v1/wallet/account_internal_txs",
      data: "{\"address\": \"$address\",\"contract_address\": \"$contractAddress\",\"page\": $page,\"size\": 20}",
    );

    if (result["code"] == 0) {
      var dataList = result["data"]["data"];
      if (dataList == null || (dataList as List).length == 0) {
        return [];
      }
      List resultList = dataList as List;
      return resultList
          .map((json) => InternalTransactions.fromJson(json))
          .toList();
    } else {
      throw new Exception();
    }
  }

  Future<HynTransferHistory> queryHYNTxDetail(String address) async {
    Map result = await AtlasHttpCore.instance.post(
      "v1/wallet/tx_detail",
      data: "{\"address\": \"$address\"}",
    );
    if (result["code"] == 0) {
      var data = result["data"];
      return HynTransferHistory.fromJson(data);
    } else {
      throw new Exception();
    }
  }

  static Map3IntroduceEntity _map3introduceEntity;

  static Future<Map3IntroduceEntity> getIntroduceEntity() async {
    if (_map3introduceEntity != null) {
      return _map3introduceEntity;
    } else {
      var atlasApi = AtlasApi();
      _map3introduceEntity = await atlasApi._getMap3Introduce();
      return _map3introduceEntity;
    }
  }

  static goToAtlasMap3HelpPage(BuildContext context) {
    String webUrl =
        FluroConvertUtils.fluroCnParamsEncode("http://h.hyn.space/helpPage");
    String webTitle = FluroConvertUtils.fluroCnParamsEncode(
        S.of(Keys.rootKey.currentContext).help);
    Application.router.navigateTo(context,
        Routes.toolspage_webview_page + '?initUrl=$webUrl&title=$webTitle');
  }

  static goToHynScanPage(BuildContext context,String walletAddress) {
    if(walletAddress == null){
      return;
    }
    if(walletAddress.contains("@")){
      return;
    }
    if(walletAddress.startsWith("0x")){
      walletAddress = WalletUtil.ethAddressToBech32Address(walletAddress);
    }
    String webUrl;
    if(env.buildType == BuildType.DEV){
      webUrl = FluroConvertUtils.fluroCnParamsEncode("https://test.hynscan.io/address/$walletAddress/transactions");
    }else{
      webUrl = FluroConvertUtils.fluroCnParamsEncode("https://hynscan.io/address/$walletAddress/transactions");
    }
    String webTitle = FluroConvertUtils.fluroCnParamsEncode("");
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

  // 查询燃烧信息
  Future<BurnMsg> postBurnMsg({
    int status = 2,
  }) async {
    return AtlasHttpCore.instance.postEntity(
        "/v1/atlas/burn_msg",
        EntityFactory<BurnMsg>(
          (json) => BurnMsg.fromJson(json),
        ),
        params: {
          'status': status,
        },
        options: RequestOptions(contentType: "application/json"));
  }

  // 查询燃烧历史
  Future<List<BurnHistory>> postBurnHistoryList({
    int status = 2,
    int page = 1,
    int size = 10,
  }) async {
    return AtlasHttpCore.instance.postEntity(
        "/v1/atlas/burn_list",
        EntityFactory<List<BurnHistory>>((list) =>
            (list as List).map((item) => BurnHistory.fromJson(item)).toList()),
        params: {
          "status": status,
          "page": page,
          "size": size,
        },
        options: RequestOptions(contentType: "application/json"));
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
      {int page = 1, int size = 10}) async {
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
      {int page = 1, int size = 0}) async {
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

  // 查询Atlas节点列表
  Future<List<AtlasInfoEntity>> postUserAtlasNodeList(
    String address,
    NodeJoinType nodeJoinType, {
    int page = 1,
    int size = 10,
  }) async {
    return AtlasHttpCore.instance.postEntity(
        nodeJoinType == NodeJoinType.CREATOR
            ? "/v1/atlas/node_list_i_create"
            : "/v1/atlas/node_list_i_join",
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

  Future<List<HynTransferHistory>> getAtlasStakingLogList(String nodeAddress,
      {int page = 1, int size = 10}) async {
    return AtlasHttpCore.instance.postEntity(
        "/v1/atlas/tx_log",
        EntityFactory<List<HynTransferHistory>>((list) => (list as List)
            .map((item) => HynTransferHistory.fromJson(item))
            .toList()),
        params: {
          "node_address": nodeAddress,
          "page": page,
          "size": size,
        },
        options: RequestOptions(contentType: "application/json"));
  }

  // 查询atlas概览数据
  /*
  this.request = true,
  this.requestHeader = true,
  this.requestBody = false,
  this.responseHeader = true,
  this.responseBody = false,
  this.error = true,
  */
  Future<AtlasHomeEntity> postAtlasHome(String address) async {
    return AtlasHttpCoreNoLog.instance.postEntity(
        "/v1/atlas/home",
        EntityFactory<AtlasHomeEntity>(
          (json) => AtlasHomeEntity.fromJson(json),
        ),
        params: {
          "address": address,
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
  Future<TxHashEntity> getAtlasReward(String rawTx) async {
    return AtlasHttpCore.instance.postEntity(
        "/v1/atlas/reward",
        EntityFactory<TxHashEntity>(
          (json) => TxHashEntity.fromJson(json),
        ),
        params: {
          "raw_tx": rawTx,
        },
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
  Future<TxHashEntity> postPledgeAtlas(String rawTx) async {
    return AtlasHttpCore.instance.postEntity(
        "/v1/atlas/pledge",
        EntityFactory<TxHashEntity>(
          (json) => TxHashEntity.fromJson(json),
        ),
        params: {
          "raw_tx": rawTx,
        },
        options: RequestOptions(contentType: "application/json"));
  }

  // atlas节点图表数据
  Future<List<RewardHistoryEntity>> postAtlasChartHistory(String nodeAddress,
      {int page = 1, int size = 20}) async {
    return AtlasHttpCore.instance.postEntity(
        "/v1/atlas/reward_history",
        EntityFactory<List<RewardHistoryEntity>>((list) =>
            (list['data'] as List)
                .map((item) => RewardHistoryEntity.fromJson(item))
                .toList()),
        params: {
          "node_address": nodeAddress,
          "page": page,
          "size": size,
        },
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

  Future<Map3InfoEntity> getMap3Info(String address, String nodeId) async {
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
      "node_id": nodeId,
    }, options: RequestOptions(contentType: "application/json"));
  }

  // 查询查询我创建的节点
  Future<List<Map3InfoEntity>> getMap3NodeListByMyCreate(
    String address, {
    int page = 1,
    int size = 10,
    List status,
  }) async {
    return AtlasHttpCore.instance.postEntity(
        "/v1/map3/node_list_i_create",
        EntityFactory<List<Map3InfoEntity>>((list) => (list as List)
            .map((item) => Map3InfoEntity.fromJson(item))
            .toList()),
        params: {
          "address": address,
          "page": page,
          "size": size,
          'status': status,
        },
        options: RequestOptions(contentType: "application/json"));
  }

  // 查询查询我创建的节点
  Future<List<Map3InfoEntity>> getMap3NodeListByMyJoin(
    String address, {
    int page = 1,
    int size = 10,
    List status,
  }) async {
    return AtlasHttpCore.instance.postEntity(
        "/v1/map3/node_list_i_join",
        EntityFactory<List<Map3InfoEntity>>((list) => (list as List)
            .map((item) => Map3InfoEntity.fromJson(item))
            .toList()),
        params: {
          "address": address,
          "page": page,
          "size": size,
          'status': status,
        },
        options: RequestOptions(contentType: "application/json"));
  }

  // 查询查询Map3节点列表
  Future<List<Map3InfoEntity>> getMap3NodeListStarted(
    String address, {
    int page = 1,
    int size = 10,
  }) async {
    return AtlasHttpCore.instance.postEntity(
        "/v1/map3/node_list_started",
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

  // 查询查询Map3节点列表
  Future<List<Map3InfoEntity>> getMap3NodeList(
    String address, {
    int page = 1,
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

  // 查询查询Map3节点列表:查询查询待启动节点，未达到最小抵押量的
  Future<Map3StakingEntity> getMap3StakingList(
    String address, {
    int page = 1,
    int size = 0,
  }) async {
    return AtlasHttpCore.instance.postEntity(
        "/v1/map3/node_list",
        EntityFactory<Map3StakingEntity>(
            (json) => Map3StakingEntity.fromJson(json)),
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
  Future<Map3IntroduceEntity> _getMap3Introduce() async {
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
  Future<List<HynTransferHistory>> getMap3StakingLogListOld(String nodeAddress,
      {int page = 1, int size = 10}) async {
    return AtlasHttpCore.instance.postEntity(
        "/v1/map3/tx_log",
        EntityFactory<List<HynTransferHistory>>((list) => (list as List)
            .map((item) => HynTransferHistory.fromJson(item))
            .toList()),
        params: {
          "node_address": nodeAddress,
          "page": page,
          "size": size,
        },
        options: RequestOptions(contentType: "application/json"));
  }

  // 获取节点的抵押流水 (v2)
  Future<List<HynTransferHistory>> getMap3StakingLogList(String nodeAddress,
      {int page = 1, int size = 10}) async {
    return AtlasHttpCore.instance.postEntity(
        "/v1/map3/tx_log_all",
        EntityFactory<List<HynTransferHistory>>((list) => (list as List)
            .map((item) => HynTransferHistory.fromJson(item))
            .toList()),
        params: {
          "node_address": nodeAddress,
          "page": page,
          "size": size,
        },
        options: RequestOptions(contentType: "application/json"));
  }

  // 获取节点的抵押人地址列表
  Future<List<Map3UserEntity>> getMap3UserList(String nodeId,
      {int page = 1, int size = 10}) async {
    return AtlasHttpCore.instance.postEntity(
        "/v1/map3/user_list",
        EntityFactory<List<Map3UserEntity>>((list) => (list as List)
            .map((item) => Map3UserEntity.fromJson(item))
            .toList()),
        params: {
          "node_id": nodeId,
          "page": page,
          "size": size,
        },
        options: RequestOptions(contentType: "application/json"));
  }

  // 上传图片
  Future<String> postUploadImageFile(String address, String path, ProgressCallback onSendProgress) async {
    try {
      Map<String, dynamic> params = {};
      params["address"] = address;
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

  // 获取节点创建的推荐抵押量
  Future<List<String>> getMap3RecCreate() async {
    return AtlasHttpCore.instance.postEntity(
        "/v1/map3/rec_create",
        EntityFactory<List<String>>(
            (list) => (list as List).map((item) => "$item").toList()),
        options: RequestOptions(contentType: "application/json"));
  }

  // 获取节点推荐抵押量
  Future<List<String>> getMapRecStaking() async {
    return AtlasHttpCore.instance.postEntity(
        "/v1/map3/rec_staking",
        EntityFactory<List<String>>(
            (list) => (list as List).map((item) => "$item").toList()),
        options: RequestOptions(contentType: "application/json"));
  }

  // 获取节点推荐抵押量
  Future<List<String>> getBiboxWhiteList() async {
    return AtlasHttpCore.instance.postEntity(
        "/v1/wallet/bibox",
        EntityFactory<List<String>>(
            (list) => (list as List).map((item) => "$item").toList()),
        options: RequestOptions(contentType: "application/json"));
  }

  // 获取账户交易记录
  Future<List<HynTransferHistory>> getRewardTxsList(String walletAddress,
      {int page = 1, int size = 10}) async {
    return AtlasHttpCore.instance.postEntity(
        "/v1/wallet/reward_txs",
        EntityFactory<List<HynTransferHistory>>((json) => (json['data'] as List)
            .map((item) => HynTransferHistory.fromJson(item))
            .toList()),
        params: {
          "address": walletAddress,
          "page": page,
          "size": size,
        },
        options: RequestOptions(contentType: "application/json"));
  }

  // 查询map3首页数据
  Future<Map3HomeEntity> getMap3Home(String address) async {
    return AtlasHttpCore.instance.postEntity(
        "/v1/map3/home",
        EntityFactory<Map3HomeEntity>(
          (json) => Map3HomeEntity.fromJson(json),
        ),
        params: {
          "address": address,
        },
        options: RequestOptions(contentType: "application/json"));
  }

  // 同步用户信息
  static Future postUserSync(UserPayloadWithAddressEntity userPayload) async {
    return AtlasHttpCore.instance.post("/v1/wallet/user_sync",
        data: userPayload.toJson(),
        options: RequestOptions(contentType: "application/json"));
  }

  // 获取交易列表
  Future<List<HynTransferHistory>> getTxsList(
    String walletAddress, {
    int page = 1,
    int size = 10,
    String atlasAddress = '',
    String map3Address = '',
    String order = '',
    // 自定义： 1.pending；2.pending_for_receipt; 3.success;4.fail;5.dropped&replaced
    List<int> status,
    // 0一般转账；1创建atlas节点；2修改atlas节点；3参与atlas节点抵押；4撤销atlas节点抵押；5领取atlas奖励；6创建map3节点；7编辑map3节点；8撤销map3节点；9参与map3抵押；10撤销map3抵押；11领取map3奖励；12裂变map3节点；13重新激活Atlas
    List<int> type,
  }) async {
    return AtlasHttpCore.instance.postEntity(
        "/v1/wallet/txs",
        EntityFactory<List<HynTransferHistory>>((json) => (json as List)
            .map((item) => HynTransferHistory.fromJson(item))
            .toList()),
        params: {
          "address": walletAddress,
          "atlas_address": atlasAddress,
          "map3_address": map3Address,
          "page": page,
          "size": size,
          "status": status,
          "type": type,
        },
        options: RequestOptions(contentType: "application/json"));
  }

  static Future<bool> checkLastTxIsPending(
    int type, {
    String map3Address = '',
    String atlasAddress = '',
  }) async {
    try {
      var activatedWallet =
          WalletInheritedModel.of(Keys.rootKey.currentContext).activatedWallet;
      var _wallet = activatedWallet?.wallet;
      var _walletAddress = _wallet?.getEthAccount()?.address ?? "";

      List<HynTransferHistory> list = await AtlasApi().getTxsList(
        _walletAddress,
        status: [
          TransactionStatus.pending,
          TransactionStatus.pending_for_receipt
        ],
        type: [type],
        map3Address: map3Address,
        atlasAddress: atlasAddress,
      );

      var isNotEmpty = list?.isNotEmpty ?? false;
      if (isNotEmpty) {
        // 已经过去30秒的话，可以执行后面操作
        var lastTransaction = list.first;
        var now = DateTime.now().millisecondsSinceEpoch;
        var last = lastTransaction.timestamp * 1000;
        var isOver30Seconds = (now - last) > (30 * 1000);
        //print("my--->now:$now, last:$last, isOver30Seconds:$isOver30Seconds");
        if (isOver30Seconds) {
          isNotEmpty = false;
        }
      }

      if (isNotEmpty) {
        switch (type) {
          case MessageType.typeTerminateMap3:
            Fluttertoast.showToast(
              msg: '终止请求正处理中!',
              gravity: ToastGravity.CENTER,
            );
            break;

          case MessageType.typeUnMicroDelegate:
            Fluttertoast.showToast(
              msg: '部分撤销请求正处理中!',
              gravity: ToastGravity.CENTER,
            );
            break;

          case MessageType.typeCollectMicroStakingRewards:
            Fluttertoast.showToast(
              msg: '提取请求正处理中!',
              gravity: ToastGravity.CENTER,
            );
            break;

          case MessageType.typeRenewMap3:
            Fluttertoast.showToast(
              msg: '续约请求正处理中!',
              gravity: ToastGravity.CENTER,
            );
            break;

          case MessageType.typeEditMap3:
            Fluttertoast.showToast(
              msg: '编辑请求正处理中!',
              gravity: ToastGravity.CENTER,
            );
            break;

          case MessageType.typeReDelegate:
            Fluttertoast.showToast(
              msg: '复抵押正处理中!',
              gravity: ToastGravity.CENTER,
            );
            break;

          case MessageType.typeUnReDelegate:
            Fluttertoast.showToast(
              msg: '取消复抵押正处理中!',
              gravity: ToastGravity.CENTER,
            );
            break;

          case MessageType.typeCollectReStakingReward:
            Fluttertoast.showToast(
              msg: '提取出块奖励正处理中!',
              gravity: ToastGravity.CENTER,
            );
            break;
        }
      }

      return isNotEmpty;
    } catch (e) {
      print(e);
      Fluttertoast.showToast(
        msg: '未知错误，请稍后重试!',
        gravity: ToastGravity.CENTER,
      );
      return false;
    }
  }

  static bool isTransferBill(int type) {
    return (type == MessageType.typeUnMicrostakingReturn ||
        type == MessageType.typeTerminateMap3Return);
  }

  static double getTransferBillAmount(HynTransferHistory hynTransferHistory) {
    var amountStr = (Decimal.parse(hynTransferHistory.payload.amount) +
            Decimal.parse(hynTransferHistory.payload.reward))
        .toString();
    return ConvertTokenUnit.weiToEther(weiBigInt: BigInt.parse(amountStr))
        .toDouble();
  }

  static bool isTransferMap3Atlas(int type) {
    return (type == MessageType.typeCreateValidator ||
        type == MessageType.typeEditValidator ||
        type == MessageType.typeReDelegate ||
        type == MessageType.typeUnReDelegate ||
        type == MessageType.typeCollectReStakingReward ||
        type == MessageType.typeCreateMap3 ||
        type == MessageType.typeEditMap3 ||
        type == MessageType.typeTerminateMap3 ||
        type == MessageType.typeMicroDelegate ||
        type == MessageType.typeUnMicroDelegate ||
        type == MessageType.typeCollectMicroStakingRewards ||
        type == MessageType.typeRenewMap3);
  }

  static Future<bool> checkIsExit({String map3Address = ''}) async {
    try {
      var activatedWallet =
          WalletInheritedModel.of(Keys.rootKey.currentContext).activatedWallet;
      var _wallet = activatedWallet?.wallet;
      var _walletAddress = _wallet?.getEthAccount()?.address ?? "";

      List<HynTransferHistory> list = await AtlasApi().getTxsList(
        _walletAddress,
        type: [MessageType.typeTerminateMap3],
        map3Address: map3Address,
      );

      var isNotEmpty = list?.isNotEmpty ?? false;

      if (isNotEmpty) {
        var status = list.first.status;
        switch (status) {
          case TransactionStatus.pending:
            Fluttertoast.showToast(
              msg: '终止请求正处理中!',
              gravity: ToastGravity.CENTER,
            );
            break;

          case TransactionStatus.success:
            Fluttertoast.showToast(
              msg: '终止请求已完成!',
              gravity: ToastGravity.CENTER,
            );
            break;
        }
        return true;
      } else {
        return false;
      }
    } catch (e) {
      print(e);
      return false;
    }
  }

  // 查询map3ID是否在
  Future<bool> checkNodeIdExist(String nodeId, {String address = ''}) async {
    return AtlasHttpCore.instance.postEntity(
        "/v1/map3/node_id_exist",
        EntityFactory<bool>(
          (haveExist) => haveExist,
        ),
        params: {
          "address": address,
          "node_id": nodeId,
        },
        options: RequestOptions(contentType: "application/json"));
  }

  Future<SystemConfigEntity> getSystemConfigData() async {
    var configEntity = await AtlasHttpCore.instance.postEntity('/v1/app/config',
        EntityFactory<SystemConfigEntity>((data) {
      return SystemConfigEntity.fromJson(json.decode(data));
    }), params: {
      "key": 'app:config',
    }, options: RequestOptions(contentType: "application/json"));
    return configEntity;
  }
}
