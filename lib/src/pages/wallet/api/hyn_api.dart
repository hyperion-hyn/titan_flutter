import 'package:decimal/decimal.dart';
import 'package:titan/src/global.dart';
import 'package:titan/src/pages/atlas_map/entity/create_map3_entity.dart';
import 'package:titan/src/pages/atlas_map/entity/map3_info_entity.dart';
import 'package:titan/src/plugins/wallet/convert.dart';
import 'package:titan/src/plugins/wallet/wallet.dart' as localWallet;
import 'package:titan/src/plugins/wallet/wallet_const.dart';

// import 'package:web3dart/web3dart.dart' as web3;
import 'package:web3dart/web3dart.dart';

class HYNApi {
  static Future transferHYN(
    String password,
    String toAddress,
    localWallet.Wallet wallet, {
    BigInt amount,
    int type,
  }) async {
    var gasPrice = Decimal.fromInt(1 * TokenUnit.G_WEI);
    final txHash = await wallet.sendEthTransaction(
      password: password,
      toAddress: toAddress,
      gasPrice: BigInt.parse(gasPrice.toStringAsFixed(0)),
      value: amount,
      type: type ?? MessageType.typeNormal,
    );

    logger.i('HYN transaction committed，txHash $txHash');
  }

  static Future transCreateAtlasNode(
    Decimal maxChangeRate,
    Decimal maxRate,
    Decimal rate,
    BigInt maxTotalDelegation,
    String password,
    BigInt amount,
    String toAddress,
    Map3InfoEntity entity,
    localWallet.Wallet wallet,
  ) async {
    var message = CreateAtlasNodeMessage(
      maxChangeRate: ConvertTokenUnit.decimalToWei(maxChangeRate),
      maxRate: ConvertTokenUnit.decimalToWei(maxRate),
      rate: ConvertTokenUnit.decimalToWei(rate),
      maxTotalDelegation: ConvertTokenUnit.bigintToWei(maxTotalDelegation),
      description: NodeDescription(
          name: entity.name,
          details: entity.describe,
          identity: entity.nodeId,
          securityContact: entity.contact,
          website: entity.home),
      operatorAddress: wallet.getAtlasAccount().address,
      slotPubKey: '2438b2439f5cec20d56c0948e557071a72d0ac9a113d627fafc1ad365802fb23919cd1bf07932ee0eb10e965147fe404',
      slotKeySig:
          '2a42c89854e15c8d5f6bde111217a53767c94c96ff061ea65a1f0f392fadafe383c6e94d1873956e399e0e869bb2cd11885fcb155eed2e783570a3b305b2c1c33ce846227458eec0abae735bf6460a25f70bf3d24da592790e59d826ca07e910',
    );
    print(message);

    transferHYN(password, toAddress, wallet, type: message.type, amount: amount);
  }

  static Future transCreateMap3Node(
      CreateMap3Entity entity,
    String password,
    localWallet.Wallet wallet,
  ) async {
    var payload = entity.payload;
    var amount = ConvertTokenUnit.decimalToWei(Decimal.parse(entity.amount));
    var message = CreateMap3NodeMessage(
      amount: amount,
      commission: BigInt.from(10).pow(17),
      // 0.1   10%手续费
      description: NodeDescription(
          name: payload.name,
          details: payload.describe,
          identity: payload.nodeId,
          securityContact: payload.connect,
          website: payload.home),
      operatorAddress: wallet.getAtlasAccount().address,
      // todo: test
      nodePubKey: payload.region,
      nodeKeySig: payload.provider,
      //nodePubKey: '5228b7f763038bb5b7638b624a56535a97b7e2cf6cba6e43d303d8919d7397fffd2eed7060bd29a13f5a9ab78994f614',
      //nodeKeySig: 'eb88a3e92d7e6a8c1b356730cda4e6ef24dec89fd2d5279761c50e0f71c6597f06aec6c861c884ee5b3f311832a0f9026d3864b9c116294333301999737ff2a02331ee9bdde89e3963ba794ceaedd3bfbf39243405c1b2f99a52ccf5aca0f411',
    );
    print(message);

    transferHYN(password, entity.to, wallet, type: message.type, amount: amount);
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
      // todo: test
      nodeKeyToRemove: payload.region,
      nodeKeyToAdd: payload.region,
      nodeKeyToAddSig: payload.provider,
    );
    print(message);

    transferHYN(password, entity.to, wallet, type: message.type);
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

    transferHYN(password, toAddress, wallet, type: message.type);
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

    transferHYN(password, toAddress, wallet, type: message.type, amount: amount);
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

    transferHYN(password, toAddress, wallet, type: message.type, amount: amount);
  }

  static Future transCollectMap3Node(
    String password,
    String toAddress,
    String map3NodeAddress,
    localWallet.Wallet wallet,
  ) async {
    var message = CollectMicroRewardsMessage(
      delegatorAddress: wallet.getAtlasAccount().address,
    );
    print(message);

    transferHYN(password, toAddress, wallet, type: message.type);
  }
}
