import 'package:bitcoin_flutter/bitcoin_flutter.dart' as bitcoin;
import 'package:decimal/decimal.dart';
import 'package:ethereum_address/ethereum_address.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_k_chart/utils/date_format_util.dart';
import 'package:titan/config.dart';
import 'package:titan/src/components/quotes/quotes_component.dart';
import 'package:titan/src/components/setting/setting_component.dart';
import 'package:titan/src/components/wallet/wallet_component.dart';
import 'package:titan/src/data/cache/app_cache.dart';
import 'package:titan/src/pages/market/api/exchange_api.dart';
import 'package:titan/src/pages/wallet/api/etherscan_api.dart';
import 'package:titan/src/pages/webview/webview.dart';
import 'package:titan/src/plugins/wallet/cointype.dart';
import 'package:titan/src/plugins/wallet/convert.dart';
import 'package:titan/src/plugins/wallet/token.dart';
import 'package:titan/src/plugins/wallet/wallet.dart';
import 'package:titan/src/plugins/wallet/wallet_const.dart';
import 'package:titan/src/plugins/wallet/wallet_util.dart';
import 'package:titan/src/utils/utile_ui.dart';
import 'package:bip39/bip39.dart' as bip39;
import "package:convert/convert.dart" show hex;
import 'package:web3dart/web3dart.dart' as web3;

class AddressData {
  String name;
  String address;
  Decimal ethBalance;
  Decimal usdtBalance;
  Decimal hynBanlance;
  int type;

  AddressData({this.name, this.address, this.ethBalance, this.hynBanlance, this.usdtBalance, this.type});
}

class MMData {
  String uid;

  // String address;
  String key;
  Decimal usdtBalance;
  Decimal hynBalance;

  MMData({
    this.uid,
    this.key,
    this.usdtBalance,
    this.hynBalance,
  });
}

class AddressIndex {
  static const int GAS = 10;
  static const int C_HYN = 1;
  static const int C_USDT = 2;
}

class DexWalletManagerPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _DexWalletManagerPageState();
  }
}

class _DexWalletManagerPageState extends State<DexWalletManagerPage> {
  Wallet wallet;

  ExchangeApi _exchangeApi = ExchangeApi();

  GlobalKey<FormState> _formKeyTransfer = GlobalKey<FormState>(debugLabel: '转账');
  GlobalKey<FormState> _formKeyMM = GlobalKey<FormState>(debugLabel: 'MM');
  var _mmTextEditorController = TextEditingController();
  var _addressTextEditorController = TextEditingController();
  var _amountTextEditorController = TextEditingController();
  var _toAddress = '';
  var _amount = Decimal.zero;
  var _mmAmount = Decimal.zero;

  bool _isRefreshing = false;

  String pwd;

