import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:titan/src/plugins/wallet/wallet.dart';

import 'package:web3dart/crypto.dart';

class Signer {
  static Future<String> signApiWithWallet(
    Wallet wallet,
    String password,
    String method, //GET, POST
    String host, //example: api.hyn.space
    String path, //example: /api/index/testWalletSign
    Map<String, dynamic> params,
  ) async {
    var msg = _formatSignString(
      method: method,
      host: host,
      path: path,
      params: params,
    );
    print('[Signer.signApiWithWallet]: msg: $msg');

    final credentials = await wallet.getCredentials(password);
    var msgHash = keccakUtf8(msg);
    var personalSign =
        await credentials.signPersonalMessage(utf8.encode(bytesToHex(msgHash)));
    return bytesToHex(personalSign);
  }

  static String signApiWithSecretKey({
    String secret,
    String method, //GET, POST
    String host, //example: api.hyn.space
    String path, //example: /api/index/testWalletSign
    Map<String, dynamic> params,
  }) {
    var msg = _formatSignString(
      method: method,
      host: host,
      path: path,
      params: params,
      onlySignParamsKeys: ['api', 'seed', 'sign_method', 'sign_ver', 'ts'],
    );

    var key = utf8.encode(secret);
    var hmac = Hmac(sha256, key);
    var digest = hmac.convert(utf8.encode(msg));
    print(bytesToHex(digest.bytes));
    return base64.encode(digest.bytes);
  }

  static String _formatSignString({
    String method, //GET, POST
    String host, //example: api.hyn.space
    String path, //example: /api/index/testWalletSign
    Map<String, dynamic> params,
    List<String> onlySignParamsKeys,
  }) {
    var msg = '$method\n$host\n$path\n';

    var paramsStr = '';
    var sortedParams = params.keys.toList()..sort();
    for (var k in sortedParams) {
      if (onlySignParamsKeys != null) {
        if (!onlySignParamsKeys.contains(k)) {
          continue;
        }
      }
      if (paramsStr != '') {
        paramsStr += '&';
      }
      paramsStr += '$k=${params[k].toString()}';
    }
    msg += paramsStr;
    return msg;
  }
}
