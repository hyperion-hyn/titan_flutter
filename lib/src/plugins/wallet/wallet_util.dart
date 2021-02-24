import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:titan/env.dart';
import 'package:titan/src/basic/error/error_code.dart';
import 'package:titan/src/basic/http/http.dart';
import 'package:titan/src/basic/http/my_client.dart';
import 'package:titan/src/components/wallet/vo/coin_view_vo.dart';
import 'package:titan/src/config/consts.dart';
import 'package:titan/src/data/cache/app_cache.dart';
import 'package:titan/src/plugins/wallet/account.dart';
import 'package:titan/src/plugins/wallet/cointype.dart';
import 'package:titan/src/plugins/wallet/config/ethereum.dart';
import 'package:titan/src/plugins/wallet/config/heco.dart';
import 'package:titan/src/plugins/wallet/config/hyperion.dart';
import 'package:titan/src/plugins/wallet/hyn_erc20_abi.dart';
import 'package:titan/src/plugins/wallet/keystore.dart';
import 'package:titan/src/plugins/wallet/map3_staking_abi.dart';
import 'package:titan/src/plugins/wallet/rp_holding_abi.dart';
import 'package:titan/src/plugins/wallet/wallet.dart';
import 'package:titan/src/plugins/wallet/wallet_channel.dart';
import 'package:http/http.dart';
import 'package:titan/src/plugins/wallet/wallet_expand_info_entity.dart';
import 'package:web3dart/crypto.dart';
import 'package:web3dart/json_rpc.dart';
import 'package:web3dart/web3dart.dart' as web3;
import 'package:bip39/bip39.dart' as bip39;

import 'hyn_staking_abi.dart';

typedef web3.DeployedContract ContractMaker(String contractAddress, String name);

class WalletUtil {
  static Future<String> makeMnemonic() {
//    return WalletChannel.makeMnemonic();
    return Future.value(bip39.generateMnemonic(strength: 128));
  }

  static Future<List<Wallet>> getNotBackUpWalletList() async {
    var notBackUpWalletList = List<Wallet>();
    try {
      var wallets = await WalletUtil.scanWallets();

      ///add await or will pass loop
      await wallets.forEach((wallet) async {
        var isBackUp = wallet.walletExpandInfoEntity.isBackup;
        if (!isBackUp) notBackUpWalletList.add(wallet);
      });
    } catch (e) {}

    return notBackUpWalletList;
  }

  static Future<bool> checkWalletSafeLockIsEnable(
    String walletAddress,
  ) async {
    bool isEnabled =
        await AppCache.getValue('${PrefsKey.WALLET_SAFE_LOCK_IS_ENABLE_PREFIX}_$walletAddress');

    return (isEnabled ?? false);
  }

  static setWalletSafeLockEnable(
    bool enabled,
  ) async {
    await AppCache.saveValue(
      '${PrefsKey.WALLET_SAFE_LOCK_IS_ENABLE_PREFIX}',
      enabled,
    );
  }

  static Future<bool> checkWalletSafeLockPwd(
    String input,
  ) async {
    String pwd = await AppCache.secureGetValue(
      '${PrefsKey.WALLET_SAFE_LOCK_PWD_PREFIX}',
    );
    return (pwd == (input ?? ''));
  }

  static setWalletSafeLockPwd(
    String walletAddress,
    String pwd,
  ) async {
    await AppCache.secureSaveValue(
      '${PrefsKey.WALLET_SAFE_LOCK_PWD_PREFIX}_$walletAddress',
      pwd,
    );
  }

  static Future<bool> setWalletExpandInfo(
    String walletAddress,
    WalletExpandInfoEntity walletExpandInfoEntity,
  ) async {
    if (walletExpandInfoEntity == null) {
      return AppCache.remove("${PrefsKey.WALLET_EXPAND_INFO_PREFIX}$walletAddress");
    } else {
      return AppCache.saveValue(
        "${PrefsKey.WALLET_EXPAND_INFO_PREFIX}$walletAddress",
        "${json.encode(walletExpandInfoEntity.toJson())}",
      );
    }
  }

  static Future<WalletExpandInfoEntity> getWalletExpandInfo(
    String walletAddress,
  ) async {
    String entityStr = await AppCache.getValue(
      '${PrefsKey.WALLET_EXPAND_INFO_PREFIX}$walletAddress',
    );
    if (entityStr == null) {
      return null;
    }
    return WalletExpandInfoEntity.fromJson(json.decode(entityStr));
  }

