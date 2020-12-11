import 'package:dio/dio.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:titan/src/basic/http/entity.dart';
import 'package:titan/src/components/wallet/vo/wallet_vo.dart';
import 'package:titan/src/components/wallet/wallet_component.dart';
import 'package:titan/src/config/consts.dart';
import 'package:titan/src/pages/red_pocket/api/rp_http.dart';
import 'package:titan/src/pages/red_pocket/entity/rp_detail_entity.dart';
import 'package:titan/src/pages/red_pocket/entity/rp_holding_record_entity.dart';
import 'package:titan/src/pages/red_pocket/entity/rp_miners_entity.dart';
import 'package:titan/src/pages/red_pocket/entity/rp_my_level_info.dart';
import 'package:titan/src/pages/red_pocket/entity/rp_my_rp_record_entity.dart';
import 'package:titan/src/pages/red_pocket/entity/rp_promotion_rule_entity.dart';
import 'package:titan/src/pages/red_pocket/entity/rp_release_info.dart';
import 'package:titan/src/pages/red_pocket/entity/rp_staking_info.dart';
import 'package:titan/src/pages/red_pocket/entity/rp_staking_release_info.dart';
import 'package:titan/src/pages/red_pocket/entity/rp_statistics.dart';
import 'package:titan/src/plugins/wallet/wallet.dart' as WalletClass;
import 'package:titan/src/plugins/wallet/wallet.dart';
import 'package:titan/src/plugins/wallet/wallet_const.dart';
import 'package:titan/src/plugins/wallet/wallet_util.dart';
import 'package:web3dart/credentials.dart';
import 'package:web3dart/web3dart.dart';

class RPApi {
  Future<dynamic> postStakingRp({
    BigInt amount,
    String password = '',
    WalletVo activeWallet,
  }) async {
    var address = activeWallet?.wallet?.getEthAccount()?.address ?? "";
    var txHash = await activeWallet.wallet.sendHynStakeWithdraw(
      HynContractMethod.STAKE,
      password,
      stakingAmount: amount,
    );
    print("[Rp_api] postStakingRp, address:$address, txHash:$txHash");
    if (txHash == null) {
      return;
    }

    return await RPHttpCore.instance.postEntity("/v1/rp/create", EntityFactory<dynamic>((json) => json),
        params: {
          "address": address,
          "hyn_amount": amount.toString(),
          "tx_hash": txHash,
        },
        options: RequestOptions(contentType: "application/json"));
  }

  Future<dynamic> postRetrieveHyn({
    String password = '',
    WalletVo activeWallet,
  }) async {
    var address = activeWallet?.wallet?.getEthAccount()?.address ?? "";
    var txHash = await activeWallet.wallet.sendHynStakeWithdraw(HynContractMethod.WITHDRAW, password);
    print("[Rp_api] postRetrieveHyn, address:$address, txHash:$txHash");
    if (txHash == null) {
      return;
    }
    return await RPHttpCore.instance.postEntity("/v1/rp/retrieve", EntityFactory<dynamic>((json) => json),
        params: {
          "address": address,
          "tx_hash": txHash,
        },
        options: RequestOptions(contentType: "application/json"));
  }

  ///
  Future<RPStatistics> getRPStatistics(String address) async {
    return await RPHttpCore.instance.getEntity(
        "/v1/rp/statistics/$address",
        EntityFactory<RPStatistics>(
          (json) => RPStatistics.fromJson(json),
        ),
        options: RequestOptions(contentType: "application/json"));
  }

  Future<RpStakingReleaseInfo> getRPStakingReleaseInfo(String address, String id) async {
    return await RPHttpCore.instance.getEntity(
        "/v1/rp/staking/$address/$id",
        EntityFactory<RpStakingReleaseInfo>(
          (json) => RpStakingReleaseInfo.fromJson(json),
        ),
        options: RequestOptions(contentType: "application/json"));
  }

