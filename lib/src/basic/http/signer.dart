import 'dart:convert';
import 'dart:typed_data';

import 'package:titan/src/plugins/wallet/wallet.dart' as plugin;
import 'package:web3dart/crypto.dart';

class Signer {
  static Future<String> signApi(
    plugin.Wallet wallet,
    String password,
    String method, //GET, POST
    String host, //example: api.hyn.space
    String path, //example: /api/index/testWalletSign
    Map<String, dynamic> params,
  ) async {
    var msg = '$method\n$host\n$path\n';

    var paramsStr = '';
    var sortedParams = params.keys.toList()..sort();
    for (var k in sortedParams) {
      if (paramsStr != '') {
        paramsStr += '&';
      }
      paramsStr += '$k=${params[k].toString()}';
    }
    msg += paramsStr;

    final credentials = await wallet.getCredentials(password);
    var msgHash = keccakUtf8(msg);
    print("$msg ${bytesToHex(msgHash)} ${wallet.getEthAccount().address}");
    var personalSign = await credentials.signPersonalMessage(utf8.encode(bytesToHex(msgHash)));
    return bytesToHex(personalSign);
  }

  static Future<String> signMessage(plugin.Wallet wallet, String password, Map<String, dynamic> params) async {
//    params['t'] = DateTime.now().millisecondsSinceEpoch;
    var sortedParams = params.keys.toList()..sort();
    var msg = '';
    for (var k in sortedParams) {
      if (msg != '') {
        msg += '&';
      }
      msg += '$k=${params[k].toString()}';
    }

//    final client = WalletUtil.getWeb3Client();
    final credentials = await wallet.getCredentials(password);

    var msgHash = keccakUtf8(msg);
//    m = utf8.encode('I like signatures');
    print("$msg ${bytesToHex(msgHash)} ${wallet.getEthAccount().address}");
    var personalSign = await credentials.signPersonalMessage(utf8.encode(bytesToHex(msgHash)));
    return bytesToHex(personalSign);
//    print(bytesToHex(personalSign));

//    var signed = await client.signTransaction(
//        credentials,
//        Transaction(
//          from: EthereumAddress.fromHex(wallet.wallet.getEthAccount().address),
//          data: keccakUtf8(msg),
//          to: EthereumAddress.fromHex(wallet.wallet.getEthAccount().address),
//          nonce: 0,
//          gasPrice: EtherAmount.inWei(BigInt.one),
//          maxGas: 1,
//          value: EtherAmount.inWei(BigInt.zero),
//        ),
//        chainId: 8888);
//
//    params['sign'] = bytesToHex(signed);
  }
}

Uint8List uint8ListFromList(List<int> data) {
  if (data is Uint8List) return data;

  return Uint8List.fromList(data);
}
