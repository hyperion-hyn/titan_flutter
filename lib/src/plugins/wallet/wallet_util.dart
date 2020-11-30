import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:titan/src/basic/http/entity.dart';
import 'package:titan/src/basic/http/http.dart';
import 'package:titan/src/components/auth/auth_component.dart';
import 'package:titan/src/components/wallet/vo/coin_vo.dart';
import 'package:titan/src/components/wallet/wallet_component.dart';
import 'package:titan/src/config/consts.dart';
import 'package:titan/src/data/cache/app_cache.dart';
import 'package:titan/src/pages/atlas_map/api/atlas_http.dart';
import 'package:titan/src/pages/wallet/model/bitcoin_transfer_history.dart';
import 'package:titan/src/plugins/titan_plugin.dart';
import 'package:titan/src/plugins/wallet/account.dart';
import 'package:titan/src/plugins/wallet/cointype.dart';
import 'package:titan/src/plugins/wallet/hyn_erc20_abi.dart';
import 'package:titan/src/plugins/wallet/keystore.dart';
import 'package:titan/src/plugins/wallet/map3_staking_abi.dart';
import 'package:titan/src/plugins/wallet/token.dart';
import 'package:titan/src/plugins/wallet/wallet.dart';
import 'package:titan/src/plugins/wallet/wallet_channel.dart';
import 'package:http/http.dart';
import 'package:titan/src/plugins/wallet/wallet_const.dart';
import 'package:titan/src/utils/utile_ui.dart';
import 'package:titan/src/widget/auth_dialog/bio_auth_dialog.dart';
import 'package:web3dart/crypto.dart';
import 'package:web3dart/web3dart.dart' as web3;
import 'package:bip39/bip39.dart' as bip39;

