import 'dart:math';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:titan/src/components/setting/setting_component.dart';
import 'package:titan/src/components/wallet/bloc/bloc.dart';
import 'package:titan/src/components/wallet/wallet_component.dart';
import 'package:titan/src/global.dart';
import 'package:titan/src/pages/atlas_map/api/atlas_api.dart';
import 'package:titan/src/pages/atlas_map/entity/pledge_map3_entity.dart';
import 'package:titan/src/pages/atlas_map/entity/user_payload_with_address_entity.dart';
import 'package:titan/src/plugins/wallet/account.dart';
import 'package:titan/src/plugins/wallet/cointype.dart';
import 'package:titan/src/plugins/wallet/config/bitcoin.dart';
import 'package:titan/src/plugins/wallet/config/ethereum.dart';
import 'package:titan/src/plugins/wallet/config/heco.dart';
import 'package:titan/src/plugins/wallet/config/hyperion.dart';
import 'package:titan/src/plugins/wallet/convert.dart';
import 'package:titan/src/plugins/wallet/keystore.dart';
import 'package:titan/src/plugins/wallet/wallet_util.dart';
import 'package:titan/src/widget/keyboard/wallet_password_dialog.dart';
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
        title: Text("Wallet Demo"),
      ),
      body: ListView(
        shrinkWrap: true,
        padding: EdgeInsets.all(16),
        children: <Widget>[
          RaisedButton(
            onPressed: () async {
              var index = EthereumChainType.values.indexOf(EthereumConfig.chainType);
              setState(() {
                EthereumConfig.chainType = EthereumChainType.values[(index + 1) % EthereumChainType.values.length];
              });
            },
            child: Text('Ethereum chain -> ${EthereumConfig.chainType.toString().split('.')[1]}'),
          ),
          Divider(
            height: 2,
          ),
          RaisedButton(
            onPressed: () async {
              var index = HyperionChainType.values.indexOf(HyperionConfig.chainType);
              setState(() {
                HyperionConfig.chainType = HyperionChainType.values[(index + 1) % HyperionChainType.values.length];
              });
            },
            child: Text('Hyperion chain -> ${HyperionConfig.chainType.toString().split('.')[1]}'),
          ),
          Divider(
            height: 2,
          ),
          RaisedButton(
            onPressed: () async {
              var index = HecoChainType.values.indexOf(HecoConfig.chainType);
              setState(() {
                HecoConfig.chainType = HecoChainType.values[(index + 1) % HecoChainType.values.length];
              });
            },
            child: Text('Heco chain -> ${HecoConfig.chainType.toString().split('.')[1]}'),
          ),
          Divider(
            height: 2,
          ),
          RaisedButton(
            onPressed: () async {
              var index = BitcoinChainType.values.indexOf(BitcoinConfig.chainType);
              setState(() {
                BitcoinConfig.chainType = BitcoinChainType.values[(index + 1) % BitcoinChainType.values.length];
              });
            },
            child: Text('Bitcoin chain -> ${BitcoinConfig.chainType.toString().split('.')[1]}'),
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
            child: Text('激活一号钱包'),
          ),
          RaisedButton(
            onPressed: () async {
              _mnemonic = await WalletUtil.makeMnemonic();
//              return ;

//              ripple scissors kick mammal hire column oak again sun offer wealth tomorrow wagon turn fatal  //常用的测试网
//              because certain august huge empower blue half pepper tunnel trust amazing forget  //测试网私钥

//              _mnemonic = 'motion clip lunch rebel use bag fashion indicate ten mushroom loop miracle'; //1
//              _mnemonic = 'pizza another fault reduce choose bronze zebra attitude pottery repair spider person'; //2
//              _mnemonic = 'enrich rail nature figure legend bright bird habit page project silk wrap'; //3
//              _mnemonic = 'rifle beyond crime insect spider mention mirror ripple mixed pulse perfect nerve';//4
//              _mnemonic = 'like parent salmon record drop weapon friend obey planet raven desert grit';  //5
//              _mnemonic = 'post diamond chimney type armed seed absurd doll dream law fan hollow';//6 0x9068736a8f1aFaeBf9231c2d979CDCe3235f4eEE
//              _mnemonic = 'park vapor mind eagle depth witness liquid effort helmet margin attitude topple';//7 0xA167fa1e7B240B70b30861a819CF37C8F7fccE94
//              _mnemonic = 'rebel stand list ladder argue sentence night episode aisle steel amateur bid';//8 0x68846029FE9907612A656c6b24b8c17697786676

              if (!bip39.validateMnemonic(_mnemonic)) {
                Fluttertoast.showToast(msg: '不是合法的助记词');
                return;
              }

              //var walletName = "我的助记词钱包1";
              var walletName = _mnemonic.split(" ").first;
              var password = '111111';
              var wallet = await WalletUtil.storeByMnemonic(name: walletName, password: password, mnemonic: _mnemonic);
              if (wallet != null) {
                var userPayload = UserPayloadWithAddressEntity(
                    Payload(userName: wallet.keystore.name), wallet.getAtlasAccount().address);
                AtlasApi.postUserSync(userPayload);
                _mnemonic = null;
                //激活它
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
              var activeWallet = WalletInheritedModel.of(context).activatedWallet?.wallet;
              if (activeWallet != null) {
                var balance;
                Account account = activeWallet.getAtlasAccount();
                if (account != null) {
                  // balance = await activeWallet.getBalance(account);
                  balance = await WalletUtil.getBalanceByCoinTypeAndAddress(CoinType.HYN_ATLAS, '0x89A9855032047fAF65BAA95F43128af6EE5721eD', HyperionConfig.hynRPHrc30Address);
                  print(
                      "账户0x89A9855032047fAF65BAA95F43128af6EE5721eD RP 余额是 ${balance / BigInt.from(pow(10, account.token.decimals))}");

                  // balance = await activeWallet.getErc20Balance(account, EthereumConfig.getHynErc20Address);
                  // print("账户${account.address} HYN-erc20 余额是 ${balance / BigInt.from(pow(10, account.token.decimals))}");
                }
              }
            },
            child: Text('查看钱包主链币余额'),
          ),
          Divider(
            height: 16,
          ),
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
                var nonce = await activeWallet.getCurrentWalletNonce(CoinType.ETHEREUM);
                logger.i('pending nonce is $nonce');
              }
            },
            child: Text('查看 ethereum nonce'),
          ),
          RaisedButton(
            onPressed: () async {
              var gas = await WalletUtil.ethGasPrice(CoinType.ETHEREUM);
              logger.i('-油费是 ${gas / BigInt.from(EthereumUnitValue.G_WEI)} GWEI');
            },
            child: Text('ethereum gas price'),
          ),
          RaisedButton(
            onPressed: () async {
              var amount = 0.0; //13.45;
              var wallet = WalletInheritedModel.of(context).activatedWallet.wallet;
              if (wallet != null) {
                var createNodeWalletAddress = wallet.getEthAccount().address; //创建节点合约的钱包地址
                double myStaking = 100000; //我要抵押的量
                var gasLimit = 1000000; //TODO 暂定的，到时候要调成合适的.
                var gasPriceRecommend =
                    WalletInheritedModel.of(context, aspect: WalletAspect.gasPrice).ethGasPriceRecommend;

                var funAbi = WalletUtil.getMap3FuncAbiHex(
                    contractAddress: EthereumConfig.map3EthereumContractAddress,
                    funName: 'delegate',
                    params: [
                      EthereumAddress.fromHex(createNodeWalletAddress),
                      ConvertTokenUnit.etherToWei(etherDouble: myStaking)
                    ]);
                var ret = await wallet.estimateGasPrice(
                  CoinType.ETHEREUM,
                  toAddress: EthereumConfig.map3EthereumContractAddress,
                  value: ConvertTokenUnit.etherToWei(etherDouble: amount),
                  gasPrice: BigInt.from(gasPriceRecommend.average.toInt()),
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
                var wallet = WalletInheritedModel.of(context).activatedWallet;
                if (wallet != null) {
                  var password = '111111';
                  var amount = ConvertTokenUnit.etherToWei(etherDouble: 0.01); //.toRadixString(16);
                  var gasPrice = EthereumGasPrice.getRecommend().averageBigInt;
                  var toAddress = '0x89A9855032047fAF65BAA95F43128af6EE5721eD';
                  final txHash = await wallet.wallet.sendTransaction(
                    CoinType.ETHEREUM,
                    password: password,
                    toAddress: toAddress,
                    gasPrice: gasPrice,
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
                  var amount = ConvertTokenUnit.etherToWei(etherDouble: 1); //.toRadixString(16);

                  var toAddress = '0x89A9855032047fAF65BAA95F43128af6EE5721eD';

                  final txHash = await activeWallet.sendErc20Transaction(
                    CoinType.ETHEREUM,
                    password: password,
                    value: amount,
                    toAddress: toAddress,
                    contractAddress: EthereumConfig.getHynErc20Address,
                    gasPrice: EthereumGasPrice.getRecommend().averageBigInt,
                  );

                  logger.i('HYN交易已提交，交易hash $txHash');
                }
              } catch (e, st) {
                print(st);
                logger.e(e);
              }
            },
            child: Text('HYN erc20 转账'),
          ),
          RaisedButton(
            onPressed: () async {
              try {
                var password = '111111';
                Map<String, dynamic> params = {"a": 1, "d": 'd_p', "c": 'c_p', 'b': 'b_p'};
//                await Signer.signMessage(context, password, params);
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
                var hashTx = await activeWallet.sendBitcoinTransaction(
                    "111111", activeWallet.getBitcoinZPub(), "bc1q5ldpsdpnds87wkvtgss9us2zf6rmtr80qeelzc", 13, 10000);
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
                var password = showDialog(
                    context: context,
                    barrierDismissible: false,
                    child: WalletPasswordDialog(
                      checkPwdValid: (walletPwd) {
                        return WalletUtil.checkPwdValid(
                          context,
                          WalletInheritedModel.of(context).activatedWallet.wallet,
                          walletPwd,
                        );
                      },
                    ));
                print("password $password");
              } catch (e) {
                logger.e(e);
              }
            },
            child: Text('数字键盘'),
          ),
          RaisedButton(
            onPressed: () async {
              try {
                var password = showDialog(
                    context: context,
                    barrierDismissible: false,
                    child: WalletPasswordDialog(
                      checkPwdValid: null,
                      isDoubleCheck: true,
                    ));
                print("password $password");
              } catch (e) {
                logger.e(e);
              }
            },
            child: Text('校验数字键盘'),
          ),
          RaisedButton(
            onPressed: () async {
              try {
                var walletList = await WalletUtil.scanWallets();
                walletList.forEach((element) {
                  print("identifier  ${element.keystore.name} ${element.keystore.identifier}");
                });
              } catch (e) {
                logger.e(e);
              }
            },
            child: Text('identifier'),
          ),
        ],
      ),
    );
  }
}
