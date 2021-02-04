import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:k_chart/utils/date_format_util.dart';
import 'package:package_info/package_info.dart';
import 'package:titan/generated/l10n.dart' as Transfer;
import 'package:titan/src/basic/http/entity.dart';
import 'package:titan/src/basic/http/http_exception.dart';
import 'package:titan/src/basic/http/signer.dart';
import 'package:titan/src/components/wallet/vo/coin_view_vo.dart';
import 'package:titan/src/components/wallet/vo/wallet_view_vo.dart';
import 'package:titan/src/components/wallet/wallet_component.dart';
import 'package:titan/src/config/consts.dart';
import 'package:titan/src/pages/red_pocket/api/rp_http.dart';
import 'package:titan/src/pages/red_pocket/entity/rp_airdrop_round_info.dart';
import 'package:titan/src/pages/red_pocket/entity/rp_detail_entity.dart';
import 'package:titan/src/pages/red_pocket/entity/rp_holding_record_entity.dart';
import 'package:titan/src/pages/red_pocket/entity/rp_level_airdrop_info.dart';
import 'package:titan/src/pages/red_pocket/entity/rp_miners_entity.dart';
import 'package:titan/src/pages/red_pocket/entity/rp_my_level_info.dart';
import 'package:titan/src/pages/red_pocket/entity/rp_my_rp_record_entity.dart';
import 'package:titan/src/pages/red_pocket/entity/rp_promotion_rule_entity.dart';
import 'package:titan/src/pages/red_pocket/entity/rp_release_info.dart';
import 'package:titan/src/pages/red_pocket/entity/rp_share_config_entity.dart';
import 'package:titan/src/pages/red_pocket/entity/rp_share_entity.dart';
import 'package:titan/src/pages/red_pocket/entity/rp_share_req_entity.dart';
import 'package:titan/src/pages/red_pocket/entity/rp_staking_info.dart';
import 'package:titan/src/pages/red_pocket/entity/rp_staking_release_info.dart';
import 'package:titan/src/pages/red_pocket/entity/rp_statistics.dart';
import 'package:titan/src/pages/red_pocket/entity/rp_stats.dart';
import 'package:titan/src/plugins/wallet/cointype.dart';
import 'package:titan/src/plugins/wallet/config/hyperion.dart';
import 'package:titan/src/pages/red_pocket/entity/rp_util.dart';
import 'package:titan/src/plugins/wallet/convert.dart';
import 'package:titan/src/plugins/wallet/wallet.dart' as WalletClass;
import 'package:titan/src/plugins/wallet/wallet.dart';
import 'package:titan/src/plugins/wallet/wallet_util.dart';
import 'package:web3dart/credentials.dart';
import 'package:web3dart/web3dart.dart';

class RPApi {
  Future<dynamic> postStakingRp({
    BigInt amount,
    String password = '',
    WalletViewVo activeWallet,
    int gasLimit = HyperionGasLimit.HRC30_APPROVE_RP,
  }) async {
    var address = activeWallet?.wallet?.getEthAccount()?.address ?? "";
    var txHash = await activeWallet.wallet.sendHynStakeWithdraw(
      HynContractMethod.STAKE,
      password,
      stakingAmount: amount,
      gasLimit: gasLimit,
    );
    print("[Rp_api] postStakingRp, address:$address, txHash:$txHash");
    if (txHash == null) {
      return;
    }

    return await RPHttpCore.instance
        .postEntity("/v1/rp/create", EntityFactory<dynamic>((json) => json),
            params: {
              "address": address,
              "hyn_amount": amount.toString(),
              "tx_hash": txHash,
            },
            options: RequestOptions(contentType: "application/json"));
  }

  // todo:取回未设置gasLimit
  Future<dynamic> postRetrieveHyn({
    String password = '',
    WalletViewVo activeWallet,
    int gasLimit = HyperionGasLimit.NODE_OPT,
  }) async {
    var address = activeWallet?.wallet?.getEthAccount()?.address ?? "";
    var txHash = await activeWallet.wallet.sendHynStakeWithdraw(
      HynContractMethod.WITHDRAW,
      password,
      gasLimit: gasLimit,
    );
    print("[Rp_api] postRetrieveHyn, address:$address, txHash:$txHash");
    if (txHash == null) {
      return;
    }
    return await RPHttpCore.instance
        .postEntity("/v1/rp/retrieve", EntityFactory<dynamic>((json) => json),
            params: {
              "address": address,
              "tx_hash": txHash,
            },
            options: RequestOptions(contentType: "application/json"));
  }