import 'bitcoin_trans_entity.dart';
import 'contract_const.dart';
import 'hyn_staking_abi.dart';

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
      {@required String name,
      @required String password,
      @required String mnemonic}) async {
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
      {@required String name,
      @required String password,
      @required String prvKeyHex}) async {
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
  static Future<BigInt> ethGasPrice({int requestId = 1}) async {
    var response =
        await postToEthereumNetwork(method: 'eth_gasPrice', params: []);
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
    return WalletChannel.exportPrivateKey(
        fileName: fileName, password: password);
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
    var wallet = _parseWalletJson(map);
    return wallet;
  }

  static Uint8List getErc20FuncAbi({
    String contractAddress,
    String funName,
    List<dynamic> params = const [],
  }) {
    final contract = getHynErc20Contract(contractAddress);
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
    var abi = getErc20FuncAbi(
        contractAddress: contractAddress, params: params, funName: funName);
    return bytesToHex(abi,
        include0x: include0x, padToEvenLength: padToEvenLength);
  }

  static String getMap3FuncAbiHex(
      {String contractAddress,
      String funName,
      List<dynamic> params = const [],
      bool include0x = true,
      bool padToEvenLength = true}) {
    var abi = getMap3FuncAbi(
        contractAddress: contractAddress, params: params, funName: funName);
    return bytesToHex(abi,
        include0x: include0x, padToEvenLength: padToEvenLength);
  }

  static Wallet _parseWalletJson(dynamic map) {
    var keystore = KeyStore.fromDynamicMap(map);
    var backAccounts = [];
    // add Hyn atlas
    for (var account in map['accounts']) {
      if (account['coinType'] == CoinType.ETHEREUM) {
        backAccounts.add({
          "address": account["address"],
          "derivationPath": account['derivationPath'],
          'coinType': CoinType.HYN_ATLAS
        });
      }
      backAccounts.add(account);
    }

    var accounts = List<Account>.from(backAccounts.map((accountMap) =>
        Account.fromJsonWithNet(accountMap, WalletConfig.netType)));

    //filter only ETHEREUM
//    accounts = accounts.where((account) {
//      return account.coinType == CoinType.ETHEREUM;
//    }).toList();

    var wallet = Wallet(keystore: keystore, accounts: accounts);
    return wallet;
  }

  static web3.Web3Client _newWeb3Client(String api) {
    return web3.Web3Client(api, Client());
  }

  static web3.DeployedContract _newHynContract(String contractAddress) {
    final contract = web3.DeployedContract(
        web3.ContractAbi.fromJson(HYN_ERC20_ABI, 'HYN'),
        web3.EthereumAddress.fromHex(contractAddress));
    return contract;
  }

  static web3.DeployedContract _newMap3Contract(String contractAddress) {
    final contract = web3.DeployedContract(
        web3.ContractAbi.fromJson(MAP3_STAKING_ABI, 'Map3Staking'),
        web3.EthereumAddress.fromHex(contractAddress));
    return contract;
  }

  static web3.DeployedContract _newHynStakingContract(String contractAddress) {
    final contract = web3.DeployedContract(
        web3.ContractAbi.fromJson(HYN_STAKING_ABI, 'HynStaking'),
        web3.EthereumAddress.fromHex(contractAddress));
    return contract;
  }

  /// https://infura.io/docs/gettingStarted/makeRequests.md
  static Future<dynamic> postToEthereumNetwork(
      {String method, List params, int id = 1,bool isAtlasTrans = false}) {
    //{jsonrpc: 2.0, id: 1, result: 0x4547fdfbf3f1cfd25c0fa7267a97c7832ddda76352456b8e78898e9bd619adb7}
    return HttpCore.instance.post(isAtlasTrans ? WalletConfig.getAtlasApi() : WalletConfig.getEthereumApi(),
        params: {
          "jsonrpc": "2.0",
          "method": method,
          "params": params,
          "id": id
        },
        options: RequestOptions(contentType: Headers.jsonContentType));
  }

  static Future<dynamic> postToAtlasNetwork(
      {String method, List params, int id = 1}) {
    return AtlasHttpCore.instance.post(WalletConfig.getAtlasApi(),
        params: {
          "jsonrpc": "2.0",
          "method": method,
          "params": params,
          "id": id
        },
        options: RequestOptions(contentType: Headers.jsonContentType));
  }

  static web3.DeployedContract _hynErc20Contract;
  static web3.DeployedContract _map3StakingContract;
  static web3.DeployedContract _hynStakingContract;

  static web3.Web3Client _web3AtlasClientMain;
  static web3.Web3Client _web3AtlasClientTest;
  static web3.Web3Client _web3clientMain;
  static web3.Web3Client _web3clientRopsten;
  static web3.Web3Client _web3clientRinkeby;
  static web3.Web3Client _web3clientLocal;

  static web3.DeployedContract getHynErc20Contract(String contractAddress) {
    if (_hynErc20Contract == null ||
        _hynErc20Contract?.address?.hex?.contains(contractAddress) != true) {
      _hynErc20Contract = WalletUtil._newHynContract(contractAddress);
    }
    return _hynErc20Contract;
  }

  static web3.DeployedContract getMap3Contract(String contractAddress) {
    if (_map3StakingContract == null ||
        _map3StakingContract?.address?.hex?.contains(contractAddress) != true) {
      _map3StakingContract = WalletUtil._newMap3Contract(contractAddress);
    }
    return _map3StakingContract;
  }

  static web3.DeployedContract getHynStakingContract(String contractAddress) {
    if (_hynStakingContract == null ||
        _hynStakingContract?.address?.hex?.contains(contractAddress) != true) {
      _hynStakingContract = WalletUtil._newHynStakingContract(contractAddress);
    }
    return _hynStakingContract;
  }

  static web3.Web3Client getWeb3Client([bool isAtlas = false, bool isPrint = false]) {
    if (isAtlas) {
      if (WalletConfig.netType == EthereumNetType.main) {
        if (_web3AtlasClientMain == null) {
          _web3AtlasClientMain =
              WalletUtil._newWeb3Client(WalletConfig.ATLAS_API);
          _web3AtlasClientMain.printResponse = isPrint;
        }
        return _web3AtlasClientMain;
      } else {
        if (_web3AtlasClientTest == null) {
          _web3AtlasClientTest =
              WalletUtil._newWeb3Client(WalletConfig.ATLAS_API_TEST);
          _web3AtlasClientTest.printResponse = isPrint;
        }
        return _web3AtlasClientTest;
      }
    }

    switch (WalletConfig.netType) {
      case EthereumNetType.main:
        if (_web3clientMain == null) {
          _web3clientMain =
              WalletUtil._newWeb3Client(WalletConfig.INFURA_MAIN_API);
        }
        return _web3clientMain;
      case EthereumNetType.ropsten:
        if (_web3clientRopsten == null) {
          _web3clientRopsten =
              WalletUtil._newWeb3Client(WalletConfig.INFURA_ROPSTEN_API);
        }
        return _web3clientRopsten;
      case EthereumNetType.rinkeby:
        if (_web3clientRinkeby == null) {
          _web3clientRinkeby =
              WalletUtil._newWeb3Client(WalletConfig.INFURA_RINKEBY_API);
        }
        return _web3clientRinkeby;
      case EthereumNetType.local:
        if (_web3clientLocal == null) {
          _web3clientLocal =
              WalletUtil._newWeb3Client(ContractTestConfig.walletLocalDomain);
          //_web3clientLocal = WalletUtil._newWeb3Client(WalletConfig.LOCAL_API);
        }
        return _web3clientLocal;
    }
    return null;
  }

  static Future<BigInt> getBalanceByCoinTypeAndAddress(
      int coinType, String address,
      [String contractAddress, String block = 'latest']) async {
    if ([CoinType.ETHEREUM, CoinType.HYN_ATLAS].contains(coinType)) {
      if (contractAddress == null) {
        var response;
        if (coinType == CoinType.ETHEREUM) {
          response = await WalletUtil.postToEthereumNetwork(
              method: "eth_getBalance", params: [address, block]);
        } else {
          response = await WalletUtil.postToAtlasNetwork(
              method: "eth_getBalance", params: [address, block]);
        }
        if (response['result'] != null) {
          return hexToInt(response['result']);
        }
      } else {
        final contract = WalletUtil.getHynErc20Contract(contractAddress);
        final balanceFun = contract.function('balanceOf');
        bool isAtlasCoin = coinType == CoinType.HYN_ATLAS;
        final balance = await WalletUtil.getWeb3Client(isAtlasCoin).call(
            contract: contract,
            function: balanceFun,
            params: [web3.EthereumAddress.fromHex(address)]);
        return balance.first;
      }
    }
    return BigInt.from(0);
  }

  static String formatToHynAddrIfAtlasChain(CoinVo coinVo, String ethAddress) {
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
}
