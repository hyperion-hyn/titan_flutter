import 'package:decimal/decimal.dart';
import 'package:titan/src/components/wallet/wallet_component.dart';
import 'package:titan/src/config/consts.dart';
import 'package:titan/src/global.dart';
import 'package:titan/src/pages/atlas_map/entity/create_atlas_entity.dart';
import 'package:titan/src/pages/atlas_map/entity/create_map3_entity.dart';
import 'package:titan/src/pages/atlas_map/entity/map3_info_entity.dart';
import 'package:titan/src/pages/atlas_map/entity/pledge_atlas_entity.dart';
import 'package:titan/src/pages/wallet/model/transtion_detail_vo.dart';
import 'package:titan/src/pages/wallet/service/account_transfer_service.dart';
import 'package:titan/src/plugins/wallet/convert.dart';
import 'package:titan/src/plugins/wallet/wallet.dart' as localWallet;
import 'package:titan/src/plugins/wallet/wallet_const.dart';
import 'package:titan/src/plugins/wallet/wallet_util.dart';
import 'package:titan/src/utils/format_util.dart';

import 'package:web3dart/web3dart.dart';

class HYNApi {
  static Future<String> signTransferHYN(String password, localWallet.Wallet wallet,
      {String toAddress,
      BigInt amount,
      IMessage message,
      bool isAtlasTrans = true,
      String gasPrice,
      int gasLimit}) async {
    if (gasPrice == null) {
      gasPrice = (1 * TokenUnit.G_WEI).toStringAsFixed(0);
    }
    if(gasLimit == null){
      final client = WalletUtil.getWeb3Client(isAtlasTrans);
      var walletAddress = WalletInheritedModel.of(Keys.rootKey.currentContext).activatedWallet.wallet.getAtlasAccount().address;
      if(message == null || message?.type == MessageType.typeNormal){
        gasLimit = 21000;
      }else{
        /*var gasLimitBitInt = await client.estimateGas(sender: EthereumAddress.fromHex(walletAddress),
            data: message?.toRlp(),
            txType: message?.type ?? MessageType.typeNormal);
        gasLimit = gasLimitBitInt.toInt();*/
        gasLimit = 100000;
      }

      print("!!!!! $gasLimit");
    }
    final txHash = await wallet.signEthTransaction(
      password: password,
      toAddress: toAddress,
      gasPrice: BigInt.parse(gasPrice),
      value: message == null ? amount : null,
      type: message?.type ?? MessageType.typeNormal,
      message: message,
      isAtlasTrans: isAtlasTrans,
      gasLimit: gasLimit,
    );

    logger.i('HYN transaction committed，txHash $txHash');
    return txHash;
  }

  static Future<String> sendTransferHYN(String password, localWallet.Wallet wallet,
      {String toAddress,
      BigInt amount,
      IMessage message,
      bool isAtlasTrans = true,
      String gasPrice,
      int gasLimit}) async {
    if (gasPrice == null) {
      gasPrice = (1 * TokenUnit.G_WEI).toStringAsFixed(0);
    }
    if(gasLimit == null){
      final client = WalletUtil.getWeb3Client(isAtlasTrans);
      var walletAddress = WalletInheritedModel.of(Keys.rootKey.currentContext).activatedWallet.wallet.getAtlasAccount().address;
      if(message == null || message?.type == MessageType.typeNormal){
        gasLimit = 21000;
      }else{
        /*var gasLimitBitInt = await client.estimateGas(sender: EthereumAddress.fromHex(walletAddress),
            data: message?.toRlp(),
            txType: message?.type ?? MessageType.typeNormal);
        gasLimit = gasLimitBitInt.toInt();*/
        gasLimit = 100000;
      }

      print("!!!!! $gasLimit");
    }
    final txHash = await wallet.sendEthTransaction(
      password: password,
      toAddress: toAddress,
      gasPrice: BigInt.parse(gasPrice),
      value: message == null ? amount : null,
      type: message?.type ?? MessageType.typeNormal,
      message: message,
      isAtlasTrans: isAtlasTrans,
      gasLimit: gasLimit,
    );

    logger.i('HYN transaction committed，txHash $txHash');
    return txHash;
  }

