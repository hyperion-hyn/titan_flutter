import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:titan/src/global.dart';
import 'package:titan/src/plugins/wallet/account.dart';
import 'package:titan/src/plugins/wallet/wallet.dart';
import 'package:titan/src/plugins/wallet/wallet_util.dart';

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
          Divider(height: 16,),
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
              var walletName = "我的助记词钱包1";
              var password = "my password";
              var wallet = await WalletUtil.saveAsTrustWalletKeyStoreByMnemonic(
                  name: walletName, password: password, mnemonic: mnemonic);
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
              var prvKey =
                  "afeefca74d9a325cf1d6b6911d61a65c32afa8e02bd5e78e2e4ac2910bab45f5";
              var walletName = "我的密钥钱包1";
              var password = "my password";
              var wallet = await WalletUtil.saveAsTrustWalletKeyStoreByPrvKey(
                  name: walletName, password: password, prvKeyHex: prvKey);
              if (wallet != null) {
                logger.i("已经导入密码钱包 ${wallet.keystore.fileName}");
              } else {
                logger.i("导入密码钱包错误 ");
              }
            },
            child: Text('通过私钥导入'),
          ),
          RaisedButton(
            onPressed: () async {
              var json =
                  '{"address":"3e88208d9bd1eb15b97dea04bdd739eea4d351b6","crypto":{"cipher":"aes-128-ctr","ciphertext":"a4da8ca12244034bea5d609f7eb9e819588bfff1e166b2c89ea7abdfb595b528","cipherparams":{"iv":"0285090551a563ad5ae6596c4a0bc869"},"kdf":"scrypt","kdfparams":{"dklen":32,"n":262144,"p":1,"r":8,"salt":"d9c5fd98901347e64258bdadfc78188ebb8be07392a99de2a24cbbadc4810321"},"mac":"b00629f6a26ae131d1f8e08d529488729bb839810307c5154edb2860bf186191"},"id":"94303270-4f9a-474e-9d46-306ba5dc61c4","version":3}';
              var walletName = "我的密钥钱包1";
              var password = "moo";
              try {
                var wallet = await WalletUtil.saveAsTrustWalletKeyStoreByJson(
                    name: walletName, password: password, keyStoreJson: json);
                if (wallet != null) {
                  logger.i("已经导入JSON钱包 ${wallet.keystore.fileName}");
                } else {
                  logger.i("导入JSON钱包错误 ");
                }
              } on PlatformException catch(e){
                logger.e(e.code);
              }
            },
            child: Text('通过keystore json导入'),
          ),
          RaisedButton(
            onPressed: () async {
              var wallets = await WalletUtil.scanWallets();
              if (wallets.length > 0) {
                print('扫描到的钱包:');
                for (var wallet in wallets) {
                  print("钱包文件路径： ${wallet.keystore.fileName}");
                  if (wallet is TrustWallet) {
                    for (var account in wallet.accounts) {
                      print("账户地址： ${account.address}");
                      print(account.token);
                      print('-------');
                      for (var token in account.erc20AssetTokens) {
                        print(token);
                      }
                    }
                  }
                }
              } else {
                print('没有扫描到钱包');
              }
            },
            child: Text('扫描所有钱包'),
          ),
          RaisedButton(
            onPressed: () async {
              var wallets = await WalletUtil.scanWallets();
              if(wallets.length > 0) {
                //修改第一个账户密码吧
                var wallet = wallets[0];
                print('即将修改${wallet.keystore.fileName} 的密码');
                var success = await wallet.keystore.changePassword(oldPassword: "my password", newPassword: "my password new", name: '修改的钱包');
                if(success) {
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
              for (var wallet in wallets) {
                var result = await wallet.delete();
                print("删除结果 ${wallet.keystore.fileName} $result");
              }
            },
            child: Text('删除所有钱包'),
          ),
          Divider(height: 16,),
          RaisedButton(
            onPressed: () async {
              var wallets = await WalletUtil.scanWallets();
              for (var wallet in wallets) {
                var balance;
                Account account;
                if (wallet is TrustWallet) {
                  account = wallet.getEthAccount();
                } else if (wallet is V3Wallet) {
                  account = wallet.account;
                }
                if (account != null) {
                  balance = await wallet.getBalance(account);
                  print(
                      "账户${account.address} ${account.token.symbol} 余额是 ${balance / BigInt.from(pow(10, account.token.decimals))}");

                  //获取erc20账户余额
                  for (var token in account.erc20AssetTokens) {
                    balance = await wallet
                        .getErc20Balance(token.erc20ContractAddress);
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
        ],
      ),
    );
  }
}