  Future<List<RpReleaseInfo>> getRPReleaseInfoList(
    String address, {
    int page = 1,
    int size = 20,
  }) async {
    return await RPHttpCore.instance.getEntity(
      '/v1/rp/release/$address',
      EntityFactory<List<RpReleaseInfo>>(
        (json) {
          var data = (json['data'] as List).map((map) {
            return RpReleaseInfo.fromJson(map);
          }).toList();

          return data;
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

  Future<List<RpReleaseInfo>> getStakingReleaseList(
    String id,
    String address, {
    int page = 1,
    int size = 20,
  }) async {
    // return getRPReleaseInfoList(address);

    return await RPHttpCore.instance.getEntity(
      '/v1/rp/staking/$address/$id/release',
      EntityFactory<List<RpReleaseInfo>>(
        (json) {
          var data = (json['data'] as List).map((map) {
            return RpReleaseInfo.fromJson(map);
          }).toList();

          return data;
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

  Future<List<RpStakingInfo>> getRPStakingInfoList(
    String address, {
    int page = 1,
    int size = 20,
  }) async {
    return await RPHttpCore.instance.getEntity(
      '/v1/rp/staking/$address',
      EntityFactory<List<RpStakingInfo>>((json) {
        var data = (json['data'] as List).map((map) {
          return RpStakingInfo.fromJson(map);
        }).toList();

        return data;
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

  ///可以取回的数量
  Future<Map<String, dynamic>> getCanRetrieve(String address) async {
    var data = await RPHttpCore.instance.getEntity(
      '/v1/rp/can_retrieve/$address',
      EntityFactory<Map<String, dynamic>>((json) {
        return json;
      }),
      options: RequestOptions(
        contentType: "application/json",
      ),
    );
    print("[rp_api] getCanRetrieve, data:$data");

    return data;
  }

  ///确认邀请
  Future<String> postRpInviter(
    String inviterAddress,
    WalletClass.Wallet wallet,
  ) async {
    var myAddress = wallet?.getEthAccount()?.address ?? "";
    if (myAddress.isEmpty || (inviterAddress?.isEmpty ?? true)) {
      return null;
    }
    inviterAddress = WalletUtil.bech32ToEthAddress(inviterAddress);
    if (myAddress.toLowerCase() == inviterAddress.toLowerCase()) {
      Fluttertoast.showToast(msg: "不能邀请自己");
      return null;
    }
    var result = await RPHttpCore.instance.postEntity("/v1/rp/confirm_invite", EntityFactory<dynamic>((json) => json),
        params: {
          "invitee": myAddress,
          "inviter": inviterAddress,
        },
        options: RequestOptions(contentType: "application/json"));
    return result['identify'];
  }

  ///邀请列表
  Future<RpMinersEntity> getRPMinerList(
    String address, {
    int page = 1,
    int size = 20,
  }) async {
    return await RPHttpCore.instance.getEntity(
      '/v1/rp/miners/$address',
      EntityFactory<RpMinersEntity>((json) {
        return RpMinersEntity.fromJson(json['data']);
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

  ///我的红包列表
  Future<RpMyRpRecordEntity> getMyRpRecordList(
    String address, {
    int size = 20,
    pagingKey = '',
  }) async {
    return await RPHttpCore.instance.getEntity(
      '/v1/rp/redpocket/list/$address',
      EntityFactory<RpMyRpRecordEntity>((json) {
        return RpMyRpRecordEntity.fromJson(json);
      }),
      params: {
        'paging_key': pagingKey,
        'size': size,
      },
      options: RequestOptions(
        contentType: "application/json",
      ),
    );
  }

  Future<RpOpenRecordEntity> getMyRpOpenInfo(
    String address,
    int redPocketId,
    int redPocketType,
  ) async {
    return await RPHttpCore.instance.getEntity(
        "/v1/rp/redpocket/info/$address",
        EntityFactory<RpOpenRecordEntity>(
          (json) => RpOpenRecordEntity.fromJson(json),
        ),
        params: {
          'id': redPocketId,
          'type': redPocketType,
        },
        options: RequestOptions(contentType: "application/json"));
  }

  Future<RpMyRpSplitRecordEntity> getMySlitRpRecordList(
    String address, {
    int size = 20,
    pagingKey = '',
    int redPocketId,
    int redPocketType,
  }) async {
    return await RPHttpCore.instance.getEntity(
      '/v1/rp/redpocket/split/$address',
      EntityFactory<RpMyRpSplitRecordEntity>((json) {
        return RpMyRpSplitRecordEntity.fromJson(json);
      }),
      params: {
        'paging_key': pagingKey,
        'id': redPocketId,
        'type': redPocketType,
        'size': size,
      },
      options: RequestOptions(
        contentType: "application/json",
      ),
    );
  }

  Future<RpDetailEntity> getMyRdList(
    String address, {
    int id = 0,
    int type = 0,
    int page = 1,
    int size = 20,
  }) async {
    return await RPHttpCore.instance.getEntity(
      '/v1/rp/redpocket/$address/detail',
      EntityFactory<RpDetailEntity>((json) {
        return RpDetailEntity.fromJson(json['data']);
      }),
      params: {
        'id': id,
        'type': type,
        'page': page,
        'size': size,
      },
      options: RequestOptions(
        contentType: "application/json",
      ),
    );
  }

  ///用户量级记录
  Future<List<RPLevelHistory>> getRpHoldingHistory(
    String address, {
    int page = 1,
    int size = 20,
  }) async {
    return await RPHttpCore.instance.getEntity(
      '/v1/rp/level/history/$address',
      EntityFactory<List<RPLevelHistory>>((json) {
        var data = (json['data'] as List).map((map) {
          return RPLevelHistory.fromJson(map);
        }).toList();

        return data;
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

  ///用户等级信息
  Future<RpMyLevelInfo> getRPMyLevelInfo(String address) async {
    return await RPHttpCore.instance.getEntity(
        "/v1/rp/level/info/$address",
        EntityFactory<RpMyLevelInfo>(
          (json) => RpMyLevelInfo.fromJson(json),
        ),
        options: RequestOptions(contentType: "application/json"));
  }

  ///用户升级 燃烧以及抵押 需求
  Future<RpPromotionRuleEntity> getRPPromotionRule(String address) async {
    return await RPHttpCore.instance.getEntity(
        "/v1/rp/level/promotion/$address",
        EntityFactory<RpPromotionRuleEntity>(
          (json) => RpPromotionRuleEntity.fromJson(json),
        ),
        options: RequestOptions(contentType: "application/json"));
  }

  ///预提交升级
  Future<dynamic> postRpDepositAndBurn({
    int level,
    BigInt depositAmount,
    BigInt burningAmount,
    String password = '',
    WalletVo activeWallet,
  }) async {
    var address = activeWallet?.wallet?.getEthAccount()?.address ?? "";

    var amount = depositAmount + burningAmount;
    var approveHex = await postRpApprove(password: password, activeWallet: activeWallet, amount: amount);
    if (approveHex?.isEmpty ?? true) {
      return;
    }
    print('[rp_api] postRpDepositAndBurn, approveHex: $approveHex');

    var rawTxHash = await activeWallet.wallet.signRpHolding(
      RpHoldingMethod.DEPOSIT_BURN,
      password,
      depositAmount: depositAmount,
      burningAmount: burningAmount,
    );

    print("[Rp_api] postRpDepositAndBurn, sendRpHolding, address:$address, txHash:$rawTxHash");
    if (rawTxHash == null) {
      return;
    }

    // todo: {"code":-10001,"msg":"Invalid request params","data":null,"subMsg":""}
    return await RPHttpCore.instance.postEntity("/v1/rp/level/promotion/submit", EntityFactory<dynamic>((json) => json),
        params: {
          "address": address,
          "burning": burningAmount.toString(),
          "holding": depositAmount.toString(),
          "level": level,
          // "tx_hash": txHash,
          'raw_tx': rawTxHash,
        },
        options: RequestOptions(contentType: "application/json"));
  }

  Future<dynamic> postRpWithdraw({
    BigInt withdrawAmount,
    String password = '',
    WalletVo activeWallet,
  }) async {
    var address = activeWallet?.wallet?.getEthAccount()?.address ?? "";

    // var amount = withdrawAmount;
    // var approveHex = await postRpApprove(password: password, activeWallet: activeWallet, amount: amount);
    // print('[rp_api] postRpWithdraw, approveHex: $approveHex');

    var rawTxHash = await activeWallet.wallet.signRpHolding(
      RpHoldingMethod.WITHDRAW,
      password,
      withdrawAmount: withdrawAmount,
    );

    print("[Rp_api] postRpWithdraw, sendRpHolding, address:$address, rawTxHash:$rawTxHash");
    if (rawTxHash == null) {
      return;
    }

    return await RPHttpCore.instance.postEntity("/v1/rp/level/withdraw/submit", EntityFactory<dynamic>((json) => json),
        params: {
          "address": address,
          "withdraw": withdrawAmount.toString(),
          "raw_tx": rawTxHash,
        },
        options: RequestOptions(contentType: "application/json"));
  }

  ///预提交 , 授权
  Future<String> postRpApprove({
    String password = '',
    BigInt amount,
    WalletVo activeWallet,
  }) async {
    var wallet = activeWallet?.wallet;
    var context = Keys.rootKey.currentContext;
    var address = wallet?.getEthAccount()?.address ?? "";

    final client = WalletUtil.getWeb3Client(true);
    var nonce = await client.getTransactionCount(EthereumAddress.fromHex(address));
    var gasLimit = 100000;
    var gasPrice = BigInt.from(WalletInheritedModel.of(context).gasPriceRecommend.fast.toInt());
    print(
        '[rp_api] postRpApprove, address:$address, amount:$amount, nonce:$nonce, gasPrice:$gasPrice, gasLimit:$gasLimit');

    var ret = await wallet.getAllowance(
      WalletConfig.hynRPHrc30Address,
      address,
      WalletConfig.rpHoldingContractAddress,
      true,
    );

    print('[rp_api] postRpApprove, getAllowance, res:$ret');
    // todo: getAllowance
    if (ret >= amount) {
      return '200';
    }
    var approveHex = await wallet.sendApproveErc20Token(
      contractAddress: WalletConfig.hynRPHrc30Address,
      approveToAddress: WalletConfig.rpHoldingContractAddress,
      amount: amount,
      password: password,
      gasPrice: gasPrice,
      gasLimit: gasLimit,
      //gasLimit: SettingInheritedModel.ofConfig(context).systemConfigEntity.erc20ApproveGasLimit,
      nonce: nonce,
      isAtlas: true,
    );
    print('[rp_api] postRpApprove, amount:$amount, approveHex: $approveHex');

    return approveHex;
  }
}
