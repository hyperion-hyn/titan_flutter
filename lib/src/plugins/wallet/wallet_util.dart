import 'package:decimal/decimal.dart';
import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';
import 'package:titan/src/basic/http/http.dart';
import 'package:titan/src/plugins/wallet/account.dart';
import 'package:titan/src/plugins/wallet/cointype.dart';
import 'package:titan/src/plugins/wallet/keystore.dart';
import 'package:titan/src/plugins/wallet/wallet.dart';
import 'package:titan/src/plugins/wallet/wallet_channel.dart';
import 'package:http/http.dart';
import 'package:web3dart/crypto.dart';
import 'package:web3dart/web3dart.dart' as web3;
import 'package:bip39/bip39.dart' as bip39;

class WalletUtil {
  static Future<String> makeMnemonic() {
//    return WalletChannel.makeMnemonic();
    return Future.value(bip39.generateMnemonic(strength: 128));
  }

  ///scan all wallets
  static Future<List<Wallet>> scanWallets() async {
    var wallets = <Wallet>[];

    var keyStoreMaps = await WalletChannel.scanKeyStores();
    for (var map in keyStoreMaps) {
//      logger.i(map);
      var wallet = _parseWalletJson(map);
      if (wallet != null) {
        wallets.add(wallet);
      }
    }
    return wallets;
  }

  ///store mnemonic
  static Future<Wallet> storeByMnemonic(
      {@required String name, @required String password, @required String mnemonic}) async {
    var fileName = await WalletChannel.saveAsTrustWalletKeyStoreByMnemonic(
      name: name,
      mnemonic: mnemonic,
      password: password,
    );
    return loadWallet(fileName);
  }

  ///store private key
  static Future<Wallet> storePrivateKey(
      {@required String name, @required String password, @required String prvKeyHex}) async {
    var fileName =
        await WalletChannel.saveAsTrustWalletKeyStoreByPrivateKey(name: name, prvKeyHex: prvKeyHex, password: password);
    return loadWallet(fileName);
  }

  ///store Json
  static Future<Wallet> storeJson(
      {@required String name,
      @required String password,
      @required String newPassword,
      @required String keyStoreJson}) async {
    var fileName = await WalletChannel.saveKeyStoreByJson(
      name: name,
      keyStoreJson: keyStoreJson,
      password: password,
      newPassword: newPassword,
    );
    return loadWallet(fileName);
  }

  ///get eth gas price
  static Future<BigInt> ethGasPrice({int requestId = 1}) async {
    var response = await postInfura(method: 'eth_gasPrice', params: []);
    if (response['result'] != null) {
      BigInt gasPrice = hexToInt(response['result']);
      return gasPrice;
    }
    return BigInt.from(0);
  }

  ///estimate eth gas
  ///return amountUsed * lastEthGasPrice
  static Future<BigInt> estimateGas({
    @required String fromAddress,
    @required String toAddress,
    @required int coinType,
    @required String amount,
    String erc20ContractAddress,
  }) {
    return WalletChannel.estimateGas(
      fromAddress: fromAddress,
      toAddress: toAddress,
      coinType: coinType,
      amount: amount,
      erc20ContractAddress: erc20ContractAddress,
      isMainNet: WalletConfig.isMainNet,
    );
  }

  static Future<String> transfer({
    @required String password,
    @required String fileName,
    @required String fromAddress,
    @required String toAddress,
    @required String amount,
    @required int coinType,
    String data,
  }) {
    return WalletChannel.transfer(
      password: password,
      fileName: fileName,
      fromAddress: fromAddress,
      toAddress: toAddress,
      amount: amount,
      coinType: coinType,
      isMainNet: WalletConfig.isMainNet,
      data: data,
    );
  }

  static Future<String> transferErc20Token({
    @required String password,
    @required String fileName,
    @required String fromAddress,
    @required String toAddress,
    @required String amount,
    @required String erc20ContractAddress,
    String data,
  }) {
    return WalletChannel.transfer(
      password: password,
      fileName: fileName,
      fromAddress: fromAddress,
      toAddress: toAddress,
      amount: amount,
      coinType: CoinType.ETHEREUM,
      erc20ContractAddress: erc20ContractAddress,
      isMainNet: WalletConfig.isMainNet,
      data: data,
    );
  }

  static Future<String> exportPrivateKey({
    @required String fileName,
    @required password,
  }) {
    return WalletChannel.exportPrivateKey(fileName: fileName, password: password);
  }

  static Future<String> exportMnemonic({
    @required String fileName,
    @required password,
  }) {
    return WalletChannel.exportMnemonic(fileName: fileName, password: password);
  }

  static Future<bool> changePassword({
    @required String oldPassword,
    @required String newPassword,
    @required Wallet wallet,
    String name,
  }) async {
    bool result = await wallet.keystore.changePassword(
      oldPassword: oldPassword,
      newPassword: newPassword,
      name: name,
    );
    return result;
  }

  ///load wallet
  static Future<Wallet> loadWallet(String fileName) async {
    var map = await WalletChannel.loadKeyStore(fileName);
    var wallet = _parseWalletJson(map);
    return wallet;
  }

  static Wallet _parseWalletJson(dynamic map) {
    var keystore = KeyStore.fromDynamicMap(map);
    var accounts = List<Account>.from(
        map['accounts'].map((accountMap) => Account.fromJsonWithNet(accountMap, WalletConfig.isMainNet)));
    var wallet = Wallet(keystore: keystore, accounts: accounts);
    return wallet;
  }

  static web3.Web3Client newWeb3Client() {
    return web3.Web3Client(WalletConfig.getInfuraApi(), Client());
  }

  static web3.DeployedContract newHynContract(String contractAddress) {
    final contract = web3.DeployedContract(
        web3.ContractAbi.fromJson(WalletConfig.HYN_ERC20_ABI, 'HYN'), web3.EthereumAddress.fromHex(contractAddress));
    return contract;
  }

  static Future<dynamic> postInfura({String method, List params, int id = 1}) {
    return HttpCore.instance.post(WalletConfig.getInfuraApi(),
        params: {"jsonrpc": "2.0", "method": method, "params": params, "id": id},
        options: RequestOptions(contentType: Headers.jsonContentType));
  }
}