  static Future<String> transCreateAtlasNode(
    CreateAtlasEntity createAtlasEntity,
    String password,
    localWallet.Wallet wallet,
  ) async {
    var message = CreateAtlasNodeMessage(
      maxChangeRate: ConvertTokenUnit.strToBigInt(createAtlasEntity.payload.feeRateTrim),
      maxRate: ConvertTokenUnit.strToBigInt(createAtlasEntity.payload.feeRateMax),
      rate: ConvertTokenUnit.strToBigInt(createAtlasEntity.payload.feeRate),
      maxTotalDelegation: ConvertTokenUnit.strToBigInt(createAtlasEntity.payload.maxStaking),
      description: NodeDescription(
          name: createAtlasEntity.payload.name,
          details: createAtlasEntity.payload.describe,
          identity: createAtlasEntity.payload.nodeId,
          securityContact: createAtlasEntity.payload.contact,
          website: createAtlasEntity.payload.home),
      operatorAddress: createAtlasEntity.payload.map3Address,
      slotPubKey: '2438b2439f5cec20d56c0948e557071a72d0ac9a113d627fafc1ad365802fb23919cd1bf07932ee0eb10e965147fe404',
      slotKeySig:
          '2a42c89854e15c8d5f6bde111217a53767c94c96ff061ea65a1f0f392fadafe383c6e94d1873956e399e0e869bb2cd11885fcb155eed2e783570a3b305b2c1c33ce846227458eec0abae735bf6460a25f70bf3d24da592790e59d826ca07e910',
    );
    print(message);

    var rawTx = await signTransferHYN(password, wallet, message: message);
    return rawTx;
  }

  static Future<String> transEditAtlasNode(
    CreateAtlasEntity createAtlasEntity,
    String password,
    localWallet.Wallet wallet,
  ) async {
    var message = EditAtlasNodeMessage(
      validatorAddress: createAtlasEntity.payload.atlasAddress,
      commissionRate: ConvertTokenUnit.strToBigInt(createAtlasEntity.payload.feeRate),
      maxTotalDelegation: ConvertTokenUnit.strToBigInt(createAtlasEntity.payload.maxStaking),
      description: NodeDescription(
          name: createAtlasEntity.payload.name,
          details: createAtlasEntity.payload.describe,
          identity: createAtlasEntity.payload.nodeId,
          securityContact: createAtlasEntity.payload.contact,
          website: createAtlasEntity.payload.home),
      operatorAddress: createAtlasEntity.payload.map3Address,
      slotKeyToRemove: "",
      slotKeyToAdd: '2438b2439f5cec20d56c0948e557071a72d0ac9a113d627fafc1ad365802fb23919cd1bf07932ee0eb10e965147fe404',
      slotKeyToAddSig:
          '2a42c89854e15c8d5f6bde111217a53767c94c96ff061ea65a1f0f392fadafe383c6e94d1873956e399e0e869bb2cd11885fcb155eed2e783570a3b305b2c1c33ce846227458eec0abae735bf6460a25f70bf3d24da592790e59d826ca07e910',
      eposStatus: 0, //0、 Active 1、Inactive 2、Banned
    );
    print(message);

    var rawTx = await signTransferHYN(password, wallet, message: message);
    return rawTx;
  }

  static Future<String> transAtlasReceiveReward(
    String map3Address,
    String atlasAddress,
    String password,
    localWallet.Wallet wallet,
  ) async {
    var message = CollectAtlasRewardMessage(delegatorAddress: map3Address, validatorAddress: atlasAddress);
    print(message);

    var rawTx = await signTransferHYN(password, wallet, message: message);
    return rawTx;
  }

  static Future<String> transAtlasActive(
    CreateAtlasEntity createAtlasEntity,
    String password,
    localWallet.Wallet wallet,
  ) async {
    var message = EditAtlasNodeMessage(
      validatorAddress: createAtlasEntity.payload.atlasAddress,
      operatorAddress: wallet.getAtlasAccount().address,
      eposStatus: 0, //0、 Active 1、Inactive 2、Banned
    );
    print(message);

    var rawTx = await signTransferHYN(password, wallet, message: message);
    return rawTx;
  }

