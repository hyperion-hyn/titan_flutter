import 'package:dio/dio.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:titan/src/basic/http/entity.dart';
import 'package:titan/src/components/wallet/vo/wallet_vo.dart';
import 'package:titan/src/pages/red_pocket/api/rp_http.dart';
import 'package:titan/src/pages/red_pocket/entity/rp_miners_entity.dart';
import 'package:titan/src/pages/red_pocket/entity/rp_promotion_entity.dart';
import 'package:titan/src/pages/red_pocket/entity/rp_release_info.dart';
import 'package:titan/src/pages/red_pocket/entity/rp_staking_info.dart';
import 'package:titan/src/pages/red_pocket/entity/rp_staking_release_info.dart';
import 'package:titan/src/pages/red_pocket/entity/rp_statistics.dart';
import 'package:titan/src/plugins/wallet/convert.dart';
import 'package:titan/src/plugins/wallet/wallet.dart';
import 'package:titan/src/plugins/wallet/wallet_util.dart';

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

  Future<bool> postRpInviter(
    String inviterAddress,
    Wallet wallet,
  ) async {
    var myAddress = wallet?.getEthAccount()?.address ?? "";
    if (myAddress.isEmpty || (inviterAddress?.isEmpty ?? true)) {
      return false;
    }
    inviterAddress = WalletUtil.bech32ToEthAddress(inviterAddress);
    if (myAddress.toLowerCase() == inviterAddress.toLowerCase()) {
      Fluttertoast.showToast(msg: "不能邀请自己");
      return false;
    }
    await RPHttpCore.instance.postEntity("/v1/rp/confirm_invite", EntityFactory<dynamic>((json) => json),
        params: {
          "invitee": myAddress,
          "inviter": inviterAddress,
        },
        options: RequestOptions(contentType: "application/json"));
    return true;
  }

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

  ///用户等级信息
  Future<RpPromotionEntity> getRPPromotionInfo(String address) async {
    return await RPHttpCore.instance.getEntity(
        "/v1/rp/promotion/$address",
        EntityFactory<RpPromotionEntity>(
          (json) => RpPromotionEntity.fromJson(json),
        ),
        options: RequestOptions(contentType: "application/json"));
  }

  // 预提交升级
  Future<dynamic> postLevelPromotion({
    BigInt burning,
    BigInt holding,
    int level,
    String password = '',
    WalletVo activeWallet,
  }) async {
    var address = activeWallet?.wallet?.getEthAccount()?.address ?? "";
    var txHash = await activeWallet.wallet.sendHynStakeWithdraw(
      HynContractMethod.STAKE,
      password,
      stakingAmount: burning + holding,
    );
    print("[Rp_api] postLevelPromotion, address:$address, txHash:$txHash");
    if (txHash == null) {
      return;
    }

    return await RPHttpCore.instance.postEntity("/v1/rp/level/promotion/submit", EntityFactory<dynamic>((json) => json),
        params: {
          "address": address,
          "burning": burning.toString(),
          "holding": holding.toString(),
          "level": level,
          "tx_hash": txHash,
        },
        options: RequestOptions(contentType: "application/json"));
  }

  // 预提交提取
  Future<dynamic> postLevelWithdraw({
    BigInt withdraw,
    String password = '',
    WalletVo activeWallet,
  }) async {
    var address = activeWallet?.wallet?.getEthAccount()?.address ?? "";
    var txHash = await activeWallet.wallet.sendHynStakeWithdraw(
      HynContractMethod.STAKE,
      password,
      stakingAmount: withdraw,
    );
    print("[Rp_api] postLevelWithdraw, address:$address, txHash:$txHash");
    if (txHash == null) {
      return;
    }

    return await RPHttpCore.instance.postEntity("/v1/rp/level/withdraw/submit", EntityFactory<dynamic>((json) => json),
        params: {
          "address": address,
          "level": withdraw.toString(),
          "tx_hash": txHash,
        },
        options: RequestOptions(contentType: "application/json"));
  }
}
