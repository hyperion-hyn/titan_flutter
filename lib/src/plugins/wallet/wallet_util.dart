import 'dart:typed_data';

import 'package:decimal/decimal.dart';
import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
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
      activeCoins: [CoinType.ETHEREUM],
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

  static Uint8List getErc20FuncAbi({
    String erc20Address,
    String funName,
    List<dynamic> params = const [],
  }) {
    final abiCode = EthereumConst.HYN_ERC20_ABI;
    final contract =
        web3.DeployedContract(web3.ContractAbi.fromJson(abiCode, 'HYN'), web3.EthereumAddress.fromHex(erc20Address));
    final func = contract.function(funName);
    return func.encodeCall(params);
  }

  static String getErc20FuncAbiHex({
    String ethAccountAddress,
    String erc20Address,
    String funName,
    List<dynamic> params = const [],
    bool include0x = true,
  }) {
    var abi = getErc20FuncAbi(erc20Address: erc20Address, params: params, funName: funName);
    return bytesToHex(abi, include0x: include0x);
  }

  static Wallet _parseWalletJson(dynamic map) {
    var keystore = KeyStore.fromDynamicMap(map);
    var accounts = List<Account>.from(
        map['accounts'].map((accountMap) => Account.fromJsonWithNet(accountMap, WalletConfig.isMainNet)));
    var wallet = Wallet(keystore: keystore, accounts: accounts);
    return wallet;
  }

  static web3.Web3Client _newWeb3Client() {
    return web3.Web3Client(WalletConfig.getInfuraApi(), Client());
  }

  static web3.DeployedContract _newHynContract(String contractAddress) {
    final contract = web3.DeployedContract(
        web3.ContractAbi.fromJson(EthereumConst.HYN_ERC20_ABI, 'HYN'), web3.EthereumAddress.fromHex(contractAddress));
    return contract;
  }

  /// https://infura.io/docs/gettingStarted/makeRequests.md
  static Future<dynamic> postInfura({String method, List params, int id = 1}) {
    return HttpCore.instance.post(WalletConfig.getInfuraApi(),
        params: {"jsonrpc": "2.0", "method": method, "params": params, "id": id},
        options: RequestOptions(contentType: Headers.jsonContentType));
  }

  static web3.DeployedContract _hynErc20Contract;
  static web3.Web3Client _web3clientMain;
  static web3.Web3Client _web3clientRopsten;

  static web3.DeployedContract getHynErc20Contract(String contractAddress) {
    if (_hynErc20Contract == null || _hynErc20Contract?.address?.hex?.contains(contractAddress) != true) {
      _hynErc20Contract = WalletUtil._newHynContract(contractAddress);
    }
    return _hynErc20Contract;
  }

  static web3.Web3Client getWeb3Client() {
    if (WalletConfig.isMainNet) {
      if (_web3clientMain == null) {
        _web3clientMain = WalletUtil._newWeb3Client();
      }
      return _web3clientMain;
    } else {
      if (_web3clientRopsten == null) {
        _web3clientRopsten = WalletUtil._newWeb3Client();
      }
      return _web3clientRopsten;
    }
  }

  static String formatCoinNum(double coinNum) {
    return NumberFormat("#,###.######").format(coinNum);
  }

  static String formatPrice(double price) {
    if(price >= 1){
      return NumberFormat("#,###.##").format(price);
    }else{
      return NumberFormat("#,###.####").format(price);
    }
  }

  static String formatPercentChange(double percentChange) {
    return NumberFormat("#,###.##").format(percentChange) + "%";
  }

}