  ///统计信息
  Future<RPStatistics> getRPStatistics(String address) async {
    var isEmpty = address?.isEmpty ?? true;
    var path = "/v1/rp/statistics/$address";
    if (isEmpty) {
      path = "/v1/rp/statistics/null";
    }
    return await RPHttpCore.instance.getEntity(
        path,
        EntityFactory<RPStatistics>(
          (json) => RPStatistics.fromJson(json),
        ),
        options: RequestOptions(contentType: "application/json"));
  }

  int count = 0;
  int startTime = 0;
  int endTime = 0;

  Future<RpAirdropRoundInfo> getLatestRpAirdropRoundInfo(
    String address,
  ) async {
    return await RPHttpCore.instance.getEntity(
        "/v1/rp/airdrop/latestRound/$address",
        EntityFactory<RpAirdropRoundInfo>(
          (json) => RpAirdropRoundInfo.fromJson(json),
        ),
        options: RequestOptions(contentType: "application/json"));
  }

  Future<RpStats> getRPStats() async {
    return await RPHttpCore.instance.getEntity(
        "/v1/rp/stats",
        EntityFactory<RpStats>(
          (json) => RpStats.fromJson(json),
        ),
        options: RequestOptions(contentType: "application/json"));
  }

  Future<RpLevelAirdropInfo> getLatestLevelAirdropInfo(
    String address,
  ) async {
    return await RPHttpCoreNoLog.instance.getEntity(
        "/v1/rp/airdrop/level/latestRound/$address",
        EntityFactory<RpLevelAirdropInfo>(
          (json) => RpLevelAirdropInfo.fromJson(json),
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
      Fluttertoast.showToast(msg: Transfer.S.of(Keys.rootKey.currentContext).can_not_invite_myself);
      return null;
    }
    var result = await RPHttpCore.instance
        .postEntity("/v1/rp/confirm_invite", EntityFactory<dynamic>((json) => json),
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
    RedPocketType rpType = RedPocketType.LUCKY,
  }) async {
    return await RPHttpCore.instance.getEntity(
      '/v1/rp/redpocket/list/$address',
      EntityFactory<RpMyRpRecordEntity>((json) {
        return RpMyRpRecordEntity.fromJson(json);
      }),
      params: {
        'paging_key': json.encode(pagingKey),
        'size': size,
        'type': rpType.index,
      },
      options: RequestOptions(
        contentType: "application/json",
      ),
    );
  }

  Future<RpMyRpRecordEntity> getMyRpRecordStatistics(
    String address, {
    int size = 200,
    pagingKey = '',
  }) async {
    return await RPHttpCore.instance.getEntity(
      '/v1/rp/redpocket/list/$address',
      EntityFactory<RpMyRpRecordEntity>((json) {
        return RpMyRpRecordEntity.fromJson(json);
      }),
      params: {
        'paging_key': json.encode(pagingKey),
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
    int size = 200,
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
        'paging_key': json.encode(pagingKey),
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
    PackageInfo packageInfo;
    if (packageInfo == null) {
      packageInfo = await PackageInfo.fromPlatform();
    }

    var version = packageInfo?.version ?? "";
    var buildNumber = packageInfo?.buildNumber ?? "";
    //print("[rp_api] getRPPromotionRule, version:$version, buildNumber:$buildNumber");

    var versionCode = version + "+" + buildNumber;

    return await RPHttpCore.instance.getEntity(
        "/v1/rp/level/promotion/$address",
        EntityFactory<RpPromotionRuleEntity>(
          (json) => RpPromotionRuleEntity.fromJson(json),
        ),
        params: {
          'flag': '$versionCode',
        },
        options: RequestOptions(contentType: "application/json"));
  }

  ///预提交升级
  Future<dynamic> postRpDepositAndBurn({
    int from,
    int to,
    BigInt depositAmount,
    BigInt burningAmount,
    String password = '',
    WalletViewVo activeWallet,
    int gasLimit = HyperionGasLimit.NODE_OPT,
  }) async {
    var address = activeWallet?.wallet?.getEthAccount()?.address ?? "";

    var amount = depositAmount + burningAmount;
    final client = WalletUtil.getWeb3Client(CoinType.HYN_ATLAS);
    var nonce = await client.getTransactionCount(EthereumAddress.fromHex(address));
    var approveHex = await postRpApprove(
      password: password,
      activeWallet: activeWallet,
      amount: amount,
      nonce: nonce,
      gasLimit: gasLimit,
    );
    if (approveHex?.isEmpty ?? true) {
      throw HttpResponseCodeNotSuccess(
          -30011, Transfer.S.of(Keys.rootKey.currentContext).hyn_not_enough_for_network_fee);
    }
    print('[rp_api] postRpDepositAndBurn, approveHex: $approveHex');

    if (approveHex != '200') {
      nonce = nonce + 1;
    }
    var rawTxHash = await activeWallet.wallet.signRpHolding(
      RpHoldingMethod.DEPOSIT_BURN,
      password,
      depositAmount: depositAmount,
      burningAmount: burningAmount,
      nonce: nonce,
      gasLimit: gasLimit,
    );
    print("[Rp_api] postRpDepositAndBurn, sendRpHolding, address:$address, txHash:$rawTxHash");
    if (rawTxHash == null) {
      throw HttpResponseCodeNotSuccess(
          -30012, Transfer.S.of(Keys.rootKey.currentContext).rp_balance_not_enoungh);
    }

    return await RPHttpCore.instance
        .postEntity("/v1/rp/level/promotion/submit", EntityFactory<dynamic>((json) => json),
            params: {
              "address": address,
              "burning": burningAmount.toString(),
              "holding": depositAmount.toString(),
              "from": from,
              "to": to,
              'raw_tx': rawTxHash,
            },
            options: RequestOptions(contentType: "application/json"));
  }

  Future<dynamic> postRpWithdraw({
    int from,
    int to,
    BigInt withdrawAmount,
    String password = '',
    WalletViewVo activeWallet,
  }) async {
    var address = activeWallet?.wallet?.getEthAccount()?.address ?? "";

    var rawTxHash = await activeWallet.wallet.signRpHolding(
      RpHoldingMethod.WITHDRAW,
      password,
      withdrawAmount: withdrawAmount,
    );

    print("[Rp_api] postRpWithdraw, sendRpHolding, address:$address, rawTxHash:$rawTxHash");
    if (rawTxHash == null) {
      throw HttpResponseCodeNotSuccess(
          -30012, Transfer.S.of(Keys.rootKey.currentContext).rp_balance_not_enoungh);
    }

    return await RPHttpCore.instance
        .postEntity("/v1/rp/level/withdraw/submit", EntityFactory<dynamic>((json) => json),
            params: {
              "address": address,
              "withdraw": withdrawAmount.toString(),
              "raw_tx": rawTxHash,
              "from": from,
              "to": to,
            },
            options: RequestOptions(contentType: "application/json"));
  }

  ///预提交 , 授权
  Future<String> postRpApprove({
    String password = '',
    BigInt amount,
    WalletViewVo activeWallet,
    int nonce,
    int gasLimit = HyperionGasLimit.NODE_OPT,
  }) async {
    var wallet = activeWallet?.wallet;
    var context = Keys.rootKey.currentContext;
    var address = wallet?.getEthAccount()?.address ?? "";

    var gasPrice = BigInt.from(WalletInheritedModel.of(context).ethGasPriceRecommend.fast.toInt());
    print(
        '[rp_api] postRpApprove, address:$address, amount:$amount, gasPrice:$gasPrice, gasLimit:$gasLimit');

    var ret = await wallet.getAllowance(
      HyperionConfig.hynRPHrc30Address,
      address,
      HyperionConfig.rpHoldingContractAddress,
      CoinType.HYN_ATLAS,
    );

    print('[rp_api] postRpApprove, getAllowance, res:$ret');
    // getAllowance
    if (ret >= amount) {
      return '200';
    }
    var approveHex = await wallet.sendApproveErc20Token(
      contractAddress: HyperionConfig.hynRPHrc30Address,
      approveToAddress: HyperionConfig.rpHoldingContractAddress,
      amount: amount,
      password: password,
      gasPrice: gasPrice,
      gasLimit: gasLimit,
      nonce: nonce,
      coinType: CoinType.HYN_ATLAS,
    );
    print('[rp_api] postRpApprove, amount:$amount, approveHex: $approveHex');

    return approveHex;
  }

  // 新人/位置红包领取列表+信息
  Future<RpShareEntity> getNewBeeDetail(
    String address, {
    String id = '',
  }) async {
    return await RPHttpCore.instance.getEntity(
      '/v1/rp/new-bee/$address/detail',
      EntityFactory<RpShareEntity>((json) {
        return RpShareEntity.fromJson(json);
      }),
      params: {
        'id': id,
      },
      options: RequestOptions(
        contentType: "application/json",
      ),
    );
  }

  // 新人/位置红包信息
  Future<RpShareSendEntity> getNewBeeInfo(
    String address, {
    String id = '',
  }) async {
    return await RPHttpCore.instance.getEntity(
      '/v1/rp/new-bee/$address/info',
      EntityFactory<RpShareSendEntity>((json) {
        return RpShareSendEntity.fromJson(json);
      }),
      params: {
        'id': id,
      },
      options: RequestOptions(
        contentType: "application/json",
      ),
    );
  }

  // 领取新人/位置红包
  Future<dynamic> postOpenShareRp({
    RpShareReqEntity reqEntity,
  }) async {
    var responseEntity = await RPHttpCore.instance.postResponseEntity(
      "/v1/rp/new-bee/${reqEntity.address}/open",
      EntityFactory<dynamic>((json) => json),
      params: reqEntity.toJson(),
      options: RequestOptions(contentType: "application/json"),
    );

    if (responseEntity.code == -40013) {
      return -40013;
    } else if (responseEntity.code == ResponseCode.SUCCESS || responseEntity.code == 200) {
      return responseEntity.data;
    } else {
      throw HttpResponseCodeNotSuccess(
        responseEntity.code,
        responseEntity.msg,
        subMsg: responseEntity.subMsg,
      );
    }
  }

  // 发新人/位置红包
  Future<RpShareReqEntity> postSendShareRp({
    RpShareReqEntity reqEntity,
    WalletViewVo activeWallet,
    String password = '',
    String toAddress,
    CoinViewVo coinVo,
    int gasLimit = HyperionGasLimit.NODE_OPT,
  }) async {
    var address = activeWallet?.wallet?.getEthAccount()?.address ?? "";

    final client = WalletUtil.getWeb3Client(CoinType.HYN_ATLAS);

    // rp
    String rpSignedTX = '';
    var rpNonce = await client.getTransactionCount(EthereumAddress.fromHex(address));

    // hyn
    String hynSignedTX = '';
    var hynNonce = rpNonce;

    if (reqEntity.rpAmount > 0 && reqEntity.hynAmount > 0) {
      rpSignedTX = await activeWallet.wallet.signErc20Transaction(
        CoinType.HYN_ATLAS,
        contractAddress: coinVo.contractAddress,
        password: password,
        toAddress: toAddress,
        value: ConvertTokenUnit.strToBigInt(reqEntity.rpAmount.toString(), coinVo.decimals),
        // gasPrice: HyperionGasPrice.getRecommend().averageBigInt, // null，则是实时gasPrice
        nonce: rpNonce,
        gasLimit: gasLimit,
      );
      if (rpSignedTX == null) {
        throw HttpResponseCodeNotSuccess(
            -30012, Transfer.S.of(Keys.rootKey.currentContext).rp_balance_not_enoungh);
      }
      print('[rp_api] postSendShareRp, toAddress:$toAddress, nonce:$rpNonce, rawTxRp: $rpSignedTX');

      hynNonce = rpNonce + 1;

      hynSignedTX = await activeWallet.wallet.signTransaction(
        CoinType.HYN_ATLAS,
        password: password,
        toAddress: toAddress,
        gasPrice: HyperionGasPrice.getRecommend().averageBigInt,
        value: ConvertTokenUnit.strToBigInt(reqEntity.hynAmount.toString(), coinVo.decimals),
        nonce: hynNonce,
        gasLimit: gasLimit,
      );
      if (hynSignedTX?.isEmpty ?? true) {
        throw HttpResponseCodeNotSuccess(
            -30011, Transfer.S.of(Keys.rootKey.currentContext).hyn_not_enough_for_network_fee);
      }
      print(
          '[rp_api] postSendShareRp, toAddress:$toAddress, hynNonce:$hynNonce, rawTxHyn: $hynSignedTX');
    } else {
      if (reqEntity.rpAmount > 0) {
        rpSignedTX = await activeWallet.wallet.signErc20Transaction(
          CoinType.HYN_ATLAS,
          contractAddress: coinVo.contractAddress,
          password: password,
          toAddress: toAddress,
          value: ConvertTokenUnit.strToBigInt(reqEntity.rpAmount.toString(), coinVo.decimals),
          // gasPrice: HyperionGasPrice.getRecommend().averageBigInt, // null，则是实时gasPrice
          nonce: rpNonce,
          gasLimit: gasLimit,
        );
        print(
            '[rp_api] postSendShareRp, toAddress:$toAddress, nonce:$rpNonce, rawTxRp: $rpSignedTX');

        if (rpSignedTX == null) {
          throw HttpResponseCodeNotSuccess(
              -30012, Transfer.S.of(Keys.rootKey.currentContext).rp_balance_not_enoungh);
        }
      }

      if (reqEntity.hynAmount > 0) {
        hynSignedTX = await activeWallet.wallet.signTransaction(
          CoinType.HYN_ATLAS,
          password: password,
          toAddress: toAddress,
          gasPrice: HyperionGasPrice.getRecommend().averageBigInt,
          value: ConvertTokenUnit.strToBigInt(reqEntity.hynAmount.toString(), coinVo.decimals),
          nonce: hynNonce,
          gasLimit: gasLimit,
        );
        print(
            '[rp_api] postSendShareRp, toAddress:$toAddress, hynNonce:$hynNonce, rawTxHyn: $hynSignedTX');

        if (hynSignedTX?.isEmpty ?? true) {
          throw HttpResponseCodeNotSuccess(
              -30011, Transfer.S.of(Keys.rootKey.currentContext).hyn_not_enough_for_network_fee);
        }
      }
    }

    reqEntity.rpSignedTX = rpSignedTX;
    reqEntity.hynSignedTX = hynSignedTX;

    return await RPHttpCore.instance.postEntity(
      "/v1/rp/new-bee/$address/send",
      EntityFactory<RpShareReqEntity>((json) => RpShareReqEntity.fromJson(json)),
      params: reqEntity.toJson(),
      options: RequestOptions(contentType: "application/json"),
    );
  }

  // 新人/位置红包配置
  Future<RpShareConfigEntity> getNewBeeConfig(String address) async {
    return await RPHttpCore.instance.getEntity(
      '/v1/rp/new-bee/$address/config',
      EntityFactory<RpShareConfigEntity>((json) {
        return RpShareConfigEntity.fromJson(json);
      }),
      options: RequestOptions(
        contentType: "application/json",
      ),
    );
  }

  // 我领取的新人/位置红包配置
  Future<List<RpShareOpenEntity>> getShareGetList(
    String address, {
    int page = 1,
    int size = 20,
  }) async {
    return await RPHttpCore.instance.getEntity(
      '/v1/rp/new-bee/$address/get/list',
      EntityFactory<List<RpShareOpenEntity>>((json) {
        var data = (json['data'] as List).map((map) {
          return RpShareOpenEntity.fromJson(map);
        }).toList();

        return data;
      }),
      params: {
        'page': page,
        'pageSize': size,
      },
      options: RequestOptions(
        contentType: "application/json",
      ),
    );
  }

  // 我发送的新人/位置红包配置
  Future<List<RpShareSendEntity>> getShareSendList(
    String address, {
    int page = 1,
    int size = 20,
  }) async {
    return await RPHttpCore.instance.getEntity(
      '/v1/rp/new-bee/$address/send/list',
      EntityFactory<List<RpShareSendEntity>>((json) {
        var data = (json['data'] as List).map((map) {
          return RpShareSendEntity.fromJson(map);
        }).toList();

        return data;
      }),
      params: {
        'page': page,
        'pageSize': size,
      },
      options: RequestOptions(
        contentType: "application/json",
      ),
    );
  }

  // 最新的的新人/位置红包列表
  Future<List<RpShareSendEntity>> getShareLatestList(String address) async {
    return await RPHttpCore.instance.getEntity(
      '/v1/rp/new-bee/$address/latest',
      EntityFactory<List<RpShareSendEntity>>((json) {
        var data = (json as List).map((map) {
          return RpShareSendEntity.fromJson(map);
        }).toList();

        return data;
      }),
      options: RequestOptions(
        contentType: "application/json",
      ),
    );
  }

  // 获取新人/位置红包密码
  Future<dynamic> getRpPwdInfo({
    String address,
    WalletClass.Wallet wallet,
    String password,
    String id,
  }) async {
    Map<String, dynamic> params = {};
    params['address'] = address;
    params['ts'] = (DateTime.now().millisecondsSinceEpoch ~/ 1000).toString();
    params['id'] = id;

    var path = '/v1/rp/new-bee/$address/get-pwd';

    var signed = await Signer.signApiWithWallet(
      wallet,
      password,
      'GET',
      Const.RP_DOMAIN.split('//')[1],
      path,
      params,
    );
    params['sign'] = signed;

    return await RPHttpCore.instance.getEntity(
      path,
      EntityFactory<dynamic>((json) {
        return json;
      }),
      params: params,
      options: RequestOptions(
        contentType: "application/json",
      ),
    );
  }
}
