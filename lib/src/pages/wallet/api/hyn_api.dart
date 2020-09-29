import 'package:decimal/decimal.dart';
import 'package:titan/src/components/setting/setting_component.dart';
import 'package:titan/src/config/consts.dart';
import 'package:titan/src/global.dart';
import 'package:titan/src/plugins/wallet/convert.dart';
import 'package:titan/src/plugins/wallet/wallet.dart' as localWallet;
import 'package:titan/src/plugins/wallet/wallet_const.dart';
import 'package:web3dart/web3dart.dart' as web3;
import 'package:web3dart/web3dart.dart';

class HYNApi{

  static Future transferHYN(String password, BigInt amount, String toAddress, localWallet.Wallet wallet) async {
    var gasPrice = Decimal.fromInt(1 * TokenUnit.G_WEI);
    final txHash = await wallet.sendEthTransaction(
      password: password,
      toAddress: toAddress,
      gasPrice: BigInt.parse(gasPrice.toStringAsFixed(0)),
      value: amount,
      type: MessageType.typeNormal,
    );

    logger.i('HYN atlas transaction committed，txhash $txHash');
  }

  static Future transCreateAtlasNode(Decimal maxChangeRate, Decimal maxRate, Decimal rate, BigInt maxTotalDelegation, String password, BigInt amount, String toAddress, localWallet.Wallet wallet) async {
    var createAtlasNodeMessage = CreateAtlasNodeMessage(
      maxChangeRate: ConvertTokenUnit.decimalToWei(maxChangeRate),
      maxRate: ConvertTokenUnit.decimalToWei(maxRate),
      rate: ConvertTokenUnit.decimalToWei(rate),
      maxTotalDelegation: ConvertTokenUnit.bigintToWei(maxTotalDelegation),
      description: NodeDescription(
          name: 'moo',
          details: 'moo_detail',
          identity: 'moo_idx',
          securityContact: 'moo_contact',
          website: 'moo_website'),
      operatorAddress: wallet.getAtlasAccount().address,
      slotPubKey: '2438b2439f5cec20d56c0948e557071a72d0ac9a113d627fafc1ad365802fb23919cd1bf07932ee0eb10e965147fe404',
      slotKeySig: '2a42c89854e15c8d5f6bde111217a53767c94c96ff061ea65a1f0f392fadafe383c6e94d1873956e399e0e869bb2cd11885fcb155eed2e783570a3b305b2c1c33ce846227458eec0abae735bf6460a25f70bf3d24da592790e59d826ca07e910',
    );
    print(createAtlasNodeMessage);

    var gasPrice = Decimal.fromInt(1 * TokenUnit.G_WEI);
    final txHash = await wallet.sendEthTransaction(
      password: password,
      toAddress: toAddress,
      gasPrice: BigInt.parse(gasPrice.toStringAsFixed(0)),
      type: createAtlasNodeMessage.type,
      message: createAtlasNodeMessage
    );

    logger.i('HYN atlas transaction committed，txhash $txHash');
  }

}