  ///scan all wallets
  static Future<List<Wallet>> scanWallets() async {
    var wallets = <Wallet>[];

    var keyStoreMaps = await WalletChannel.scanKeyStores();
    for (var map in keyStoreMaps) {
//      logger.i(map);
      var wallet = await _parseWalletJson(map);
      if (wallet != null) {
        // wallet.walletExpandInfoEntity =
        //     await WalletUtil.getWalletExpandInfo(wallet.getEthAccount().address) ??
        //         WalletExpandInfoEntity.defaultEntity();
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
      activeCoins: [CoinType.ETHEREUM, CoinType.BITCOIN],
    );
    return loadWallet(fileName);
  }

  ///store private key
  static Future<Wallet> storePrivateKey(
      {@required String name, @required String password, @required String prvKeyHex}) async {
    var fileName = await WalletChannel.saveAsTrustWalletKeyStoreByPrivateKey(
        name: name, prvKeyHex: prvKeyHex, password: password);
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
  static Future<BigInt> ethGasPrice(int coinType, {int requestId = 1}) async {
    var response = await postToEthereumNetwork(coinType, method: 'eth_gasPrice', params: []);
    if (response['result'] != null) {
      BigInt gasPrice = hexToInt(response['result']);
      return gasPrice;
    }
    return BigInt.from(0);
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

  static useDigitsPwd(Wallet wallet) {
    AppCache.saveValue<bool>(
      '${PrefsKey.WALLET_USE_DIGITS_PWD_PREFIX}_${wallet.keystore.fileName}',
      true,
    );
  }

  static checkUseDigitsPwd(Wallet wallet) async {
    var result = await AppCache.getValue<bool>(
        '${PrefsKey.WALLET_USE_DIGITS_PWD_PREFIX}_${wallet.keystore.fileName}');
    return result != null && result;
  }

  static Future<bool> checkPwdValid(
    BuildContext context,
    Wallet wallet,
    String walletPwd,
  ) async {
    String result;
    try {
      result = await WalletUtil.exportPrivateKey(
        fileName: wallet.keystore.fileName,
        password: walletPwd,
      );
    } on PlatformException catch (e) {
      result = null;
      print(e);
    }
    if (result != null) {
      return true;
    } else {
      return false;
    }
  }

  static getPwdFromSecureStorage(
    BuildContext context,
    Wallet wallet,
  ) async {
    String pwd = await AppCache.secureGetValue(
        '${SecurePrefsKey.WALLET_PWD_KEY_PREFIX}${wallet.keystore.fileName}');

    ///Check password from secureStorage is correct
    String result;
    try {
      result = await WalletUtil.exportPrivateKey(
        fileName: wallet.keystore.fileName,
        password: pwd,
      );
    } catch (e) {}
    if (result != null) {
      return pwd;
    } else {
      return null;
    }
  }

  static savePwdToSecureStorage(
    BuildContext context,
    Wallet wallet,
    String password,
  ) async {
    await AppCache.secureSaveValue(
      '${SecurePrefsKey.WALLET_PWD_KEY_PREFIX}${wallet.keystore.fileName}',
      password,
    );
  }

  static Future<bool> updateWallet({
    @required String password,
    String newPassword,
    @required Wallet wallet,
    String name,
  }) async {
    bool result = await wallet.keystore.updateWallet(
      password: password,
      newPassword: newPassword,
      name: name,
    );
    return result;
  }

  ///load wallet
  static Future<Wallet> loadWallet(String fileName) async {
    var map = await WalletChannel.loadKeyStore(fileName);
    var wallet = await _parseWalletJson(map);
    return wallet;
  }

  static Uint8List getErc20FuncAbi({
    String contractAddress,
    String funName,
    List<dynamic> params = const [],
  }) {
    final contract = getErc20Contract(contractAddress, 'HYN');
    final func = contract.function(funName);
    return func.encodeCall(params);
  }

  static Uint8List getMap3FuncAbi({
    String contractAddress,
    String funName,
    List<dynamic> params = const [],
  }) {
    final contract = getMap3Contract(contractAddress);
    final func = contract.function(funName);
    return func.encodeCall(params);
  }

  static String getErc20FuncAbiHex(
      {String contractAddress,
      String funName,
      List<dynamic> params = const [],
      bool include0x = true,
      bool padToEvenLength = true}) {
    var abi = getErc20FuncAbi(contractAddress: contractAddress, params: params, funName: funName);
    return bytesToHex(abi, include0x: include0x, padToEvenLength: padToEvenLength);
  }

  static String getMap3FuncAbiHex(
      {String contractAddress,
      String funName,
      List<dynamic> params = const [],
      bool include0x = true,
      bool padToEvenLength = true}) {
    var abi = getMap3FuncAbi(contractAddress: contractAddress, params: params, funName: funName);
    return bytesToHex(abi, include0x: include0x, padToEvenLength: padToEvenLength);
  }

  static Future<Wallet> _parseWalletJson(dynamic map) async {
    var keystore = KeyStore.fromDynamicMap(map);
    var backAccounts = [];
    var ethAddress;
    for (var account in map['accounts']) {
      if (account['coinType'] == CoinType.ETHEREUM) {
        // add hyperion tokens
        backAccounts.add({
          "address": account["address"],
          "derivationPath": account['derivationPath'],
          'coinType': CoinType.HYN_ATLAS,
        });

        ethAddress = account["address"];
      }

      // add ethereum tokens
      backAccounts.add(account);

      // add Huobi ECO Chain tokens
      if (account['coinType'] == CoinType.ETHEREUM) {
        // add huobi heco tokens
        backAccounts.add({
          "address": account["address"],
          "derivationPath": account['derivationPath'],
          'coinType': CoinType.HB_HT,
        });
      }
    }

    var walletExpandInfoEntity = WalletExpandInfoEntity.defaultEntity();
    if (ethAddress != null && ethAddress != '') {
      walletExpandInfoEntity = ((await WalletUtil.getWalletExpandInfo(ethAddress)) ??
          WalletExpandInfoEntity.defaultEntity());
    }

    var accounts = List<Account>.from(
        backAccounts.map((accountMap) => Account.mainAccountFromJson(accountMap)));

    //filter only ETHEREUM
//    accounts = accounts.where((account) {
//      return account.coinType == CoinType.ETHEREUM;
//    }).toList();

    var wallet = Wallet(
        keystore: keystore, accounts: accounts, walletExpandInfoEntity: walletExpandInfoEntity);
    return wallet;
  }

  static web3.Web3Client _newWeb3Client(String api) {
    return web3.Web3Client(api, MyClient(isPrintLog: env.buildType != BuildType.PROD));
  }

  static web3.DeployedContract _newErc20Contract(String contractAddress, String name) {
    final contract = web3.DeployedContract(web3.ContractAbi.fromJson(HYN_ERC20_ABI, name),
        web3.EthereumAddress.fromHex(contractAddress));
    return contract;
  }

  static web3.DeployedContract _newRpHoldingContract(String contractAddress, String name) {
    final contract = web3.DeployedContract(web3.ContractAbi.fromJson(RP_HOLDING_ABI, name),
        web3.EthereumAddress.fromHex(contractAddress));
    return contract;
  }

  static web3.DeployedContract _newMap3Contract(String contractAddress, String name) {
    final contract = web3.DeployedContract(web3.ContractAbi.fromJson(MAP3_STAKING_ABI, name),
        web3.EthereumAddress.fromHex(contractAddress));
    return contract;
  }

  static web3.DeployedContract _newHynStakingContract(String contractAddress, String name) {
    final contract = web3.DeployedContract(web3.ContractAbi.fromJson(HYN_STAKING_ABI, name),
        web3.EthereumAddress.fromHex(contractAddress));
    return contract;
  }

  /// https://infura.io/docs/gettingStarted/makeRequests.md
  static Future<dynamic> postToEthereumNetwork(int coinType,
      {String method, List params, int id = 1}) async {
    //{jsonrpc: 2.0, id: 1, result: 0x4547fdfbf3f1cfd25c0fa7267a97c7832ddda76352456b8e78898e9bd619adb7}
    var rpcApi = _getRpcApiByCoinType(coinType);
    var data = await HttpCore.instance.post(rpcApi,
        params: {"jsonrpc": "2.0", "method": method, "params": params, "id": id},
        options: RequestOptions(contentType: Headers.jsonContentType));

    if (data.containsKey('error') && data['error'] != null) {
      final error = data['error'];
      final code = error['code'] as int;
      final message = error['message'] as String;
      final errorData = error['data'];

      throw RPCError(code, message, errorData);
    }

    //亚马逊错误???
    if (!data.containsKey('result') && !data.containsKey('jsonrpc')) {
      throw RPCError(0, data.toString(), "");
    }

    if (data.containsKey('code') && data['code'] != null && data['code'] != 200) {
      final code = data['code'] as int;
      final message = data['msg'] as String;
      final errorData = data['subMsg'];

      throw RPCError(code, message, errorData);
    }

    return data;
  }

  /// address, contractInstance
  static Map<String, web3.DeployedContract> deployedContractMap = {};

  /// coinType_chainType, clientInstance
  static Map<String, web3.Web3Client> web3ClientMap = {};

  static web3.DeployedContract _getContract(
      ContractMaker maker, String contractAddress, String name) {
    if (deployedContractMap.containsKey(contractAddress) == null) {
      return deployedContractMap[contractAddress];
    }
    var contract = maker(contractAddress, name);
    deployedContractMap[contractAddress] = contract;
    return contract;
  }

  static web3.DeployedContract getErc20Contract(String contractAddress, String symbol) {
    return _getContract(WalletUtil._newErc20Contract, contractAddress, symbol);
  }

  static web3.DeployedContract getRpHoldingContract(String contractAddress) {
    return _getContract(WalletUtil._newRpHoldingContract, contractAddress, 'RpHolding');
  }

  static web3.DeployedContract getMap3Contract(String contractAddress) {
    return _getContract(WalletUtil._newMap3Contract, contractAddress, 'Map3Staking');
  }

  static web3.DeployedContract getHynStakingContract(String contractAddress) {
    return _getContract(WalletUtil._newHynStakingContract, contractAddress, 'HynStaking');
  }

  static web3.Web3Client getWeb3Client(int coinType, [bool printResponse = false]) {
    var key = _web3ClientMapKey(coinType);
    if (web3ClientMap.containsKey(key)) {
      return web3ClientMap[key];
    }

    var rpcApi = _getRpcApiByCoinType(coinType);
    var web3Client = WalletUtil._newWeb3Client(rpcApi);
    web3Client.printResponse = printResponse;
    web3ClientMap[key] = web3Client;
    return web3Client;
  }

  static String _getRpcApiByCoinType(int coinType) {
    var rpcApi = '';
    if (coinType == CoinType.HYN_ATLAS) {
      rpcApi = HyperionRpcProvider.rpcUrl;
    } else if (coinType == CoinType.ETHEREUM) {
      rpcApi = EthereumRpcProvider.rpcUrl;
    } else if (coinType == CoinType.HB_HT) {
      rpcApi = HecoRpcProvider.rpcUrl;
    }
    return rpcApi;
  }

  static String _web3ClientMapKey(int coinType) {
    var key = '$coinType';
    if (coinType == CoinType.HYN_ATLAS) {
      key = '${coinType}_${HyperionConfig.chainType.toString()}';
    } else if (coinType == CoinType.ETHEREUM) {
      key = '${coinType}_${EthereumConfig.chainType.toString()}';
    } else if (coinType == CoinType.HB_HT) {
      key = '${coinType}_${HecoConfig.chainType.toString()}';
    }
    return key;
  }

  static Future<BigInt> getBalanceByCoinTypeAndAddress(int coinType, String address,
      [String contractAddress, String block = 'latest']) async {
    address = bech32ToEthAddress(address);
    if (contractAddress == null) {
      //主链币
      var response =
          await postToEthereumNetwork(coinType, method: "eth_getBalance", params: [address, block]);
      if (response['result'] != null) {
        return hexToInt(response['result']);
      }
    } else {
      //合约币
      final contract = getErc20Contract(contractAddress, 'HYN');
      final balanceFun = contract.function('balanceOf');
      final balance = await getWeb3Client(coinType).call(
          contract: contract,
          function: balanceFun,
          params: [web3.EthereumAddress.fromHex(address)]);
      return balance.first;
    }
    return BigInt.from(0);
  }

  static String formatToHynAddrIfAtlasChain(CoinViewVo coinVo, String ethAddress) {
    if (coinVo.coinType == CoinType.HYN_ATLAS) {
      return ethAddressToBech32Address(ethAddress);
    } else {
      return ethAddress;
    }
  }

  static String ethAddressToBech32Address(String ethAddress) {
    if (ethAddress == null) {
      return null;
    }

    try {
      return web3.ethAddressToBech32Address(ethAddress);
    } catch (e) {
      return ethAddress;
    }
  }

  static String bech32ToEthAddress(String bech32Address) {
    try {
      return web3.bech32ToEthAddress(bech32Address);
    } catch (e) {
      return bech32Address;
    }
  }

  static String getRandomAvatarUrl() {
    List<String> fileNameList = ['what', 'sign'];

    String letters = '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    var letterList = letters.split('');

    fileNameList.addAll(letterList);
    var fileName = fileNameList[Random().nextInt(fileNameList.length)];

    var url = 'https://static-hk.hyn.mobi/static/avatar/$fileName.png';
    return url;
  }

  static String getChainNameByCoinType(int coinType) {
    var chainNme = '';
    if (coinType == CoinType.BITCOIN) {
      chainNme = 'Bitcoin';
    } else if (coinType == CoinType.ETHEREUM) {
      chainNme = 'Ethereum';
    } else if (coinType == CoinType.HYN_ATLAS) {
      chainNme = 'Atlas';
    } else if (coinType == CoinType.HB_HT) {
      chainNme = 'Heco';
    }
    return chainNme;
  }
}