  static Future<String> transAtlasStake(
    String map3Address,
    String atlasAddress,
    String password,
    localWallet.Wallet wallet,
  ) async {
    var message = ReDelegateAtlasMessage(delegatorAddress: map3Address, validatorAddress: atlasAddress);
    print(message);

    var rawTx = await signTransferHYN(password, wallet, message: message);
    return rawTx;
  }

  static Future<String> transAtlasUnStake(
    String map3Address,
    String atlasAddress,
    String password,
    localWallet.Wallet wallet,
  ) async {
    var message = UnReDelegateAtlasMessage(delegatorAddress: map3Address, validatorAddress: atlasAddress);
    print(message);

    var rawTx = await signTransferHYN(password, wallet, message: message);
    return rawTx;
  }

  //==================================Atlas Message End==============================================

  static Future transCreateMap3Node(
    CreateMap3Entity entity,
    String password,
    localWallet.Wallet wallet,
  ) async {
    var payload = entity.payload;
    print(payload.toJson());

    var amount = ConvertTokenUnit.decimalToWei(Decimal.parse(payload.staking));
    var feeRate = ConvertTokenUnit.strToBigInt(entity.payload.feeRate) / BigInt.parse('100');
    var message = CreateMap3NodeMessage(
      amount: amount,
      commission: BigInt.from(feeRate),
      description: NodeDescription(
          name: payload.name,
          details: payload.describe,
          identity: payload.nodeId,
          securityContact: payload.connect,
          website: payload.home),
      operatorAddress: wallet.getAtlasAccount().address,
      nodePubKey: payload.blsAddKey,
      nodeKeySig: payload.blsAddSign,
    );
    print(message);

    return signTransferHYN(password, wallet,
        toAddress: entity.to, message: message, gasPrice: entity.price);
  }

  static Future transEditMap3Node(
    CreateMap3Entity entity,
    String password,
    String map3NodeAddress,
    localWallet.Wallet wallet,
  ) async {
    var payload = entity.payload;

    var message = EditMap3NodeMessage(
      map3NodeAddress: map3NodeAddress,
      description: NodeDescription(
          name: payload.name,
          details: payload.describe,
          identity: payload.nodeId,
          securityContact: payload.connect,
          website: payload.home),
      operatorAddress: wallet.getAtlasAccount().address,
      nodeKeyToRemove: payload.blsRemoveKey,
      nodeKeyToAdd: payload.blsAddKey,
      nodeKeyToAddSig: payload.blsAddSign,
    );
    print(message);

    return signTransferHYN(password, wallet,
        toAddress: entity.to, message: message, gasPrice: entity.price);
  }

  static Future transTerminateMap3Node(
    String password,
    String map3NodeAddress,
    localWallet.Wallet wallet,
  ) async {
    var message = TerminateMap3NodeMessage(
      map3NodeAddress: map3NodeAddress,
      operatorAddress: wallet.getAtlasAccount().address,
    );
    print(message);

    return signTransferHYN(password, wallet, message: message);
  }

  static Future transMicroMap3Node(
    String staking,
    String password,
    String map3NodeAddress,
    localWallet.Wallet wallet,
  ) async {
    var amount = ConvertTokenUnit.decimalToWei(Decimal.parse(staking));
    var message = MicroDelegateMessage(
      amount: amount,
      map3NodeAddress: map3NodeAddress,
      delegatorAddress: wallet.getAtlasAccount().address,
    );
    print(message);

    return signTransferHYN(password, wallet, message: message);
  }

  static Future transUnMicroMap3Node(
    String staking,
    String password,
    String map3NodeAddress,
    localWallet.Wallet wallet,
  ) async {
    var amount = ConvertTokenUnit.decimalToWei(Decimal.parse(staking));
    var message = UnMicroDelegateMessage(
      amount: amount,
      map3NodeAddress: map3NodeAddress,
      delegatorAddress: wallet.getAtlasAccount().address,
    );
    print(message);

    return signTransferHYN(password, wallet, message: message);
  }

