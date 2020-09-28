import 'package:decimal/decimal.dart';
import 'package:titan/src/components/setting/setting_component.dart';
import 'package:titan/src/config/consts.dart';
import 'package:titan/src/global.dart';
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

}