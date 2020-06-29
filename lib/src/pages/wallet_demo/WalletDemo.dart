import 'dart:convert';
import 'dart:math';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:titan/src/basic/http/signer.dart';
import 'package:titan/src/components/setting/setting_component.dart';
import 'package:titan/src/components/wallet/bloc/bloc.dart';
import 'package:titan/src/components/wallet/wallet_component.dart';
import 'package:titan/src/config/consts.dart';
import 'package:titan/src/global.dart';
import 'package:titan/src/plugins/titan_plugin.dart';
import 'package:titan/src/plugins/wallet/account.dart';
import 'package:titan/src/plugins/wallet/contract_const.dart';
import 'package:titan/src/plugins/wallet/convert.dart';
import 'package:titan/src/plugins/wallet/keystore.dart';
import 'package:titan/src/plugins/wallet/token.dart';
import 'package:titan/src/plugins/wallet/wallet_const.dart';
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
  var _mnemonic = "";

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
              var index = EthereumNetType.values.indexOf(WalletConfig.netType);
              setState(() {
                WalletConfig.netType = EthereumNetType.values[(index + 1) % EthereumNetType.values.length];
              });
            },
            child: Text('${WalletConfig.netType.toString().split('.')[1]} 点击切换网络类型'),
          ),
          Divider(
            height: 16,
          ),
          RaisedButton(
            onPressed: () async {
              var wallets = await WalletUtil.scanWallets();
              if (wallets.length > 0) {
                BlocProvider.of<WalletCmpBloc>(context).add(ActiveWalletEvent(wallet: wallets[0]));
              }
            },
            child: Text('激活一个钱包'),
          ),
          RaisedButton(
            onPressed: () async {
              _mnemonic = await WalletUtil.makeMnemonic();
//              print('xxx $_mnemonic');
//              return ;

//              ripple scissors kick mammal hire column oak again sun offer wealth tomorrow wagon turn fatal  //常用的测试网
//              because certain august huge empower blue half pepper tunnel trust amazing forget  //测试网私钥

//              _mnemonic = 'motion clip lunch rebel use bag fashion indicate ten mushroom loop miracle'; //1
//              _mnemonic = 'pizza another fault reduce choose bronze zebra attitude pottery repair spider person'; //2
//              _mnemonic = 'enrich rail nature figure legend bright bird habit page project silk wrap'; //3
//              _mnemonic = 'rifle beyond crime insect spider mention mirror ripple mixed pulse perfect nerve';//4
//              _mnemonic = 'like parent salmon record drop weapon friend obey planet raven desert grit';  //5
//              _mnemonic = 'post diamond chimney type armed seed absurd doll dream law fan hollow';//6
//              _mnemonic = 'park vapor mind eagle depth witness liquid effort helmet margin attitude topple';//7
//              _mnemonic = 'rebel stand list ladder argue sentence night episode aisle steel amateur bid';//8

              if (!bip39.validateMnemonic(_mnemonic)) {
                Fluttertoast.showToast(msg: '不是合法的助记词');
                return;
              }

              //var walletName = "我的助记词钱包1";
              var walletName = _mnemonic.split(" ").first;
              var password = '111111';
              var wallet = await WalletUtil.storeByMnemonic(name: walletName, password: password, mnemonic: _mnemonic);
              if (wallet != null) {
                _mnemonic = null;
                BlocProvider.of<WalletCmpBloc>(context).add(ActiveWalletEvent(wallet: wallet));

                logger.i("-快捷一步，创建一个新钱包, name:$walletName, keystore: ${wallet.keystore.fileName}， 成功！");
              } else {
                logger.i("-快捷一步，创建一个新钱包：错误 ");
              }
            },
            child: Text('快捷一步，创建一个新钱包, 并且激活新钱包'),
          ),
          RaisedButton(
            onPressed: () async {
              if (WalletConfig.netType == EthereumNetType.main) {
                logger.i('-请先切换到ETH网络到非主网');
              } else {
                final client = WalletUtil.getWeb3Client();
                String privateKey = ContractTestConfig.privateKey;
                final credentials = await client.credentialsFromPrivateKey(privateKey);

                final address = await credentials.extractAddress();
                print(address.hexEip55);
                print(await client.getBalance(address));

                var activeWallet = WalletInheritedModel.of(context).activatedWallet?.wallet;
                if (activeWallet != null) {
                  var toAddress = activeWallet.getEthAccount().address;
                  var amount = ConvertTokenUnit.etherToWei(etherDouble: 0.05); //.toRadixString(16);
//                  var amount = ConvertTokenUnit.etherToWei(etherDouble: 0.5); //.toRadixString(16);

                  var count = await client.getTransactionCount(EthereumAddress.fromHex(address.hexEip55));

                  var txHash = await client.sendTransaction(
                    credentials,
                    Transaction(
                      to: EthereumAddress.fromHex(toAddress),
                      value: EtherAmount.inWei(amount),
                      nonce: count,
                      gasPrice: EtherAmount.inWei(BigInt.from(EthereumConst.SUPER_FAST_SPEED)),
                      maxGas: SettingInheritedModel.ofConfig(context).systemConfigEntity.ethTransferGasLimit,
                    ),
                    fetchChainIdFromNetworkId: true,
                  );
                  logger.i('ETH交易已提交，交易hash $txHash');

                  var hynErc20Contract = WalletUtil.getHynErc20Contract(ContractTestConfig.hynContractAddress);
                  var hynAmount = ConvertTokenUnit.etherToWei(etherDouble: 505000); //三十万
                  txHash = await client.sendTransaction(
                    credentials,
                    Transaction.callContract(
                      contract: hynErc20Contract,
                      function: hynErc20Contract.function('transfer'),
                      parameters: [EthereumAddress.fromHex(toAddress), hynAmount],
                      nonce: count + 1,
                      gasPrice: EtherAmount.inWei(BigInt.from(EthereumConst.SUPER_FAST_SPEED)),
                      maxGas: 500000,
                    ),
                    fetchChainIdFromNetworkId: true,
                  );
                  logger.i('HYN交易已提交，交易hash $txHash');
                }
              }
            },
            child: Text('转账到本地钱包测试'),
          ),
          RaisedButton(
            onPressed: () async {
//              var wallets = await WalletUtil.scanWallets();
              var activeWallet = WalletInheritedModel.of(context).activatedWallet?.wallet;
              if (activeWallet != null) {
                var balance;
                Account account = activeWallet.getEthAccount();
                if (account != null) {
                  balance = await activeWallet.getBalance(account);
                  print(
                      "账户${account.address} ${account.token.symbol} 余额是 ${balance / BigInt.from(pow(10, account.token.decimals))}");

                  //获取erc20账户余额
//                  for (var token in account.contractAssetTokens) {
//                    balance = await activeWallet.getErc20Balance(token.contractAddress);
//                    print(
//                        "ERC20账户${account.address} ${token.symbol} 余额是 ${balance / BigInt.from(pow(10, token.decimals))}");
//                  }
                }
              }
            },
            child: Text('查看钱包余额'),
          ),
          Divider(
            height: 16,
          ),
          RaisedButton(
            onPressed: () async {
              var wallets = await WalletUtil.scanWallets();
              if (wallets.length > 0) {
                var wallet0 = wallets[0];
                final client = WalletUtil.getWeb3Client();
                var map3Contract = WalletUtil.getMap3Contract(WalletConfig.map3ContractAddress);

                final ret = await client
                    .call(contract: map3Contract, function: map3Contract.function('maxTotalDelegation'), params: []);
                logger.i('map3 maxTotalDelegation, result: $ret');
              }
            },
            child: Text('map3调用查询，最大抵押量'),
          ),
          RaisedButton(
            onPressed: () async {
//              var wallets = await WalletUtil.scanWallets();
              var wallets = WalletInheritedModel.of(context).activatedWallet;
              if (wallets != null) {
                var wallet0 = wallets.wallet;

                var maxStakingAmount = 1000000; //一百万
                var myStaking = 0.4 * maxStakingAmount; //最小抵押量
                var hynErc20ContractAddress = wallet0.getEthAccount().contractAssetTokens[0].contractAddress;
                var approveToAddress = WalletConfig.map3ContractAddress;
                try {
                  var signedHex = await wallet0.signApproveErc20Token(
                      contractAddress: hynErc20ContractAddress,
                      approveToAddress: approveToAddress,
                      amount: ConvertTokenUnit.etherToWei(etherDouble: myStaking),
                      password: '111111',
                      gasPrice: BigInt.from(EthereumConst.SUPER_FAST_SPEED),
                      gasLimit: 5000000);
                  var ret =
                      await WalletUtil.postToEthereumNetwork(method: 'eth_sendRawTransaction', params: [signedHex]);

                  logger.i('hyn approve, result: $ret');
                } catch (e) {
                  logger.e(e);
                  if (e is PlatformException) {
                    if (e.code == PlatformErrorCode.PASSWORD_WRONG) {
                      Fluttertoast.showToast(msg: '密码错误');
                    }
                  }
                }
              }
            },
            child: Text('hyn approve'),
          ),
          RaisedButton(
            onPressed: () async {
              //请注意，要先 approve
              logger.w('-请注意，要先 approve');
              var wallets = WalletInheritedModel.of(context).activatedWallet;
//              var wallets = await WalletUtil.scanWallets();
              if (wallets != null) {
                var wallet0 = wallets.wallet;

                var maxStakingAmount = 1000000; //一百万
                var myStaking = 0.2 * maxStakingAmount; //最小抵押量
                int durationType = 0; //0: 1月， 1: 3月， 2: 6月
                var gasLimit = 1000000; //TODO 暂定的，到时候要调成合适的.
//
                var signedHex;

//                var credentials = await wallet0.getCredentials('111111');
//                final client = WalletUtil.getWeb3Client();
//                var map3Contract = WalletUtil.getMap3Contract(WalletConfig.map3ContractAddress);
//                var signed = await client.signTransaction(
//                  credentials,
//                  Transaction.callContract(
//                    contract: map3Contract,
//                    function: map3Contract.function('createNode'),
//                    parameters: [
//                      ConvertTokenUnit.etherToWei(etherDouble: myStaking),
//                      BigInt.from(durationType),
//                      hexToBytes('0x75c452bab9f8a838f6880290d537867adf0b7d744edba34806cb3c9455517435'),
//                      hexToBytes('0xe5dede8ce87e38149f1e8df57da67d43d12a27f61d11d7f6d14ebbb6132a850d'),
//                    ],
//                    gasPrice: EtherAmount.inWei(BigInt.from(EthereumConst.SUPER_FAST_SPEED)),
//                    maxGas: gasLimit,
//                  ),
//                  fetchChainIdFromNetworkId: true,
//                );
//                signedHex = bytesToHex(signed, include0x: true, padToEvenLength: true);
//                var ret = await WalletUtil.postToEthereumNetwork(
//                    method: 'eth_sendRawTransaction',
//                    params: [bytesToHex(signed, include0x: true, padToEvenLength: true)]);

                signedHex = await wallet0.signCreateMap3Node(
                  stakingAmount: ConvertTokenUnit.etherToWei(etherDouble: myStaking),
                  type: durationType,
                  firstHalfPubKey: '0x75c452bab9f8a838f6880290d537867adf0b7d744edba34806cb3c9455517435',
                  secondHalfPubKey: '0xe5dede8ce87e38149f1e8df57da67d43d12a27f61d11d7f6d14ebbb6132a850d',
                  gasPrice: BigInt.from(EthereumConst.SUPER_FAST_SPEED),
                  gasLimit: gasLimit,
                  password: '111111',
                );
                var ret = await WalletUtil.postToEthereumNetwork(method: 'eth_sendRawTransaction', params: [signedHex]);

                logger.i('map3 createNode, result: $ret');
              }
            },
            child: Text('map3创建节点抵押'),
          ),
          RaisedButton(
            onPressed: () async {
              var wallets = WalletInheritedModel.of(context).activatedWallet;
//              var wallets = await WalletUtil.scanWallets();
              if (wallets != null) {
                var wallet0 = wallets.wallet;

                var createNodeWalletAddress = wallet0.getEthAccount().address; //创建节点合约的钱包地址
                double myStaking = 100000; //我要抵押的量
                var gasLimit = 1000000; //TODO 暂定的，到时候要调成合适的.

                var signedHex = await wallet0.signDelegateMap3Node(
                  createNodeWalletAddress: createNodeWalletAddress,
                  stakingAmount: ConvertTokenUnit.etherToWei(etherDouble: myStaking),
                  gasPrice: BigInt.from(EthereumConst.SUPER_FAST_SPEED),
                  gasLimit: gasLimit,
                  password: '111111',
                );
                var ret = await WalletUtil.postToEthereumNetwork(method: 'eth_sendRawTransaction', params: [signedHex]);

                logger.i('map3 delegate, result: $ret');
              }
            },
            child: Text('map3参与抵押'),
          ),
          RaisedButton(
            onPressed: () async {
              var wallets = await WalletUtil.scanWallets();
              if (wallets.length > 0) {
                var wallet0 = wallets[0];
                var gasLimit = 1000000; //TODO 暂定的，到时候要调成合适的.

                ///创建节点合约的钱包地址
                var createNodeWalletAddress = wallet0.getEthAccount().address;

                var signedHex = await wallet0.signCollectMap3Node(
                  createNodeWalletAddress: createNodeWalletAddress,
                  gasPrice: BigInt.from(EthereumConst.SUPER_FAST_SPEED),
                  gasLimit: gasLimit,
                  password: '111111',
                );
                var ret = await WalletUtil.postToEthereumNetwork(method: 'eth_sendRawTransaction', params: [signedHex]);

                logger.i('map3 collect, result: $ret');
              }
            },
            child: Text('map3提币'),
          ),
          Divider(
            height: 16,
          ),

          /*
          RaisedButton(
            onPressed: () async {
              _mnemonic = await WalletUtil.makeMnemonic();
              logger.i(_mnemonic);
              Fluttertoast.showToast(msg: _mnemonic);
            },
            child: Text('产生助记词'),
          ),
          RaisedButton(
            onPressed: () async {
//              var mnemonic =
//                  "ripple scissors kick mammal hire column oak again sun offer wealth tomorrow wagon turn fatal";
//              var mnemonic = 'because certain august huge empower blue half pepper tunnel trust amazing forget';
              if (!bip39.validateMnemonic(_mnemonic)) {
                Fluttertoast.showToast(msg: '不是合法的助记词');
                return;
              }

              var walletName = "我的助记词钱包1";
              var password = '111111';
              var wallet = await WalletUtil.storeByMnemonic(name: walletName, password: password, mnemonic: _mnemonic);
              if (wallet != null) {
                _mnemonic = null;
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
//              var prvKey = "92e06b7043c2edc07de56fd1f22764d9d7927a386e6efc0632f74a1141291ec6";
//              var prvKey = "0x311add4073c265380aafab346b31bb0a22ca0ad7b6f544cb4a16b88f864526a3";  //moo
              var walletName = "我的私钥钱包1";
              var password = '111111';
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
                  var newPassword = '111111';

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
                  var oldPassword = '111111_wrong';
                  var newPassword = '111111';

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
          */
          RaisedButton(
            onPressed: () async {
              var wallets = await WalletUtil.scanWallets();
              if (wallets.length > 0) {
                print('-扫描到的钱包:');
                for (var wallet in wallets) {
                  print(
                      "钱包 name: ${(wallet.keystore is KeyStore) ? wallet.keystore.name : " "}  文件路径： ${wallet.keystore.fileName}");
                  for (var account in wallet.accounts) {
                    print("-账户地址： ${account.address}");
                    print(account.token);
                    print('-------');
                    for (var token in account.contractAssetTokens) {
                      print(token);
                    }
                  }
                }
              } else {
                print('-没有扫描到钱包');
              }
            },
            child: Text('扫描所有钱包'),
          ),
          Row(
            children: <Widget>[
              RaisedButton(
                onPressed: () async {
                  var wallet = WalletInheritedModel.of(context).activatedWallet;
                  if (wallet != null) {
                    //修改第一个账户密码吧
                    print('-即将修改${wallet.wallet.keystore.fileName}');
                    var success = await WalletUtil.updateWallet(
                        wallet: wallet.wallet,
                        password: '111111',
//                        newPassword: "new password",
                        name: '🤩钱包${Random().nextInt(1000)}');
//                    var success = await WalletUtil.changePassword(
//                        wallet: wallet, oldPassword: 'new password', newPassword: "111111", name: '修改的钱包');
                    if (success) {
                      print('-修改成功');
                      print('-最后成为${wallet.wallet.keystore.name} ${wallet.wallet.keystore.fileName}');
                    }
                  }
                },
                child: Text('修改钱包'),
              ),
              RaisedButton(
                onPressed: () async {
                  var wallets = await WalletUtil.scanWallets();
                  if (wallets.length > 0) {
                    //修改第一个账户密码吧
                    var wallet = wallets[0];
                    print('-即将修改${wallet.keystore.fileName} 的密码');
                    var success = await WalletUtil.updateWallet(
                        wallet: wallet, password: '111111_wrong', newPassword: "new password", name: '修改的钱包');
                    if (success) {
                      print('-修改密码成功');
                      print('-最后成为${wallet.keystore.fileName}');
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
                      var prvKey =
                          await WalletUtil.exportPrivateKey(fileName: wallet.keystore.fileName, password: '111111');
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
                          fileName: wallet.keystore.fileName, password: '111111_wrong');
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
                        var mnemonic =
                            await WalletUtil.exportMnemonic(fileName: wallet.keystore.fileName, password: '111111');
                        logger.i('your mnemonic is: $mnemonic');
                      } else {
                        print('-不是TrustWallet钱包，不支持导出助记词');
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
                            fileName: wallet.keystore.fileName, password: '111111_wrong');
                        logger.i('your mnemonic is: $mnemonic');
                      } else {
                        print('-不是TrustWallet钱包，不支持导出助记词');
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
              var password = '111111';
              var wallets = await WalletUtil.scanWallets();
              for (var wallet in wallets) {
                var result = await wallet.delete(password);
                print("-删除结果 ${wallet.keystore.fileName} $result");
              }

              wallets = await WalletUtil.scanWallets();
              if (wallets.length == 0) {
                BlocProvider.of<WalletCmpBloc>(context).add(ActiveWalletEvent(wallet: null));
              } else {
                BlocProvider.of<WalletCmpBloc>(context).add(ActiveWalletEvent(wallet: wallets[0]));
              }
            },
            child: Text('删除所有钱包'),
          ),
          Divider(
            height: 16,
          ),
          RaisedButton(
            onPressed: () async {
              var activeWallet = WalletInheritedModel.of(context).activatedWallet.wallet;
              if (activeWallet != null) {
                final client = WalletUtil.getWeb3Client();
                var ethAddress = activeWallet.getEthAccount().address;

//                var transactionHash = '0x9f86f325e64a0c9f947141e901575d11f89e3966e9b470662f0af25e9abc8852';
//                if (transactionHash != null && transactionHash.length > 0) {
////                  var transaction = await client.getTransactionByHash(transactionHash);
////                  if(transaction != null) {
////                    logger.i(transaction);
////                  }
//
//                  var transactionReceipt = await client.getTransactionReceipt(transactionHash);
//                  if (transactionReceipt != null) {
//                    logger.i("transactionReceipt ${transactionReceipt.status}");
//                  } else {
//                    print('transactionReceipt is null');
//                  }
//                }

                var count = await client.getTransactionCount(EthereumAddress.fromHex(ethAddress));
                logger.i('pending nonce is $count');
              }
            },
            child: Text('查看nonce'),
          ),
          RaisedButton(
            onPressed: () async {
              var gas = await WalletUtil.ethGasPrice();
              logger.i('-油费是 $gas ${gas / BigInt.from(TokenUnit.G_WEI)}');
            },
            child: Text('查看以太坊油费'),
          ),
          RaisedButton(
            onPressed: () async {
              var toAddress = '0xe7147924489DbA4b6eF71CFC3b0615eD74C34c39';
              var amount = 0.0; //13.45;

              var wallets = await WalletUtil.scanWallets();
              if (wallets.isNotEmpty) {
                var wallet = wallets.first;
                var createNodeWalletAddress = wallet.getEthAccount().address; //创建节点合约的钱包地址
                double myStaking = 100000; //我要抵押的量
                var gasLimit = 1000000; //TODO 暂定的，到时候要调成合适的.

                var funAbi = WalletUtil.getMap3FuncAbiHex(
                    contractAddress: WalletConfig.map3ContractAddress,
                    funName: 'delegate',
                    params: [
                      EthereumAddress.fromHex(createNodeWalletAddress),
                      ConvertTokenUnit.etherToWei(etherDouble: myStaking)
                    ]);
                var ret = await wallet.estimateGasPrice(
                  toAddress: WalletConfig.map3ContractAddress,
                  value: ConvertTokenUnit.etherToWei(etherDouble: amount),
                  gasPrice: BigInt.from(EthereumConst.SUPER_FAST_SPEED),
                  gasLimit: BigInt.from(gasLimit),
                  data: funAbi,
                );
                logger.i('estimateGasPrice $ret');
              } else {
                print('-无钱包');
              }
            },
            child: Text('查看交易费率'),
          ),
          RaisedButton(
            onPressed: () async {
              try {
                var password = '111111';
                var amount = ConvertTokenUnit.etherToWei(etherDouble: 0.01); //.toRadixString(16);
                var wallet = WalletInheritedModel.of(context).activatedWallet;
                if (wallet != null) {
                  var toAddress = '0x70247395aFFd13C2347aA8c748225f1bFeD2C32A';

                  final txHash = await wallet.wallet.sendEthTransaction(
                    password: password,
                    toAddress: toAddress,
                    gasPrice: BigInt.from(EthereumConst.FAST_SPEED),
                    value: amount,
                  );

                  logger.i('ETH交易已提交，交易hash $txHash');
                }
              } catch (e) {
                logger.e(e);
              }
            },
            child: Text('ETH转账'),
          ),
          RaisedButton(
            onPressed: () async {
              try {
                var activeWallet = WalletInheritedModel.of(context).activatedWallet.wallet;
                if (activeWallet != null) {
                  var password = '111111';
                  var amount = ConvertTokenUnit.etherToWei(etherDouble: 1000000000000000); //.toRadixString(16);
                  var hynErc20ContractAddress = activeWallet.getEthAccount().contractAssetTokens[0].contractAddress;

                  var toAddress = '0x89A9855032047fAF65BAA95F43128af6EE5721eD';

                  final txHash = await activeWallet.sendErc20Transaction(
                    contractAddress: hynErc20ContractAddress,
                    password: password,
                    value: amount,
                    toAddress: toAddress,
                    gasPrice: BigInt.from(EthereumConst.FAST_SPEED),
                  );

                  logger.i('HYN交易已提交，交易hash $txHash');
                }
              } catch (e) {
                logger.e(e);
              }
            },
            child: Text('HYN转账'),
          ),
          RaisedButton(
            onPressed: () async {
              try {
                var password = '111111';
                Map<String, dynamic> params = {"a": 1, "d": 'd_p', "c": 'c_p', 'b': 'b_p'};
                await Signer.signMessage(context, password, params);
                print(params);
              } catch (e) {
                logger.e(e);
              }
            },
            child: Text('API签名'),
          ),
          RaisedButton(
            onPressed: () async {
              try {
                var activeWallet = WalletInheritedModel.of(context).activatedWallet.wallet;
                var hashTx = await activeWallet.sendBitcoinTransaction("111111", activeWallet.getBitcoinZPub(), "bc1q5ldpsdpnds87wkvtgss9us2zf6rmtr80qeelzc", 13, 10000);
                logger.i('Bitcoin交易已提交，交易hash $hashTx');
              } catch (e) {
                logger.e(e);
              }
            },
            child: Text('比特币转账'),
          ),
          RaisedButton(
            onPressed: () async {
              try {
                var activeWallet = WalletInheritedModel.of(context).activatedWallet.wallet;
                var encryptMsg = await TitanPlugin.activeEncrypt("abcabcabc", "111111", activeWallet.keystore.fileName);
                logger.i('位置加密激活msg ${json.encode(encryptMsg).toString()}');
              } catch (e) {
                logger.e(e);
              }
            },
            child: Text('激活位置加密'),
          ),
          RaisedButton(
            onPressed: () async {
              try {
                var encryptMsg = await TitanPlugin.encrypt("0x024f5df535b366ff60105cd2423a66e8eda8d00184676449e7b6856188628575f2", "abcabc111");
                logger.i('位置加密msg ${json.encode(encryptMsg).toString()}');
              } catch (e) {
                logger.e(e);
              }
            },
            child: Text('位置加密'),
          ),
          RaisedButton(
            onPressed: () async {
              try {
                var activeWallet = WalletInheritedModel.of(context).activatedWallet.wallet;
                var encryptMsg = await TitanPlugin.decrypt("C85bouB1T6Pzoe4RqpQZqaaGnzhBDgVqvkkp3ayCR9v281tD2skF9azhrY63kdP1BE7W5vKDN7vtqp5wrcU4CrPxFgD7Jhdm7CmLBqTCDsmLZfurik9WbJAMi7tk82vr22uMkjaA5W5gpXEzhpvpZ1Pg2GwPbp6nxcQbov", "111111", activeWallet.keystore.fileName);
                logger.i('位置解密msg $encryptMsg');
              } catch (e) {
                logger.e(e);
              }
            },
            child: Text('位置解密'),
          )
        ],
      ),
    );
  }
}