  static Future transCollectMap3Node(
    String password,
    localWallet.Wallet wallet,
  ) async {
    var message = CollectMicroRewardsMessage(
      delegatorAddress: wallet.getAtlasAccount().address,
    );
    print(message);

    return signTransferHYN(password, wallet, message: message);
  }

  static Future transPreEditMap3Node(
    String password,
    localWallet.Wallet wallet,
    bool isRenew,
    String feeRate,
    String map3NodeAddress,
  ) async {

    var newCommissionRate;
    if (feeRate != null) {
       var feeRateValue = ConvertTokenUnit.strToBigInt(feeRate) /
          BigInt.parse('100');

      newCommissionRate = BigInt.from(feeRateValue);
    }

    var message = RenewMap3NodeMessage(
      isRenew: isRenew,
      newCommissionRate: newCommissionRate, // 非管理传：null, []
      delegatorAddress: wallet.getAtlasAccount().address,
      map3NodeAddress: map3NodeAddress,
    );
    print(message);

    return sendTransferHYN(password, wallet, message: message);
  }

  static String getValueByHynType(
    int hynMessageType, {
    TransactionDetailVo transactionDetail,
    bool getTypeStr = false,
    bool getAmountStr = false,
  }) {
    String typeStr = "";
    String amountStr = "0";
    switch (hynMessageType) {
      case MessageType.typeNormal:
        typeStr = "转账";
        if(transactionDetail != null){
          if(transactionDetail.type == TransactionType.TRANSFER_IN){
            amountStr = "+${FormatUtil.stringFormatCoinNum(transactionDetail.amount.toString())}";
          }else if(transactionDetail.type == TransactionType.TRANSFER_OUT){
            amountStr = "-${FormatUtil.stringFormatCoinNum(transactionDetail.amount.toString())}";
          }
        }
        break;
      case MessageType.typeCreateValidator:
        typeStr = "创建Atlas";
        break;
      case MessageType.typeEditValidator:
        typeStr = "编辑Atlas";
        break;
      case MessageType.typeReDelegate:
        typeStr = "复抵押";
        break;
      case MessageType.typeUnReDelegate:
        typeStr = "取消复抵押";
        break;
      case MessageType.typeCollectReStakingReward:
        typeStr = "提取复抵押奖励";
        amountStr = "+${FormatUtil.stringFormatCoinNum(transactionDetail?.getAtlasRewardAmount() ?? "0.0")}";
        break;
      case MessageType.typeCreateMap3:
        typeStr = "创建Map3节点";
        amountStr = "-${FormatUtil.stringFormatCoinNum(transactionDetail?.getDecodedAmount() ?? "0.0")}";
        break;
      case MessageType.typeEditMap3:
        typeStr = "编辑Map3节点";
        break;
      case MessageType.typeTerminateMap3:
        typeStr = "终止Map3节点";
        break;
      case MessageType.typeMicroDelegate:
        typeStr = "微抵押";
        amountStr ="-${ FormatUtil.stringFormatCoinNum(transactionDetail?.getDecodedAmount() ?? "0.0")}";
        break;
      case MessageType.typeUnMicroDelegate:
        typeStr = "取消微抵押";
        amountStr ="+${ FormatUtil.stringFormatCoinNum(transactionDetail?.getDecodedAmount() ?? "0.0")}";
        break;
      case MessageType.typeCollectMicroStakingRewards:
        typeStr = "提取微抵押奖励";
        amountStr ="+${ FormatUtil.stringFormatCoinNum(transactionDetail?.getMap3RewardAmount() ?? "0.0")}";
        break;
      case MessageType.typeRenewMap3:
        typeStr = "续约";
        break;
    }

    if (getTypeStr) {
      return typeStr;
    }else if(getAmountStr){
      return amountStr;
    } else {
      return "";
    }
  }

  static String getHynToAddress(TransactionDetailVo transactionDetailVo) {
    String toAddressStr;
    switch (transactionDetailVo.hynType) {
      case MessageType.typeNormal:
        toAddressStr = transactionDetailVo.toAddress;
        break;
      default:
        toAddressStr = transactionDetailVo.contractAddress;
        break;
    }
    return toAddressStr;
  }
}
