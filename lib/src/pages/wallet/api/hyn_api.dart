import 'package:decimal/decimal.dart';
import 'package:titan/src/global.dart';
import 'package:titan/src/pages/atlas_map/entity/create_atlas_entity.dart';
import 'package:titan/src/pages/atlas_map/entity/create_map3_entity.dart';
import 'package:titan/src/pages/atlas_map/entity/map3_info_entity.dart';
import 'package:titan/src/pages/atlas_map/entity/pledge_atlas_entity.dart';
import 'package:titan/src/pages/wallet/model/transtion_detail_vo.dart';
import 'package:titan/src/plugins/wallet/convert.dart';
import 'package:titan/src/plugins/wallet/wallet.dart' as localWallet;
import 'package:titan/src/plugins/wallet/wallet_const.dart';

import 'package:web3dart/web3dart.dart';

class HYNApi {
  static Future transferHYN(
    String password,
    localWallet.Wallet wallet, {
    String toAddress,
    BigInt amount,
    IMessage message,
    bool isAtlasTrans = true
  }) async {
    var gasPrice = Decimal.fromInt(1 * TokenUnit.G_WEI);
    final txHash = await wallet.sendEthTransaction(
      password: password,
      toAddress: toAddress,
      gasPrice: BigInt.parse(gasPrice.toStringAsFixed(0)),
      value: amount,
      type: message?.type ?? MessageType.typeNormal,
      message: message,
      isAtlasTrans: isAtlasTrans
    );

    logger.i('HYN transaction committed，txHash $txHash');
  }

  static Future transCreateAtlasNode(
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
      operatorAddress: wallet.getAtlasAccount().address,
      slotPubKey: '2438b2439f5cec20d56c0948e557071a72d0ac9a113d627fafc1ad365802fb23919cd1bf07932ee0eb10e965147fe404',
      slotKeySig:
          '2a42c89854e15c8d5f6bde111217a53767c94c96ff061ea65a1f0f392fadafe383c6e94d1873956e399e0e869bb2cd11885fcb155eed2e783570a3b305b2c1c33ce846227458eec0abae735bf6460a25f70bf3d24da592790e59d826ca07e910',
    );
    print(message);

