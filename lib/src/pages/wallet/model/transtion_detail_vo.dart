import 'package:json_annotation/json_annotation.dart';
import 'package:titan/src/pages/atlas_map/api/atlas_api.dart';
import 'package:titan/src/pages/atlas_map/entity/burn_history.dart';
import 'dart:convert' as jsonUtils;

import 'package:titan/src/pages/wallet/service/account_transfer_service.dart';
import 'package:titan/src/plugins/wallet/convert.dart';
import 'package:titan/src/utils/format_util.dart';

import 'hyn_transfer_history.dart';

import 'package:titan/src/plugins/wallet/convert.dart';

part 'transtion_detail_vo.g.dart';

@JsonSerializable()
class TransactionDetailVo {
  int id;
  String contractAddress;
  int localTransferType;

  int type; //1、转出 2、转入
  String hash;
  int state; //1 success, 0 pending, -1 failed
  double amount;
  String symbol;
  String fromAddress;
  String toAddress;
  int time;
  String nonce;
  String gas;
  String gasPrice;
  String gasUsed;
  String describe;

  String data;

  /*
  * "dataDecoded": {
                    "operatorAddress": "0xA1dBb26360F2187A14dFd911893ceCc83e0ee4A4",
                    "description": {
                        "name": "moo",
                        "identity": "moo_idx_3",
                        "website": "moo_website",
                        "securityContact": "moo_contact",
                        "details": "moo_detail"
                    },
                    "commission": "100000000000000000",
                    "nodePubKey": "68fac1eab5b5cabdb8e85104b4bb221b523047f25a7fb65059d21ecba69538b645b34add8118d63af04ed8504d25dc01",
                    "nodeKeySig": "0x1ff81d5d27fe38c782cbcb45c9fb162ed04bd8ec764bde1d8854daa67fc52a2f9eb5f432bf78a3cf889a3bf6fcc1ec01a1ee5b2ac41a998245a418b1c52d0b154078f04b6976d3d4f824f833e9c9b75602b4a17e42e7a7dd7f441e1e1fb8780c",
                    "amount": "110000000000000000000000"
                }
  * */
  Map<String, dynamic> dataDecoded;
  String blockHash;
  int blockNum;
  int epoch;
  int transactionIndex;
  int hynType;
  LogsDecoded logsDecoded;
  TransferPayload payload;
  @JsonKey(name: 'internal_trans')
  List<InternalTransactions> internalTransactions;

  TransactionDetailVo({
    this.id,
    this.contractAddress,
    this.localTransferType,
    this.type,
    this.state,
    this.amount,
    this.symbol,
    this.fromAddress,
    this.toAddress,
    this.time,
    this.hash,
    this.nonce,
    this.gas,
    this.gasPrice,
    this.gasUsed,
    this.describe,
    this.data,
    this.dataDecoded,
    this.blockHash,
    this.blockNum,
    this.epoch,
    this.transactionIndex,
    this.hynType,
    this.logsDecoded,
    this.payload,
    this.internalTransactions,
  });

  String getDecodedAmount() {
    if (dataDecoded == null) {
      return "0.0";
    }

    var bigAmount = '0';
    if (dataDecoded.keys.contains('amount')) {
      bigAmount = dataDecoded['amount'] ?? '0';
    }

    var amount = ConvertTokenUnit.weiToEther(weiBigInt: BigInt.parse(bigAmount))
        .toString();
    return amount;
  }

  String getAtlasRewardAmount() {
    if (logsDecoded == null ||
        logsDecoded.rewards == null ||
        logsDecoded.rewards.isEmpty) {
      return "0.0";
    }
    var amount = ConvertTokenUnit.weiToEther(
            weiBigInt: BigInt.parse(logsDecoded.rewards[0].amount))
        .toString();
    return amount;
  }

  String getBillDelegate() {
    if (payload == null || payload.delegator == null) {
      return "0";
    }
    var amount = ConvertTokenUnit.weiToEther(
            weiBigInt: BigInt.parse(FormatUtil.clearScientificCounting(
                double.parse(payload.amount))))
        .toString();
    return FormatUtil.stringFormatCoinNum(amount);
  }

  String getBillReward() {
    if (payload == null || payload.reward == null || payload.reward == "0") {
      return "0";
    }
    var amount = ConvertTokenUnit.weiToEther(
        weiBigInt: BigInt.parse(FormatUtil.clearScientificCounting(
            double.parse(payload.reward))))
        .toString();
    return FormatUtil.stringFormatCoinNum(amount);
  }

