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
import 'package:titan/src/utils/format_util.dart';
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
  bitcoin.HDWallet hdWallet;

  AddressData({
    this.hdWallet,
    this.name,
    this.address,
    this.ethBalance,
    this.hynBanlance,
    this.usdtBalance,
    this.type,
  });
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
  static const int C_USDT2 = 5;
  static const int M_HYN = 4;
}

class TokenType {
  static const int HYN_MAIN = 1;
  static const int HYN_ERC20 = 2;
  static const int USDT_ERC20 = 3;
  static const int ETH = 4;
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

                if (password == null || password.isEmpty) {
                  return;
                }

                pwd = password;
                var mnemonic = await WalletUtil.exportMnemonic(fileName: wallet.keystore.fileName, password: password);

                var seed = bip39.mnemonicToSeed(mnemonic);
                var hdWallet = bitcoin.HDWallet.fromSeed(seed);
                // 归gas
                var ethWallet;
                var ethAddress;
                var account;
                List<AddressData> accs = [];

                //主hyn
                ethWallet = hdWallet.derivePath("${Config.M_Main_Path}${AddressIndex.M_HYN}");
                ethAddress = ethereumAddressFromPublicKey(hex.decode(ethWallet.pubKey));
                var accountMain = await newAddressData(ethWallet, '主HYN 归/出', ethAddress, AddressIndex.M_HYN);
                accs.add(accountMain);

                // u归2
                ethWallet = hdWallet.derivePath("${Config.M_Main_Path}${AddressIndex.C_USDT2}");
                ethAddress = ethereumAddressFromPublicKey(hex.decode(ethWallet.pubKey));
                account = await newAddressData(ethWallet, 'U 归/出', ethAddress, AddressIndex.C_USDT2);
                accs.add(account);

                //归gas
                ethWallet = hdWallet.derivePath("${Config.M_Main_Path}${AddressIndex.GAS}");
                ethAddress = ethereumAddressFromPublicKey(hex.decode(ethWallet.pubKey));
                var accountGas = await newAddressData(ethWallet, '归GAS', ethAddress, AddressIndex.GAS);
                accs.add(accountGas);

                ethWallet = hdWallet.derivePath("${Config.M_Main_Path}${AddressIndex.C_HYN}");
                ethAddress = ethereumAddressFromPublicKey(hex.decode(ethWallet.pubKey));
                account = await newAddressData(ethWallet, 'HYN 归/出', ethAddress, AddressIndex.C_HYN);
                accs.add(account);

                // ethWallet = hdWallet.derivePath("${Config.M_Main_Path}${AddressIndex.C_USDT}");
                // ethAddress = ethereumAddressFromPublicKey(hex.decode(ethWallet.pubKey));
                // account = await newAddressData(ethWallet, 'U 归/出', ethAddress, AddressIndex.C_USDT);
                // accs.add(account);

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

