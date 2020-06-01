import 'package:flutter/cupertino.dart';
import 'package:titan/generated/l10n.dart';
import 'package:titan/src/components/wallet/wallet_component.dart';
import 'package:titan/src/plugins/wallet/wallet_util.dart';
import 'package:web3dart/crypto.dart';
import 'package:web3dart/web3dart.dart';

class Signer {
  static Future signMessage(BuildContext context, String password, Map<String, dynamic> params) async {
    var wallet = WalletInheritedModel.of(context).activatedWallet;
    if (wallet == null) {
      throw S.of(context).cannot_fint_wallet;
    }

    params['t'] = DateTime.now().millisecondsSinceEpoch;
    var sortedParams = params.keys.toList()..sort();
    var msg = '';
    for (var k in sortedParams) {
      if (msg != '') {
        msg += '&';
      }
      msg += '$k=${params[k].toString()}';
    }

    final client = WalletUtil.getWeb3Client();
    final credentials = await wallet.wallet.getCredentials(password);
    var signed = await client.signTransaction(
        credentials,
        Transaction(
          from: EthereumAddress.fromHex(wallet.wallet.getEthAccount().address),
          data: keccakUtf8(msg),
          to: EthereumAddress.fromHex(wallet.wallet.getEthAccount().address),
          nonce: 0,
          gasPrice: EtherAmount.inWei(BigInt.one),
          maxGas: 1,
          value: EtherAmount.inWei(BigInt.zero),
        ),
        chainId: 8888);

    params['sign'] = bytesToHex(signed);
  }
}