    transferHYN(password, wallet, message: message);
  }

  static Future transEditAtlasNode(
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
      operatorAddress: wallet.getAtlasAccount().address,
      slotKeyToRemove: "",
      slotKeyToAdd: '2438b2439f5cec20d56c0948e557071a72d0ac9a113d627fafc1ad365802fb23919cd1bf07932ee0eb10e965147fe404',
      slotKeyToAddSig:
          '2a42c89854e15c8d5f6bde111217a53767c94c96ff061ea65a1f0f392fadafe383c6e94d1873956e399e0e869bb2cd11885fcb155eed2e783570a3b305b2c1c33ce846227458eec0abae735bf6460a25f70bf3d24da592790e59d826ca07e910',
      eposStatus: 0, //0、 Active 1、Inactive 2、Banned
    );
    print(message);

    transferHYN(password, wallet, message: message);
  }

  static Future transAtlasReceiveReward(
    PledgeAtlasEntity pledgeAtlasEntity,
    String password,
    localWallet.Wallet wallet,
  ) async {
    var message = CollectAtlasRewardMessage(
        delegatorAddress: pledgeAtlasEntity.payload.map3Address,
        validatorAddress: pledgeAtlasEntity.payload.atlasAddress);
    print(message);

    transferHYN(password, wallet, message: message);
  }

  static Future transAtlasActive(
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

    transferHYN(password, wallet, message: message);
  }

  static Future transAtlasStake(
    PledgeAtlasEntity pledgeAtlasEntity,
    String password,
    localWallet.Wallet wallet,
  ) async {
    var message = ReDelegateAtlasMessage(
        delegatorAddress: pledgeAtlasEntity.payload.map3Address,
        validatorAddress: pledgeAtlasEntity.payload.atlasAddress);
    print(message);

    transferHYN(password, wallet, message: message);
  }

  static Future transAtlasUnStake(
      PledgeAtlasEntity pledgeAtlasEntity,
      String password,
      localWallet.Wallet wallet,
      ) async {
    var message = UnReDelegateAtlasMessage(
        delegatorAddress: pledgeAtlasEntity.payload.map3Address,
        validatorAddress: pledgeAtlasEntity.payload.atlasAddress);
    print(message);

    transferHYN(password, wallet, message: message);
  }

  //==================================Atlas Message End==============================================

  static Future transCreateMap3Node(
    CreateMap3Entity entity,
    String password,
    localWallet.Wallet wallet,
  ) async {
    var payload = entity.payload;
    var amount = ConvertTokenUnit.decimalToWei(Decimal.parse(entity.amount));
    var message = CreateMap3NodeMessage(
      amount: amount,
      commission: ConvertTokenUnit.strToBigInt(entity.payload.feeRate),
      //commission: BigInt.from(10).pow(17),
      // 0.1   10%手续费
      description: NodeDescription(
          name: payload.name,
          details: payload.describe,
          identity: payload.nodeId,
          securityContact: payload.connect,
          website: payload.home),
      operatorAddress: wallet.getAtlasAccount().address,
      nodePubKey: payload.blsAddKey,
      nodeKeySig: payload.blsAddSign,
      //nodePubKey: '5228b7f763038bb5b7638b624a56535a97b7e2cf6cba6e43d303d8919d7397fffd2eed7060bd29a13f5a9ab78994f614',
      //nodeKeySig: 'eb88a3e92d7e6a8c1b356730cda4e6ef24dec89fd2d5279761c50e0f71c6597f06aec6c861c884ee5b3f311832a0f9026d3864b9c116294333301999737ff2a02331ee9bdde89e3963ba794ceaedd3bfbf39243405c1b2f99a52ccf5aca0f411',
    );
    print(message);

    transferHYN(password, wallet, toAddress: entity.to, message: message, amount: amount);
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

    transferHYN(password, wallet, toAddress: entity.to, message: message);
  }

  static Future transTerminateMap3Node(
    String password,
    String toAddress,
    String map3NodeAddress,
    localWallet.Wallet wallet,
  ) async {
    var message = TerminateMap3NodeMessage(
      map3NodeAddress: map3NodeAddress,
      operatorAddress: wallet.getAtlasAccount().address,
    );
    print(message);

    transferHYN(password, wallet, toAddress: toAddress, message: message);
  }

  static Future transMicroMap3Node(
    String staking,
    String password,
    String toAddress,
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

    transferHYN(password, wallet, toAddress: toAddress, message: message, amount: amount);
  }

  static Future transUnMicroMap3Node(
    String staking,
    String password,
    String toAddress,
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

    transferHYN(password, wallet, toAddress: toAddress, message: message, amount: amount);
  }

  static Future transCollectMap3Node(
    String password,
    String toAddress,
    localWallet.Wallet wallet,
  ) async {
    var message = CollectMicroRewardsMessage(
      delegatorAddress: wallet.getAtlasAccount().address,
    );
    print(message);

    transferHYN(password, wallet, toAddress: toAddress, message: message);
  }

  static String getValueByHynType(int hynMessageType, {bool getTypeStr = false}){
    String typeStr;
    switch(hynMessageType){
      case MessageType.typeNormal:
        typeStr = "转账";
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
        break;
      case MessageType.typeCreateMap3:
        typeStr = "创建Map3";
        break;
      case MessageType.typeEditMap3:
        typeStr = "编辑Map3";
        break;
      case MessageType.typeTerminateMap3:
        typeStr = "终止Map3";
        break;
      case MessageType.typeMicroDelegate:
        typeStr = "微抵押";
        break;
      case MessageType.typeUnMicroDelegate:
        typeStr = "取消微抵押";
        break;
      case MessageType.typeCollectMicroStakingRewards:
        typeStr = "提取微抵押奖励";
        break;
    }

    if(getTypeStr){
      return typeStr;
    }

    return "";
  }

  static String getHynToAddress(TransactionDetailVo transactionDetailVo){
    String toAddressStr;
    switch(transactionDetailVo.hynType) {
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