  String getMap3RewardAmount() {
    if (logsDecoded == null ||
        logsDecoded.rewards == null ||
        logsDecoded.rewards.isEmpty) {
      return "0.0";
    }
    BigInt amount = BigInt.parse("0");
    logsDecoded.rewards.forEach((element) {
      amount = amount + BigInt.parse(element.amount);
    });
    var amountStr = ConvertTokenUnit.weiToEther(weiBigInt: amount).toString();
    return amountStr;
  }

  BigInt getAllContractValue(){
    BigInt value = BigInt.from(0);
    internalTransactions.forEach((element) {
      value += BigInt.parse(element.value);
    });
    return value;
  }

  factory TransactionDetailVo.fromHynTransferHistory(
    HynTransferHistory hynTransferHistory,
    int transactionType,
    String symbol,
  ) {
    return TransactionDetailVo(
      type: transactionType,
      state: hynTransferHistory.status,
      amount: AtlasApi.isTransferBill(hynTransferHistory.type)
          ? AtlasApi.getTransferBillAmount(hynTransferHistory)
          : ConvertTokenUnit.weiToEther(
                  weiBigInt: BigInt.parse(hynTransferHistory.value))
              .toDouble(),
      symbol: symbol,
      fromAddress: AtlasApi.isTransferBill(hynTransferHistory.type)
          ? hynTransferHistory.payload.map3Node
          : hynTransferHistory.from,
      toAddress: AtlasApi.isTransferBill(hynTransferHistory.type)
          ? hynTransferHistory.payload.delegator
          : hynTransferHistory.to,
      time: hynTransferHistory.timestamp * 1000,
      hash: hynTransferHistory.txHash,
      gasPrice: hynTransferHistory.gasPrice,
      gasUsed: hynTransferHistory.gasUsed.toString(),
      gas: hynTransferHistory.gasLimit.toString(),
      nonce: hynTransferHistory.nonce.toString(),
      contractAddress: hynTransferHistory.contractAddress,
      data: hynTransferHistory.data,
      dataDecoded: hynTransferHistory.dataDecoded,
      blockHash: hynTransferHistory.blockHash,
      blockNum: hynTransferHistory.blockNum,
      epoch: hynTransferHistory.epoch,
      transactionIndex: hynTransferHistory.transactionIndex,
      hynType: hynTransferHistory.type,
      logsDecoded: hynTransferHistory.logsDecoded,
      payload: hynTransferHistory.payload,
      internalTransactions: hynTransferHistory.internalTransactions,
    );
  }

  factory TransactionDetailVo.fromHynErc30TransferHistory(
      HynTransferHistory hynTransferHistory,
      int transactionType,
      String symbol,
      ) {

    return TransactionDetailVo(
      type: transactionType,
      state: hynTransferHistory.status,
      amount: AtlasApi.isTransferBill(hynTransferHistory.type)
          ? AtlasApi.getTransferBillAmount(hynTransferHistory)
          : ConvertTokenUnit.weiToEther(
          weiBigInt: BigInt.parse(hynTransferHistory.value))
          .toDouble(),
      symbol: symbol,
      fromAddress: hynTransferHistory.from,
      toAddress: hynTransferHistory.to,
      time: hynTransferHistory.timestamp * 1000,
      hash: hynTransferHistory.txHash,
      gasPrice: hynTransferHistory.gasPrice,
      gasUsed: hynTransferHistory.gasUsed.toString(),
      gas: hynTransferHistory.gasLimit.toString(),
      nonce: hynTransferHistory.nonce.toString(),
      contractAddress: hynTransferHistory.contractAddress,
      data: hynTransferHistory.data,
      dataDecoded: hynTransferHistory.dataDecoded,
      blockHash: hynTransferHistory.blockHash,
      blockNum: hynTransferHistory.blockNum,
      epoch: hynTransferHistory.epoch,
      transactionIndex: hynTransferHistory.transactionIndex,
      hynType: hynTransferHistory.type,
      logsDecoded: hynTransferHistory.logsDecoded,
      payload: hynTransferHistory.payload,
      internalTransactions: hynTransferHistory.internalTransactions,
    );
  }

  factory TransactionDetailVo.fromJson(Map<String, dynamic> json) =>
      _$TransactionDetailVoFromJson(json);

  Map<String, dynamic> toJson() => _$TransactionDetailVoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}

class LocalTransferType {
  static const LOCAL_TRANSFER_ETH = 1;
  static const LOCAL_TRANSFER_HYN_USDT = 2;
  static const LOCAL_TRANSFER_MAP3 = 3;
}