  Widget buildMMOptAccountDialogView(Decimal balance, bool isAdd) {
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

  Widget buildTransferDialogView(AddressData addressData, int tokenType) {
    var balance = getBalanceByType(addressData, tokenType);
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
                  '${addressData.name} (可用 ${FormatUtil.formatCoinNum(balance?.toDouble() ?? 0)})',
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
                    if (!value.startsWith("hyn1")) {
                      bool isEthAddress = isValidEthereumAddress(value);
                      if (!isEthAddress) {
                        return '收款地址格式不符合规范';
                      }
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
                Text('转出${getTypeName(tokenType)}数目'),
                TextFormField(
                  controller: _amountTextEditorController,
                  decoration: InputDecoration(
                    hintText: '请输入转出数目...',
                  ),
                  validator: (value) {
                    if (value.length == 0) {
                      return '请输入转账数目';
                    }
                    if (addressData.type != AddressIndex.M_HYN) {
                      if (addressData.ethBalance == Decimal.zero) {
                        return 'gas费不足';
                      }
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
                  UiUtil.shortEthAddress(addressData.type == AddressIndex.M_HYN
                      ? WalletUtil.ethAddressToBech32Address(addressData.address)
                      : addressData.address),
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
                if (addressData.type != AddressIndex.M_HYN) SizedBox(height: 2),
                if (addressData.type != AddressIndex.M_HYN)
                  Row(
                    children: <Widget>[
                      Text(
                        'ETH',
                        style: TextStyle(fontSize: 13),
                      ),
                      SizedBox(width: 4),
                      Text(FormatUtil.formatCoinNum(addressData.ethBalance?.toDouble() ?? 0),
                          style: TextStyle(fontSize: 13)),
                    ],
                  ),
                if (addressData.type != AddressIndex.M_HYN)
                  Row(
                    children: <Widget>[
                      Text(
                        'USDT',
                        style: TextStyle(fontSize: 13),
                      ),
                      SizedBox(width: 4),
                      Text(FormatUtil.formatCoinNum(addressData.usdtBalance?.toDouble() ?? 0),
                          style: TextStyle(fontSize: 13)),
                    ],
                  ),
                Row(
                  children: <Widget>[
                    Text('HYN', style: TextStyle(fontSize: 13)),
                    SizedBox(width: 4),
                    Text(FormatUtil.formatCoinNum(addressData.hynBanlance?.toDouble() ?? 0),
                        style: TextStyle(fontSize: 13)),
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
                  int tokenType;
                  if (addressData.type == AddressIndex.M_HYN) {
                    tokenType = TokenType.HYN_MAIN;
                  } else {
                    tokenType = await selectTokenType(context);
                  }
                  if (![TokenType.ETH, TokenType.USDT_ERC20, TokenType.HYN_ERC20, TokenType.HYN_MAIN]
                      .contains(tokenType)) {
                    UiUtil.toast('提币类型错误');
                    return;
                  }

                  UiUtil.showDialogWidget(context,
                      title: Text('转账'),
                      content: buildTransferDialogView(addressData, tokenType),
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

                                if (password == null || password.isEmpty) {
                                  return;
                                }

                                // await WalletUtil.exportMnemonic(
                                //     fileName: wallet.keystore.fileName, password: password);
                                print('ok');
                                // var seed = bip39.mnemonicToSeed(mnemonic);
                                // var hdWallet = bitcoin.HDWallet.fromSeed(seed);
                                // var ethWallet = hdWallet.derivePath("${Config.M_Main_Path}$type");

                                var txhash = '';

                                if (tokenType == TokenType.ETH) {
                                  //需要转ETH
                                  try {
                                    final client = WalletUtil.getWeb3Client();
                                    final credentials =
                                        await client.credentialsFromPrivateKey(addressData.hdWallet.privKey);
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

                                    print('txhash $txhash');
                                    UiUtil.toast('转账 $_amount，请等待成功后再执行其他转账');
                                  } catch (e) {
                                    print(e);
                                    UiUtil.toast('ETH转账异常 ${e.message}');
                                  }
                                } else if (tokenType == TokenType.HYN_MAIN) {
                                  try {
                                    final client = WalletUtil.getWeb3Client(true);
                                    final credentials =
                                        await client.credentialsFromPrivateKey(addressData.hdWallet.privKey);
                                    txhash = await client.sendTransaction(
                                      credentials,
                                      web3.Transaction(
                                        to: web3.EthereumAddress.fromHex(WalletUtil.bech32ToEthAddress(_toAddress)),
                                        gasPrice: web3.EtherAmount.inWei(BigInt.one),
                                        maxGas: 21000,
                                        value: web3.EtherAmount.inWei(ConvertTokenUnit.decimalToWei(_amount)),
                                        type: web3.MessageType.typeNormal,
                                      ),
                                      fetchChainIdFromNetworkId: false,
                                    );

                                    print('txhash $txhash');
                                    UiUtil.toast('转账$_amount，请等待成功后再执行其他转账');
                                  } catch (e) {
                                    print(e);
                                    UiUtil.toast('HYN转账异常 ${e.message}');
                                  }
                                } else {
                                  //转ERC 20币
                                  try {
                                    final client = WalletUtil.getWeb3Client();
                                    final credentials =
                                        await client.credentialsFromPrivateKey(addressData.hdWallet.privKey);

                                    var contract;
                                    var decimals;
                                    if (tokenType == TokenType.USDT_ERC20) {
                                      contract = WalletUtil.getHynErc20Contract(WalletConfig.getUsdtErc20Address());
                                      decimals = SupportedTokens.USDT_ERC20.decimals;
                                    } else if (tokenType == TokenType.HYN_ERC20) {
                                      contract = WalletUtil.getHynErc20Contract(WalletConfig.getHynErc20Address());
                                      decimals = SupportedTokens.HYN_ERC20.decimals;
                                    } else {
                                      UiUtil.toast('错误的类型 $tokenType');
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

                                    print('txhash $txhash');
                                    UiUtil.toast('转账$_amount，请等待成功后再执行其他转账');
                                  } catch (e) {
                                    print(e);
                                    UiUtil.toast('转账异常, ${e.message}');
                                  }
                                }
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
                  var address = addressData.address;
                  if (addressData.type == AddressIndex.M_HYN) {
                    address = WalletUtil.ethAddressToBech32Address(addressData.address);
                  }
                  await Clipboard.setData(new ClipboardData(text: address));
                  UiUtil.toast('地址复制成功 $address');
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
    var address = addressData.address;
    if (addressData.type == AddressIndex.M_HYN) {
      address = WalletUtil.ethAddressToBech32Address(addressData.address);
    }

    var ret = [BigInt.zero, BigInt.zero, BigInt.zero];
    if (addressData.type != AddressIndex.M_HYN) {
      ret = await Future.wait([
        WalletUtil.getBalanceByCoinTypeAndAddress(CoinType.ETHEREUM, addressData.address),
        WalletUtil.getBalanceByCoinTypeAndAddress(
            CoinType.ETHEREUM, addressData.address, WalletConfig.getHynErc20Address()),
        WalletUtil.getBalanceByCoinTypeAndAddress(
            CoinType.ETHEREUM, addressData.address, WalletConfig.getUsdtErc20Address()),
      ]);
    } else {
      ret[0] = BigInt.zero;
      ret[1] = await WalletUtil.getBalanceByCoinTypeAndAddress(CoinType.HYN_ATLAS, addressData.address);
      ret[2] = BigInt.zero;
    }

    var ethBalance = ret[0];
    var hynBalance = ret[1];
    var usdtBalance = ret[2];

    addressData.ethBalance = ConvertTokenUnit.weiToDecimal(ethBalance);
    addressData.hynBanlance = ConvertTokenUnit.weiToDecimal(hynBalance);
    addressData.usdtBalance = ConvertTokenUnit.weiToDecimal(usdtBalance, SupportedTokens.USDT_ERC20.decimals);

    print("'mm-$address', '$ethBalance,$hynBalance,$usdtBalance'");
    await AppCache.saveValue('mm-$address', '$ethBalance,$hynBalance,$usdtBalance');
  }

  Future<AddressData> newAddressData(bitcoin.HDWallet hdWallet, String name, String address, int type) async {
    Decimal ethBalance;
    Decimal hynBalance;
    Decimal usdtBalance;
    if (type == AddressIndex.M_HYN) {
      address = WalletUtil.ethAddressToBech32Address(address);
    }
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
        hdWallet: hdWallet,
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
    // //mock test
    // var mmData = MMData(
    //   uid: '1',
    //   key: 'k1',
    //   hynBalance: Decimal.parse('1111'),
    //   usdtBalance: Decimal.parse('111'),
    // );
    // mmList.add(mmData);
    // return ;

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

  Decimal getBalanceByType(AddressData addressData, int tokenType) {
    var balance;
    switch (tokenType) {
      case TokenType.ETH:
        balance = addressData.ethBalance;
        break;
      case TokenType.HYN_ERC20:
        balance = addressData.hynBanlance;
        break;
      case TokenType.HYN_MAIN:
        balance = addressData.hynBanlance;
        break;
      case TokenType.USDT_ERC20:
        balance = addressData.usdtBalance;
        break;
    }
    return balance ?? Decimal.zero;
  }

  String getTypeName(int tokenType) {
    var name = '';
    switch (tokenType) {
      case TokenType.ETH:
        name = 'ETH';
        break;
      case TokenType.HYN_MAIN:
        name = 'HYN';
        break;
      case TokenType.HYN_ERC20:
        name = 'HYN';
        break;
      case TokenType.USDT_ERC20:
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
                  Navigator.pop(context, TokenType.HYN_ERC20);
                },
                child: Container(
                  child: Text('HYN'),
                  color: Colors.white,
                  padding: EdgeInsets.only(top: 16, bottom: 16, left: 32),
                )),
            InkWell(
                onTap: () {
                  Navigator.pop(context, TokenType.USDT_ERC20);
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
                    Navigator.pop(context, TokenType.ETH);
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
                if (![TokenType.ETH, TokenType.USDT_ERC20, TokenType.HYN_ERC20, TokenType.HYN_MAIN].contains(type)) {
                  UiUtil.toast('币类型错误');
                  return;
                }

                UiUtil.showDialogWidget(context,
                    title: Text('减少'),
                    content: buildMMOptAccountDialogView(
                        (type == TokenType.HYN_MAIN || type == TokenType.HYN_ERC20)
                            ? mmData.hynBalance
                            : mmData.usdtBalance,
                        false),
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

                              if (password == null || password.isEmpty) {
                                return;
                              }

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
                if (![TokenType.ETH, TokenType.USDT_ERC20, TokenType.HYN_ERC20, TokenType.HYN_MAIN].contains(type)) {
                  UiUtil.toast('币类型错误');
                  return;
                }

                UiUtil.showDialogWidget(context,
                    title: Text('增加'),
                    content: buildMMOptAccountDialogView(
                        (type == TokenType.HYN_MAIN || type == TokenType.HYN_ERC20)
                            ? mmData.hynBalance
                            : mmData.usdtBalance,
                        true),
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

                              if (password == null || password.isEmpty) {
                                return;
                              }

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
