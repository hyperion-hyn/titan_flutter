import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:titan/generated/l10n.dart';
import 'package:titan/src/components/wallet/wallet_component.dart';
import 'package:titan/src/plugins/wallet/wallet_util.dart';
import 'package:web3dart/crypto.dart';
import 'package:web3dart/web3dart.dart';

class Signer {
  static const _messagePrefix = '\u0019Ethereum Signed Message:\n';

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



    var m = keccakUtf8('I like signatures');
    m = utf8.encode('I like signatures');
    print("长度: ${uint8ListFromList(m).length} ${bytesToHex(m)}");
    var personalSign = await credentials.signPersonalMessage(m);
    print(bytesToHex(personalSign));

    final prefix = _messagePrefix + m.length.toString();
    final prefixBytes = ascii.encode(prefix);

    // will be a Uint8List, see the documentation of Uint8List.+
    final concat = uint8ListFromList(prefixBytes + m);
    print('xxx1');
    print(bytesToHex(keccak256(concat)));
    
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

Uint8List uint8ListFromList(List<int> data) {
  if (data is Uint8List) return data;

  return Uint8List.fromList(data);
}