  List<AddressData> accounts = [];
  List<MMData> mmList = [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    wallet = WalletInheritedModel.of(context).activatedWallet?.wallet;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('链上子钱包'),
        actions: <Widget>[
          FlatButton(
            child: Text(
              '刷新',
              style: TextStyle(color: Colors.white),
            ),
            onPressed: () {
              refreshBalance();
            },
          )
        ],
      ),
      backgroundColor: Theme.of(context).backgroundColor,
      body: accounts.length == 0
          ? Center(
              child: RaisedButton(
              child: Text('解锁子账户'),
              onPressed: () async {
                var password = await UiUtil.showWalletPasswordDialogV2(
                  context,
                  wallet,
                );
                pwd = password;
                var mnemonic = await WalletUtil.exportMnemonic(fileName: wallet.keystore.fileName, password: password);

                var seed = bip39.mnemonicToSeed(mnemonic);
                var hdWallet = bitcoin.HDWallet.fromSeed(seed);
                var ethWallet = hdWallet.derivePath("${Config.M_Main_Path}${AddressIndex.GAS}");
                var ethAddress = ethereumAddressFromPublicKey(hex.decode(ethWallet.pubKey));
                List<AddressData> accs = [];
                var account = await newAddressData('归GAS', ethAddress, AddressIndex.GAS);
                accs.add(account);

                ethWallet = hdWallet.derivePath("${Config.M_Main_Path}${AddressIndex.C_HYN}");
                ethAddress = ethereumAddressFromPublicKey(hex.decode(ethWallet.pubKey));
                account = await newAddressData('HYN 归/出', ethAddress, AddressIndex.C_HYN);
                accs.add(account);

                ethWallet = hdWallet.derivePath("${Config.M_Main_Path}${AddressIndex.C_USDT}");
                ethAddress = ethereumAddressFromPublicKey(hex.decode(ethWallet.pubKey));
                account = await newAddressData('U 归/出', ethAddress, AddressIndex.C_USDT);
                accs.add(account);
                setState(() {
                  accounts = accs;
                });

                refreshBalance();
              },
            ))
          : SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  if (_isRefreshing) Text('刷新余额中...'),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: <Widget>[
                        Text('MM'),
                        Spacer(),
                        RaisedButton(
                          child: Text('刷新'),
                          onPressed: () async {
                            await updateMMList();
                            setState(() {});
                          },
                        ),
                      ],
                    ),
                  ),
                  for (var mmData in mmList) buildMMItem(mmData),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: <Widget>[
                        Text('子钱包'),
                        Spacer(),
                      ],
                    ),
                  ),
                  for (var item in accounts) buildAccountItem(context, item),
                ],
              ),
            ),
    );
  }

  Widget buildMMOptAccountDialogView(Decimal balance, int type, bool isAdd) {
    return Material(
      child: Form(
        key: _formKeyMM,
        child: Column(
          children: <Widget>[
            Row(
              children: <Widget>[
                Text(isAdd ? '加' : '减'),
                SizedBox(width: 2),
                Text('(余额 $balance)'),
              ],
            ),
            TextFormField(
              controller: _mmTextEditorController,
              decoration: InputDecoration(
                hintText: '请输入${isAdd ? '加' : '减'}数量...',
              ),
              validator: (value) {
                if (value.length == 0) {
                  return '请输入数量';
                }
                var amount = Decimal.parse(value);
                if (amount <= Decimal.zero) {
                  return '${isAdd ? '加' : '减'}数量必须大于0';
                }
                if (!isAdd && amount > balance) {
                  return '余额不足';
                }
                return null;
              },
              keyboardType: TextInputType.text,
              onSaved: (value) {
                _mmAmount = Decimal.parse(value);
                _mmTextEditorController.text = '';
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget buildTransferDialogView(AddressData addressData, int optType) {
    var balance = getBalanceByType(addressData, optType);
    return Material(
      child: Form(
        key: _formKeyTransfer,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text('从'),
                Text(
                  '${addressData.name} (可用 $balance)',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                ),
              ],
            ),
            SizedBox(
              height: 8,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text('到'),
                TextFormField(
                  controller: _addressTextEditorController,
                  decoration: InputDecoration(
                    hintText: '请输入转出地址...',
                  ),
                  validator: (value) {
                    if (value.length == 0) {
                      return '请输入收款地址';
                    }
                    bool isEthAddress = isValidEthereumAddress(value);
                    if (!isEthAddress) {
                      return '收款地址格式不符合规范';
                    }
                    return null;
                  },
                  keyboardType: TextInputType.text,
                  onSaved: (value) {
                    _toAddress = value;
                    _addressTextEditorController.text = '';
                  },
                ),
              ],
            ),
            SizedBox(
              height: 8,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text('转出${getTypeName(optType)}数目'),
                TextFormField(
                  controller: _amountTextEditorController,
                  decoration: InputDecoration(
                    hintText: '请输入转出数目...',
                  ),
                  validator: (value) {
                    if (value.length == 0) {
                      return '请输入转账数目';
                    }
                    if (addressData.ethBalance == Decimal.zero) {
                      return 'gas费不足';
                    }
                    var amount = Decimal.parse(value);
                    if (amount <= Decimal.zero) {
                      return '提款值必须大于0';
                    }
                    if (amount > balance) {
                      return '余额不足';
                    }

                    return null;
                  },
                  keyboardType: TextInputType.number,
                  onSaved: (value) {
                    _amount = Decimal.parse(value);
                    _amountTextEditorController.text = '';
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget buildAccountItem(BuildContext context, AddressData addressData) {
    return Container(
      color: Colors.white,
      margin: EdgeInsets.only(top: 1),
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: InkWell(
        onTap: () {
          openAddressWebPage(addressData.address);
        },
        child: Row(
          children: <Widget>[
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(addressData.name, style: TextStyle(fontWeight: FontWeight.w600)),
                Text(
                  UiUtil.shortEthAddress(addressData.address),
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
                SizedBox(height: 2),
                Row(
                  children: <Widget>[
                    Text(
                      'ETH',
                      style: TextStyle(fontSize: 13),
                    ),
                    SizedBox(width: 4),
                    Text(addressData.ethBalance.toString(), style: TextStyle(fontSize: 13)),
                  ],
                ),
                Row(
                  children: <Widget>[
                    Text(
                      'USDT',
                      style: TextStyle(fontSize: 13),
                    ),
                    SizedBox(width: 4),
                    Text(addressData.usdtBalance.toString(), style: TextStyle(fontSize: 13)),
                  ],
                ),
                Row(
                  children: <Widget>[
                    Text('HYN', style: TextStyle(fontSize: 13)),
                    SizedBox(width: 4),
                    Text(addressData.hynBanlance.toString(), style: TextStyle(fontSize: 13)),
                  ],
                ),
              ],
            ),
            Spacer(),
            SizedBox(
              width: 50,
              height: 32,
              child: RaisedButton(
                child: Text('提'),
                onPressed: () async {
                  var type = await selectTokenType(context);
                  if (![AddressIndex.C_HYN, AddressIndex.C_USDT, AddressIndex.GAS].contains(type)) {
                    return;
                  }
                  UiUtil.showDialogWidget(context,
                      title: Text('转账'),
                      content: buildTransferDialogView(addressData, type),
                      actions: [
                        FlatButton(
                          child: Text('取消'),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                        ),
                        FlatButton(
                            child: Text('确定'),
                            onPressed: () async {
                              if (_formKeyTransfer.currentState.validate()) {
                                _formKeyTransfer.currentState.save();

                                Navigator.pop(context);

                                var password = await UiUtil.showWalletPasswordDialogV2(
                                  context,
                                  wallet,
                                );

                                var mnemonic = await WalletUtil.exportMnemonic(
                                    fileName: wallet.keystore.fileName, password: password);
                                var seed = bip39.mnemonicToSeed(mnemonic);
                                var hdWallet = bitcoin.HDWallet.fromSeed(seed);
                                var ethWallet = hdWallet.derivePath("${Config.M_Main_Path}$type");
                                final client = WalletUtil.getWeb3Client();
                                final credentials = await client.credentialsFromPrivateKey(ethWallet.privKey);

                                var txhash = '';

                                if (type == AddressIndex.GAS) {
                                  //需要转ETH
                                  try {
                                    txhash = await client.sendTransaction(
                                      credentials,
                                      web3.Transaction(
                                        to: web3.EthereumAddress.fromHex(_toAddress),
                                        gasPrice: web3.EtherAmount.inWei(BigInt.from(
                                            QuotesInheritedModel.of(context).gasPriceRecommend.fast.toInt())),
                                        maxGas: 21000,
                                        value: web3.EtherAmount.inWei(ConvertTokenUnit.decimalToWei(_amount)),
                                      ),
                                      fetchChainIdFromNetworkId: true,
                                    );
                                  } catch (e) {
                                    print(e);
                                    UiUtil.toast('转账异常');
                                  }
                                } else {
                                  try {
                                    var contract;
                                    var decimals;
                                    if (type == AddressIndex.C_USDT) {
                                      contract = WalletUtil.getHynErc20Contract(WalletConfig.getUsdtErc20Address());
                                      decimals = SupportedTokens.USDT_ERC20.decimals;
                                    } else if (type == AddressIndex.C_HYN) {
                                      contract = WalletUtil.getHynErc20Contract(WalletConfig.getHynErc20Address());
                                      decimals = SupportedTokens.HYN.decimals;
                                    } else {
                                      UiUtil.toast('错误的类型 $type');
                                      return;
                                    }
                                    txhash = await client.sendTransaction(
                                      credentials,
                                      web3.Transaction.callContract(
                                        contract: contract,
                                        function: contract.function('transfer'),
                                        parameters: [
                                          web3.EthereumAddress.fromHex(_toAddress),
                                          ConvertTokenUnit.decimalToWei(_amount, decimals)
                                        ],
                                        gasPrice: web3.EtherAmount.inWei(BigInt.from(
                                            QuotesInheritedModel.of(context).gasPriceRecommend.fast.toInt())),
                                        maxGas: 65000,
                                      ),
                                      fetchChainIdFromNetworkId: true,
                                    );
                                  } catch (e) {
                                    print(e);
                                    UiUtil.toast('转账异常');
                                  }
                                }

                                print('txhash $txhash');
                                UiUtil.toast('广播成功，请等待成功后再执行其他转账');
                              }
                            })
                      ]);
                },
              ),
            ),
            SizedBox(
              width: 2,
            ),
            SizedBox(
              width: 50,
              height: 32,
              child: RaisedButton(
                child: Text('充'),
                onPressed: () async {
                  await Clipboard.setData(new ClipboardData(text: addressData.address));
                  UiUtil.toast('地址复制成功');
                },
              ),
            ),
            SizedBox(
              width: 2,
            ),
            SizedBox(
              width: 50,
              height: 32,
              child: RaisedButton(
                child: Text('刷'),
                onPressed: () {
                  refreshBalanceOfAccount(addressData);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void openAddressWebPage(address) {
    var url = EtherscanApi.getAddressDetailUrl(
        address, SettingInheritedModel.of(context, aspect: SettingAspect.area).areaModel.isChinaMainland);
    if (url != null) {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => WebViewContainer(
                    initUrl: url,
                    title: "",
                  )));
    }
  }

  Future<String> getCachedBalance(String address) async {
    return await AppCache.getValue("mm-$address");
  }

  Future updateBalanceOfAddress(AddressData addressData) async {
    var ret = await Future.wait([
      WalletUtil.getBalanceByCoinTypeAndAddress(CoinType.ETHEREUM, addressData.address),
      WalletUtil.getBalanceByCoinTypeAndAddress(
          CoinType.ETHEREUM, addressData.address, WalletConfig.getHynErc20Address()),
      WalletUtil.getBalanceByCoinTypeAndAddress(
          CoinType.ETHEREUM, addressData.address, WalletConfig.getUsdtErc20Address()),
    ]);
    var ethBalance = ret[0];
    var hynBalance = ret[1];
    var usdtBalance = ret[2];

    addressData.ethBalance = ConvertTokenUnit.weiToDecimal(ethBalance);
    addressData.hynBanlance = ConvertTokenUnit.weiToDecimal(hynBalance);
    addressData.usdtBalance = ConvertTokenUnit.weiToDecimal(usdtBalance, SupportedTokens.USDT_ERC20.decimals);

    print("'mm-${addressData.address}', '$ethBalance,$hynBalance,$usdtBalance'");
    await AppCache.saveValue('mm-${addressData.address}', '$ethBalance,$hynBalance,$usdtBalance');
  }

  Future<AddressData> newAddressData(String name, String address, int type) async {
    Decimal ethBalance;
    Decimal hynBalance;
    Decimal usdtBalance;
    var balanceStr = await getCachedBalance(address);
    if (balanceStr != null && balanceStr.isNotEmpty) {
      var ary = balanceStr.split(',');
      if (ary.length == 3) {
        ethBalance = ConvertTokenUnit.weiToDecimal(BigInt.parse(ary[0]));
        hynBalance = ConvertTokenUnit.weiToDecimal(BigInt.parse(ary[1]));
        usdtBalance = ConvertTokenUnit.weiToDecimal(BigInt.parse(ary[2]), SupportedTokens.USDT_ERC20.decimals);
      } else {
        ethBalance = Decimal.zero;
        hynBalance = Decimal.zero;
        usdtBalance = Decimal.zero;
      }
    }
    return AddressData(
        name: name,
        address: address,
        ethBalance: ethBalance,
        hynBanlance: hynBalance,
        usdtBalance: usdtBalance,
        type: type);
  }

  void refreshBalance() async {
    setState(() {
      _isRefreshing = true;
    });

    await updateMMList();

    await Future.wait(accounts.map((account) => updateBalanceOfAddress(account)));

    setState(() {
      _isRefreshing = false;
    });
  }

  void refreshBalanceOfAccount(AddressData addressData) async {
    await updateBalanceOfAddress(addressData);
    setState(() {
      print('update ${addressData.address} done');
    });
  }

  Future updateMMList() async {
    var rets = await _exchangeApi.walletSignAndPost(
      path: Config.MM_ACCOUNT_INFO,
      wallet: wallet,
      password: pwd,
      address: wallet.getEthAccount().address,
    );
    if (rets is List && rets.length > 0) {
      mmList.clear();
      for (var ret in rets) {
        var mmData = MMData(
          uid: ret['uid'],
          key: ret['key'],
          hynBalance: Decimal.parse(ret['assets']['HYN']['total']),
          usdtBalance: Decimal.parse(ret['assets']['USDT']['total']),
        );
        mmList.add(mmData);
      }
    }
  }

  Decimal getBalanceByType(AddressData addressData, int optType) {
    var balance = Decimal.zero;
    switch (optType) {
      case AddressIndex.GAS:
        balance = addressData.ethBalance;
        break;
      case AddressIndex.C_HYN:
        balance = addressData.hynBanlance;
        break;
      case AddressIndex.C_USDT:
        balance = addressData.usdtBalance;
        break;
    }
    return balance;
  }

  String getTypeName(int optType) {
    var name = '';
    switch (optType) {
      case AddressIndex.GAS:
        name = 'ETH';
        break;
      case AddressIndex.C_HYN:
        name = 'HYN';
        break;
      case AddressIndex.C_USDT:
        name = 'USDT';
        break;
    }
    return name;
  }

  Future<int> selectTokenType(BuildContext context, [bool includeEth = true]) {
    return showModalBottomSheet(
      context: context,
      builder: (context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            InkWell(
                onTap: () {
                  Navigator.pop(context, AddressIndex.C_HYN);
                },
                child: Container(
                  child: Text('HYN'),
                  color: Colors.white,
                  padding: EdgeInsets.only(top: 16, bottom: 16, left: 32),
                )),
            InkWell(
                onTap: () {
                  Navigator.pop(context, AddressIndex.C_USDT);
                },
                child: Container(
                  child: Text('USDT'),
                  color: Colors.white,
                  padding: EdgeInsets.only(top: 16, bottom: 16, left: 32),
                  margin: EdgeInsets.only(top: 2),
                )),
            if (includeEth)
              InkWell(
                  onTap: () {
                    Navigator.pop(context, AddressIndex.GAS);
                  },
                  child: Container(
                      child: Text('ETH'),
                      color: Colors.white,
                      padding: EdgeInsets.only(top: 16, bottom: 16, left: 32),
                      margin: EdgeInsets.only(top: 2))),
          ],
        );
      },
    );
  }

  Widget buildMMItem(MMData mmData) {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      margin: EdgeInsets.only(top: 1),
      child: Row(
        children: <Widget>[
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                UiUtil.shortEthAddress(mmData.uid),
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              Row(
                children: <Widget>[
                  Text(
                    'key:${UiUtil.shortEthAddress(mmData.key)}',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
              SizedBox(
                height: 4,
              ),
              Row(
                children: <Widget>[
                  Text(
                    'USDT',
                    style: TextStyle(fontSize: 13),
                  ),
                  SizedBox(width: 4),
                  Text(mmData.usdtBalance.toString(), style: TextStyle(fontSize: 13)),
                ],
              ),
              Row(
                children: <Widget>[
                  Text(
                    'HYN',
                    style: TextStyle(fontSize: 13),
                  ),
                  SizedBox(width: 4),
                  Text(mmData.hynBalance.toString(), style: TextStyle(fontSize: 13)),
                ],
              ),
            ],
          ),
          Spacer(),
          SizedBox(
            width: 50,
            height: 32,
            child: RaisedButton(
              child: Text('减'),
              onPressed: () async {
                var type = await selectTokenType(context, false);
                if (![AddressIndex.C_HYN, AddressIndex.C_USDT].contains(type)) {
                  return;
                }
                UiUtil.showDialogWidget(context,
                    title: Text('减少'),
                    content: buildMMOptAccountDialogView(
                        type == AddressIndex.C_HYN ? mmData.hynBalance : mmData.usdtBalance, type, false),
                    actions: [
                      FlatButton(
                        child: Text('取消'),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                      FlatButton(
                          child: Text('确定'),
                          onPressed: () async {
                            if (_formKeyMM.currentState.validate()) {
                              _formKeyMM.currentState.save();

                              Navigator.pop(context);

                              var password = await UiUtil.showWalletPasswordDialogV2(
                                context,
                                wallet,
                              );

                              var rets = await _exchangeApi.walletSignAndPost(
                                path: Config.MM_ACCOUNT_RECHARGE,
                                wallet: wallet,
                                password: pwd,
                                address: wallet.getEthAccount().address,
                                params: {
                                  'uid': mmData.uid,
                                  'type': getTypeName(type),
                                  'balance': (_mmAmount * Decimal.fromInt(-1)).toString()
                                },
                              );

                              await updateMMList();
                              setState(() {});

                              print('TODO 减去 ${mmData.uid} $_mmAmount');
                            }
                          }),
                    ]);
              },
            ),
          ),
          SizedBox(
            width: 2,
          ),
          SizedBox(
            width: 50,
            height: 32,
            child: RaisedButton(
              child: Text('加'),
              onPressed: () async {
                var type = await selectTokenType(context, false);
                if (![AddressIndex.C_HYN, AddressIndex.C_USDT].contains(type)) {
                  return;
                }
                UiUtil.showDialogWidget(context,
                    title: Text('增加'),
                    content: buildMMOptAccountDialogView(
                        type == AddressIndex.C_HYN ? mmData.hynBalance : mmData.usdtBalance, type, true),
                    actions: [
                      FlatButton(
                        child: Text('取消'),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                      FlatButton(
                          child: Text('确定'),
                          onPressed: () async {
                            if (_formKeyMM.currentState.validate()) {
                              _formKeyMM.currentState.save();

                              Navigator.pop(context);

                              var password = await UiUtil.showWalletPasswordDialogV2(
                                context,
                                wallet,
                              );

                              var rets = await _exchangeApi.walletSignAndPost(
                                path: Config.MM_ACCOUNT_RECHARGE,
                                wallet: wallet,
                                password: pwd,
                                address: wallet.getEthAccount().address,
                                params: {'uid': mmData.uid, 'type': getTypeName(type), 'balance': _mmAmount.toString()},
                              );

                              await updateMMList();
                              setState(() {});
                            }
                          }),
                    ]);
              },
            ),
          ),
        ],
      ),
    );
  }
}
