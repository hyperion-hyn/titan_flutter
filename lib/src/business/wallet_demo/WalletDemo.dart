import 'dart:math';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:http/http.dart';

import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:titan/src/basic/http/http.dart';
import 'package:titan/src/global.dart';
import 'package:titan/src/plugins/wallet/account.dart';
import 'package:titan/src/plugins/wallet/convert.dart';
import 'package:titan/src/plugins/wallet/keystore.dart';
import 'package:titan/src/plugins/wallet/wallet.dart';
import 'package:titan/src/plugins/wallet/wallet_util.dart';
import 'package:web3dart/crypto.dart';
import 'package:web3dart/web3dart.dart';
import 'package:bip39/bip39.dart' as bip39;

class WalletDemo extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _WalletDemoState();
  }
}

class _WalletDemoState extends State<WalletDemo> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Wallet Demo1"),
      ),
      body: ListView(
        shrinkWrap: true,
        padding: EdgeInsets.all(16),
        children: <Widget>[
          RaisedButton(
            onPressed: () async {
              setState(() {
                WalletConfig.isMainNet = !WalletConfig.isMainNet;
              });
            },
            child: Text('切换网络类型 ${WalletConfig.isMainNet ? "主网" : "ROPSTEN网"}'),
          ),
          Divider(
            height: 16,
          ),
          RaisedButton(
            onPressed: () async {
              var apiUrl = "https://ropsten.infura.io/v3/23df5e05a6524e9abfd20fb6297ee226"; //Replace with your API

              var httpClient = Client();
              var ethClient = new Web3Client(apiUrl, httpClient);
//              EtherAmount balance = await ethClient.getBalance(
//                  EthereumAddress.fromHex(
//                      '0x81e7A0529AC1726e7F78E4843802765B80d8cBc0'));
//              var ret = balance.getInWei;
//              var w = Convert.weiToNum(ret, 18);
//              print("balance is $w ${balance.getValueInUnit(EtherUnit.ether)}");

              final abiCode = await DefaultAssetBundle.of(context).loadString("res/eth/hyn_abi.json");
              final contract = DeployedContract(ContractAbi.fromJson(abiCode, 'HYN'),
                  EthereumAddress.fromHex('0xaebbada2bece10c84cbeac637c438cb63e1446c9'));
              final balanceFun = contract.function('balanceOf');
//              final balanceHyn = await ethClient.call(
//                  contract: contract,
//                  function: balanceFun,
//                  params: [
//                    EthereumAddress.fromHex(
//                        '0x81e7A0529AC1726e7F78E4843802765B80d8cBc0')
//                  ]);
//              print(balanceHyn);
//              print('hyn balance is: ${Convert.weiToNum(balanceHyn.first)}');

//              ethClient.getGasPrice();

//              Uint8List getBalanceFunAbi = balanceFun.encodeCall([
//                EthereumAddress.fromHex(
//                    '0x81e7A0529AC1726e7F78E4843802765B80d8cBc0')
//              ]);
//              print(bytesToHex(getBalanceFunAbi));

              final transferFun = contract.function('transfer');
              Uint8List transferFunAbi = transferFun.encodeCall([
                EthereumAddress.fromHex('0xA3Dcd899C0f3832DFDFed9479a9d828c6A4EB2A7'),
                ConvertTokenUnit.numToWei(10)
              ]);

              print(
                  'Convert.numToWei(1) ${ConvertTokenUnit.numToWei(1)}, ${bytesToHex(transferFunAbi, include0x: true)}');

              var response = await HttpCore.instance.post(apiUrl,
                  params: {"jsonrpc": "2.0", "method": "eth_gasPrice", "params": [], "id": 1},
                  options: RequestOptions(contentType: Headers.jsonContentType));

              if (response['result'] != null) {
//                logger.i(response['result']);
                String gasPriceHex = response['result'];
                BigInt gasPrice = hexToInt(gasPriceHex);
                print('gasPrice is $gasPrice');

                var estimateGasOfHynResponse = await HttpCore.instance.post(apiUrl,
                    params: {
                      "jsonrpc": "2.0",
                      "method": "eth_estimateGas",
                      "params": [
                        {
                          'from': '0xA3Dcd899C0f3832DFDFed9479a9d828c6A4EB2A7',
                          'to': '0x81e7A0529AC1726e7F78E4843802765B80d8cBc0',
                          'gasPrice': '0x${gasPrice.toRadixString(16)}',
                          'data': bytesToHex(transferFunAbi, include0x: true)
                        }
                      ],
                      "id": 2
                    },
                    options: RequestOptions(contentType: Headers.jsonContentType));

                if (estimateGasOfHynResponse['result'] != null) {
                  var amountUse = hexToInt(estimateGasOfHynResponse['result']);
                  var allWei = amountUse * gasPrice;
                  var us = ConvertTokenUnit.weiToDecimal(allWei) * Decimal.parse('200');
                  logger.i('hyn fee $us, wei $allWei');
                } else {
                  logger.e(estimateGasOfHynResponse['error']);
                }

                var tValue = '0x${ConvertTokenUnit.etherToWei(etherDouble: 10.3).toRadixString(16)}';
//                var tValue = '0x9184e72a';
                print('value $tValue, gasPrice: 0x${gasPrice.toRadixString(16)}}');
                var estimateGasOfEthResponse = await HttpCore.instance.post(apiUrl,
                    params: {
                      "jsonrpc": "2.0",
                      "method": "eth_estimateGas",
                      "params": [
                        {
                          'from': '0xA3Dcd899C0f3832DFDFed9479a9d828c6A4EB2A7',
                          'to': '0x81e7A0529AC1726e7F78E4843802765B80d8cBc0',
                          'gasPrice': '0x${gasPrice.toRadixString(16)}',
                          'value': tValue
                        }
                      ],
                      "id": 3
                    },
                    options: RequestOptions(contentType: Headers.jsonContentType));
                if (estimateGasOfEthResponse['result'] != null) {
                  var amountUse = hexToInt(estimateGasOfEthResponse['result']);
                  var allWei = amountUse * gasPrice;
                  var us = ConvertTokenUnit.weiToDecimal(allWei) * Decimal.parse('200');
                  logger.i('eth fee $us');
                } else {
                  logger.e(estimateGasOfEthResponse['error']);
                }
              } else {
                logger.e(response['error']);
              }
            },
            child: Text('dart获取余额'),
          ),
          Divider(
            height: 16,
          ),
          RaisedButton(
            onPressed: () async {
              var mnemonic = await WalletUtil.makeMnemonic();
              logger.i(mnemonic);
              Fluttertoast.showToast(msg: mnemonic);
            },
            child: Text('产生助记词'),
          ),
          RaisedButton(
            onPressed: () async {
              var mnemonic =
                  "ripple scissors kick mammal hire column oak again sun offer wealth tomorrow wagon turn fatal";
              if (!bip39.validateMnemonic(mnemonic)) {
                Fluttertoast.showToast(msg: '不是合法的助记词');
                return;
              }

              var walletName = "我的助记词钱包1";
              var password = 'my_password';
              var wallet = await WalletUtil.storeByMnemonic(name: walletName, password: password, mnemonic: mnemonic);
              if (wallet != null) {
                logger.i("已经导入助记词钱包 ${wallet.keystore.fileName}");
              } else {
                logger.i("导入助记词钱包错误 ");
              }
            },
            child: Text('通过助记词导入钱包'),
          ),
          RaisedButton(
            onPressed: () async {
//              var prvKey = "0xafeefca74d9a325cf1d6b6911d61a65c32afa8e02bd5e78e2e4ac2910bab45f5";
              var prvKey = "0xab4accc9310d90a61fc354d8f353bca4a2b3c0590685d3eb82d0216af3badddc";
//              var prvKey = "0x311add4073c265380aafab346b31bb0a22ca0ad7b6f544cb4a16b88f864526a3";  //moo
              var walletName = "我的密钥钱包1";
              var password = 'my_password';
              var wallet = await WalletUtil.storePrivateKey(name: walletName, password: password, prvKeyHex: prvKey);
              if (wallet != null) {
                logger.i("已经导入密码钱包 ${wallet.keystore.fileName}");
              } else {
                logger.i("导入密码钱包错误 ");
              }
            },
            child: Text('通过私钥导入'),
          ),
          Row(
            children: <Widget>[
              RaisedButton(
                onPressed: () async {
//              var json =
//                  '{"address":"3e88208d9bd1eb15b97dea04bdd739eea4d351b6","crypto":{"cipher":"aes-128-ctr","ciphertext":"a4da8ca12244034bea5d609f7eb9e819588bfff1e166b2c89ea7abdfb595b528","cipherparams":{"iv":"0285090551a563ad5ae6596c4a0bc869"},"kdf":"scrypt","kdfparams":{"dklen":32,"n":262144,"p":1,"r":8,"salt":"d9c5fd98901347e64258bdadfc78188ebb8be07392a99de2a24cbbadc4810321"},"mac":"b00629f6a26ae131d1f8e08d529488729bb839810307c5154edb2860bf186191"},"id":"94303270-4f9a-474e-9d46-306ba5dc61c4","version":3}';
//              var oldPassword = "moo";
                  //对于公钥 0x3e88208d9Bd1Eb15B97Dea04Bdd739eEa4d351b6
                  //对于的密钥是  0x311add4073c265380aafab346b31bb0a22ca0ad7b6f544cb4a16b88f864526a3

                  var json =
                      '{"activeAccounts":[{"address":"0xA3Dcd899C0f3832DFDFed9479a9d828c6A4EB2A7","derivationPath":"m/44\'/60\'/0\'/0/0"}],"crypto":{"cipher":"aes-128-ctr","cipherparams":{"iv":"1d2961149ff69d0a01a617ba89f968a2"},"ciphertext":"674ea349cfd925da4665fecf5f02caa6aedd917f537af9d7f70de57d28bb97d098266f52cdf7570d083702586e30095eb368b5486395414ab6698e319dc991ed2a9076d108a68ac611f9d54a1ee6519448ab5f16c759c3531af6e9a6","kdf":"scrypt","kdfparams":{"dklen":32,"n":4096,"p":6,"r":8,"salt":"0f9004a05b80711c4b40b5106758337b6c310444d02f2102f34867e361d7a343"},"mac":"af45e8dff47c52e13842d74359bdc102f6c1ce2cec1fc3cfb4390e571a3aa948"},"id":"a2ba2052-7586-46c8-a7c6-4294f5802671","name":"我的钱包1","type":"mnemonic","version":3}';
                  var oldPassword = 'my password';
                  var newPassword = 'my_password';

                  var walletName = "我的JSON钱包1";
                  try {
                    var wallet = await WalletUtil.storeJson(
                        name: walletName, password: oldPassword, newPassword: newPassword, keyStoreJson: json);
                    if (wallet != null) {
                      logger.i("已经导入JSON钱包 ${wallet.keystore.fileName}");
                    } else {
                      logger.i("导入JSON钱包错误 ");
                    }
                  } on PlatformException catch (e) {
                    logger.e(e.code);
                  }
                },
                child: Text('通过keystore json导入'),
              ),
              RaisedButton(
                onPressed: () async {
//              var json =
//                  '{"address":"3e88208d9bd1eb15b97dea04bdd739eea4d351b6","crypto":{"cipher":"aes-128-ctr","ciphertext":"a4da8ca12244034bea5d609f7eb9e819588bfff1e166b2c89ea7abdfb595b528","cipherparams":{"iv":"0285090551a563ad5ae6596c4a0bc869"},"kdf":"scrypt","kdfparams":{"dklen":32,"n":262144,"p":1,"r":8,"salt":"d9c5fd98901347e64258bdadfc78188ebb8be07392a99de2a24cbbadc4810321"},"mac":"b00629f6a26ae131d1f8e08d529488729bb839810307c5154edb2860bf186191"},"id":"94303270-4f9a-474e-9d46-306ba5dc61c4","version":3}';
//              var oldPassword = "moo";
                  //对于公钥 0x3e88208d9Bd1Eb15B97Dea04Bdd739eEa4d351b6
                  //对于的密钥是  0x311add4073c265380aafab346b31bb0a22ca0ad7b6f544cb4a16b88f864526a3

                  var json =
                      '{"activeAccounts":[{"address":"0xA3Dcd899C0f3832DFDFed9479a9d828c6A4EB2A7","derivationPath":"m/44\'/60\'/0\'/0/0"}],"crypto":{"cipher":"aes-128-ctr","cipherparams":{"iv":"1d2961149ff69d0a01a617ba89f968a2"},"ciphertext":"674ea349cfd925da4665fecf5f02caa6aedd917f537af9d7f70de57d28bb97d098266f52cdf7570d083702586e30095eb368b5486395414ab6698e319dc991ed2a9076d108a68ac611f9d54a1ee6519448ab5f16c759c3531af6e9a6","kdf":"scrypt","kdfparams":{"dklen":32,"n":4096,"p":6,"r":8,"salt":"0f9004a05b80711c4b40b5106758337b6c310444d02f2102f34867e361d7a343"},"mac":"af45e8dff47c52e13842d74359bdc102f6c1ce2cec1fc3cfb4390e571a3aa948"},"id":"a2ba2052-7586-46c8-a7c6-4294f5802671","name":"我的钱包1","type":"mnemonic","version":3}';
                  var oldPassword = 'my_password_wrong';
                  var newPassword = 'my_password';

                  var walletName = "我的JSON钱包1";
                  try {
                    var wallet = await WalletUtil.storeJson(
                        name: walletName, password: oldPassword, newPassword: newPassword, keyStoreJson: json);
                    if (wallet != null) {
                      logger.i("已经导入JSON钱包 ${wallet.keystore.fileName}");
                    } else {
                      logger.i("导入JSON钱包错误 ");
                    }
                  } on PlatformException catch (e) {
                    logger.e(e.code);
                  }
                },
                child: Text('密码错误'),
              ),
            ],
          ),
          RaisedButton(
            onPressed: () async {
              var wallets = await WalletUtil.scanWallets();
              if (wallets.length > 0) {
                print('扫描到的钱包:');
                for (var wallet in wallets) {
                  print(
                      "钱包 name: ${(wallet.keystore is KeyStore) ? wallet.keystore.name : " "}  文件路径： ${wallet.keystore.fileName}");
                  for (var account in wallet.accounts) {
                    print("账户地址： ${account.address}");
                    print(account.token);
                    print('-------');
                    for (var token in account.erc20AssetTokens) {
                      print(token);
                    }
                  }
                }
              } else {
                print('没有扫描到钱包');
              }
            },
            child: Text('扫描所有钱包'),
          ),
          Row(
            children: <Widget>[
              RaisedButton(
                onPressed: () async {
                  var wallets = await WalletUtil.scanWallets();
                  if (wallets.length > 0) {
                    //修改第一个账户密码吧
                    var wallet = wallets[0];
                    print('即将修改${wallet.keystore.fileName} 的密码');
                    var success = await WalletUtil.changePassword(
                        wallet: wallet, oldPassword: 'my_password', newPassword: "new password", name: '修改的钱包');
//                    var success = await WalletUtil.changePassword(
//                        wallet: wallet, oldPassword: 'new password', newPassword: "my_password", name: '修改的钱包');
                    if (success) {
                      print('修改密码成功');
                      print('最后成为${wallet.keystore.fileName}');
                    }
                  }
                },
                child: Text('修改钱包密码'),
              ),
              RaisedButton(
                onPressed: () async {
                  var wallets = await WalletUtil.scanWallets();
                  if (wallets.length > 0) {
                    //修改第一个账户密码吧
                    var wallet = wallets[0];
                    print('即将修改${wallet.keystore.fileName} 的密码');
                    var success = await WalletUtil.changePassword(
                        wallet: wallet, oldPassword: 'my_password_wrong', newPassword: "new password", name: '修改的钱包');
                    if (success) {
                      print('修改密码成功');
                      print('最后成为${wallet.keystore.fileName}');
                    }
                  }
                },
                child: Text('修改钱包密码 错误密码'),
              ),
            ],
          ),
          Row(
            children: <Widget>[
              RaisedButton(
                onPressed: () async {
                  var wallets = await WalletUtil.scanWallets();
                  if (wallets.length > 0) {
                    var wallet = wallets[0];
                    try {
                      var prvKey = await WalletUtil.exportPrivateKey(
                          fileName: wallet.keystore.fileName, password: 'my_password');
                      logger.i('your prvKey is: $prvKey');
                    } catch (e) {
                      logger.e(e);
                    }
                  }
                },
                child: Text('导出私钥 密码正确'),
              ),
              RaisedButton(
                onPressed: () async {
                  var wallets = await WalletUtil.scanWallets();
                  if (wallets.length > 0) {
                    var wallet = wallets[0];
                    try {
                      var prvKey = await WalletUtil.exportPrivateKey(
                          fileName: wallet.keystore.fileName, password: 'my_password_wrong');
                      logger.i('your prvKey is: $prvKey');
                    } catch (e) {
                      logger.e(e);
                    }
                  }
                },
                child: Text('导出私钥 密码错误'),
              ),
            ],
          ),
          Row(
            children: <Widget>[
              RaisedButton(
                onPressed: () async {
                  var wallets = await WalletUtil.scanWallets();
                  if (wallets.length > 0) {
                    var wallet = wallets[0];
                    try {
                      if ((wallet.keystore is KeyStore) && wallet.keystore.isMnemonic) {
                        var mnemonic = await WalletUtil.exportMnemonic(
                            fileName: wallet.keystore.fileName, password: 'my_password');
                        logger.i('your mnemonic is: $mnemonic');
                      } else {
                        print('不是TrustWallet钱包，不支持导出助记词');
                      }
                    } catch (e) {
                      logger.e(e);
                    }
                  }
                },
                child: Text('导出助记词 密码正确'),
              ),
              RaisedButton(
                onPressed: () async {
                  var wallets = await WalletUtil.scanWallets();
                  if (wallets.length > 0) {
                    var wallet = wallets[0];
                    try {
                      if ((wallet.keystore is KeyStore) && wallet.keystore.isMnemonic) {
                        var mnemonic = await WalletUtil.exportMnemonic(
                            fileName: wallet.keystore.fileName, password: 'my_password_wrong');
                        logger.i('your mnemonic is: $mnemonic');
                      } else {
                        print('不是TrustWallet钱包，不支持导出助记词');
                      }
                    } catch (e) {
                      logger.e(e);
                    }
                  }
                },
                child: Text('密码错误'),
              ),
            ],
          ),
          RaisedButton(
            onPressed: () async {
              var password = 'my_password';
              var wallets = await WalletUtil.scanWallets();
              for (var wallet in wallets) {
                var result = await wallet.delete(password);
                print("删除结果 ${wallet.keystore.fileName} $result");
              }
            },
            child: Text('删除所有钱包'),
          ),
          Divider(
            height: 16,
          ),
          RaisedButton(
            onPressed: () async {
              var wallets = await WalletUtil.scanWallets();
              for (var wallet in wallets) {
                var balance;
                Account account = wallet.getEthAccount();
                if (account != null) {
                  balance = await wallet.getBalance(account);
                  print(
                      "账户${account.address} ${account.token.symbol} 余额是 ${balance / BigInt.from(pow(10, account.token.decimals))}");

                  //获取erc20账户余额
                  for (var token in account.erc20AssetTokens) {
                    balance = await wallet.getErc20Balance(token.erc20ContractAddress);
                    print(
                        "ERC20账户${account.address} ${token.symbol} 余额是 ${balance / BigInt.from(pow(10, token.decimals))}");
                  }
                }
              }
            },
            child: Text('查看钱包余额'),
          ),
          RaisedButton(
            onPressed: () async {
              var gas = await WalletUtil.ethGasPrice();
              logger.i('油费是 $gas');
            },
            child: Text('查看以太坊油费'),
          ),
          RaisedButton(
            onPressed: () async {
              var fromAddress = '0x81e7A0529AC1726e7F78E4843802765B80d8cBc0';
              var toAddress = '0xe7147924489DbA4b6eF71CFC3b0615eD74C34c39';
              var contract = null; //'0xaebbada2bece10c84cbeac637c438cb63e1446c9';
              var decimals = 18;
              var amount = 13.45;

              const GWEI = 1000000000;
              var lowSpeed = 3 * GWEI; //慢
              var fastSpeed = 10 * GWEI; //快
              var extremelyFastSpeed = 30 * GWEI; //极速

              var wallets = await WalletUtil.scanWallets();
              if (wallets.isNotEmpty) {
                var wallet = wallets.first;
                var ret = await wallet.estimateGasPrice(
                    toAddress: '0xe7147924489DbA4b6eF71CFC3b0615eD74C34c39',
                    value: ConvertTokenUnit.etherToWei(etherDouble:  amount),
                    gasPrice: BigInt.from(fastSpeed));
                print('xxx $ret, ${ConvertTokenUnit.weiToDecimal(ret, decimals) * Decimal.fromInt(192)}');
              } else {
                print('无钱包');
              }
            },
            child: Text('查看交易费率'),
          ),
          RaisedButton(
            onPressed: () async {
              try {
                var password = 'my_password';
                var amount = ConvertTokenUnit.etherToWei(etherDouble: 0.01).toRadixString(16);
                var wallets = await WalletUtil.scanWallets();
                if (wallets.length > 0) {
                  var wallet0 = wallets[0];

                  var toAddress = '0x81e7A0529AC1726e7F78E4843802765B80d8cBc0';

                  var txHash = await WalletUtil.transfer(
                    password: password,
                    fileName: wallet0.keystore.fileName,
                    coinType: wallet0.getEthAccount().coinType,
                    fromAddress: wallet0.getEthAccount().address,
                    toAddress: toAddress,
                    amount: amount,
                  );

                  logger.i('ETH交易已提交，交易hash $txHash');
                }
              } catch (e) {
                logger.e(e);
              }
            },
            child: Text('EHT转账'),
          ),
          RaisedButton(
            onPressed: () async {
              try {
                var password = 'my_password';
                var amount = ConvertTokenUnit.etherToWei(etherDouble: 1).toRadixString(16);
                var wallets = await WalletUtil.scanWallets();
                if (wallets.length > 0) {
                  var wallet0 = wallets[0];
                  var hynErc20ContractAddress = wallet0.getEthAccount().erc20AssetTokens[0].erc20ContractAddress;

                  var toAddress = '0x81e7A0529AC1726e7F78E4843802765B80d8cBc0';

                  var txHash = await WalletUtil.transferErc20Token(
                    password: password,
                    fileName: wallet0.keystore.fileName,
                    erc20ContractAddress: hynErc20ContractAddress,
                    fromAddress: wallet0.getEthAccount().address,
                    toAddress: toAddress,
                    amount: amount,
                  );

                  logger.i('HYN交易已提交，交易hash $txHash');
                }
              } catch (e) {
                logger.e(e);
              }
            },
            child: Text('HYN转账'),
          ),
        ],
      ),
    );
  }
}
