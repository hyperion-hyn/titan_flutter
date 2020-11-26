import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:titan/src/basic/http/entity.dart';
import 'package:titan/src/components/wallet/vo/wallet_vo.dart';
import 'package:titan/src/pages/red_pocket/api/rp_http.dart';
import 'package:titan/src/pages/red_pocket/entity/rp_release_info.dart';
import 'package:titan/src/pages/red_pocket/entity/rp_staking_info.dart';
import 'package:titan/src/pages/red_pocket/entity/rp_statistics.dart';
import 'package:titan/src/plugins/wallet/convert.dart';
import 'package:titan/src/plugins/wallet/wallet.dart';

class RPApi {

  Future<ResponseEntity> postCreateRp(
      {
        String amount = '0',
        String password = '',
        WalletVo activeWallet,
      }) async {

    var amountBig = ConvertTokenUnit.strToBigInt(amount);
    var address = activeWallet?.wallet?.getEthAccount()?.address ?? "";
    var txHash = await activeWallet.wallet.sendHynStakeWithdraw(HynContractMethod.STAKE, amountBig, password);

    return RPHttpCore.instance.postEntity(
        "/v1/rp/create",
        EntityFactory<ResponseEntity>(
                (json) => json),
        params: {
          "address": address,
          "amount": amountBig,
          "tx_hash": txHash,
        },
        options: RequestOptions(contentType: "application/json"));
  }

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
      EntityFactory<List<RPStakingInfo>>((json) {
        var data = (json['data'] as List).map((map) {
          return RPStakingInfo.fromJson(map);
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
}
