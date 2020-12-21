import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:local_auth/local_auth.dart';
import 'package:titan/generated/l10n.dart';
import 'package:titan/src/basic/utils/hex_color.dart';
import 'package:titan/src/basic/widget/base_state.dart';
import 'package:titan/src/basic/widget/load_data_container/bloc/bloc.dart';
import 'package:titan/src/components/exchange/bloc/bloc.dart';
import 'package:titan/src/data/cache/app_cache.dart';
import 'package:titan/src/pages/atlas_map/api/atlas_api.dart';
import 'package:titan/src/pages/atlas_map/atlas/burn_history_page.dart';
import 'package:titan/src/pages/atlas_map/widget/hyn_burn_banner.dart';
import 'package:titan/src/pages/bio_auth/bio_auth_page.dart';
import 'package:titan/src/components/auth/auth_component.dart';
import 'package:titan/src/components/auth/bloc/auth_bloc.dart';
import 'package:titan/src/components/auth/bloc/auth_event.dart';
import 'package:titan/src/components/auth/bloc/auth_state.dart';
import 'package:titan/src/components/auth/model.dart';
import 'package:titan/src/components/wallet/wallet_component.dart';
import 'package:titan/src/components/setting/setting_component.dart';
import 'package:titan/src/components/socket/bloc/bloc.dart';
import 'package:titan/src/components/socket/socket_config.dart';
import 'package:titan/src/components/wallet/bloc/bloc.dart';
import 'package:titan/src/components/wallet/vo/coin_vo.dart';
import 'package:titan/src/components/wallet/vo/wallet_vo.dart';
import 'package:titan/src/components/wallet/wallet_component.dart';
import 'package:titan/src/config/application.dart';
import 'package:titan/src/pages/mine/about_me_page.dart';
import 'package:titan/src/pages/wallet/api/hyn_api.dart';
import 'package:titan/src/pages/wallet_demo/ApiDemo.dart';
import 'package:titan/src/plugins/wallet/account.dart';
import 'package:titan/src/plugins/wallet/cointype.dart';
import 'package:titan/src/pages/atlas_map/atlas/atlas_detail_page.dart';
import 'package:titan/src/pages/atlas_map/atlas/atlas_look_over_page.dart';
import 'package:titan/src/pages/atlas_map/atlas/atlas_stake_list_page.dart';
import 'package:titan/src/pages/atlas_map/atlas/atlas_stake_select_page.dart';
import 'package:titan/src/pages/node/model/enum_state.dart';
import 'package:titan/src/plugins/wallet/contract_const.dart';
import 'package:titan/src/plugins/wallet/convert.dart';
import 'package:titan/src/plugins/wallet/token.dart';
import 'package:titan/src/plugins/wallet/wallet.dart';
import 'package:titan/src/plugins/wallet/wallet_const.dart';
import 'package:titan/src/plugins/wallet/wallet_util.dart';
import 'package:titan/src/routes/fluro_convert_utils.dart';
import 'package:titan/src/routes/routes.dart';
import 'package:titan/src/style/titan_sytle.dart';
import 'package:titan/src/utils/auth_util.dart';
import 'package:titan/src/utils/format_util.dart';
import 'package:titan/src/utils/image_util.dart';
import 'package:titan/src/utils/log_util.dart';
import 'package:titan/src/utils/utile_ui.dart';
import 'package:titan/src/utils/utils.dart';
import 'package:titan/src/widget/auth_dialog/SetBioAuthDialog.dart';
import 'package:titan/src/widget/auth_dialog/bio_auth_dialog.dart';
import 'package:titan/src/widget/enter_wallet_password.dart';
import 'package:vibration/vibration.dart';
import 'package:web3dart/web3dart.dart';
import 'package:titan/src/plugins/wallet/wallet.dart' as plugWallet;

import '../../../../../config.dart';
import '../../../../../env.dart';
import '../../../../global.dart';

class ShowWalletView extends StatefulWidget {
  final WalletVo walletVo;
  final LoadDataBloc loadDataBloc;

  ShowWalletView(this.walletVo, this.loadDataBloc);

  @override
  State<StatefulWidget> createState() {
    return _ShowWalletViewState();
  }
}

class _ShowWalletViewState extends BaseState<ShowWalletView> {
  int _lastRequestCoinTime = 0;
  bool _isShowBalances = true;
  bool _isRefreshBalances = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    widget.loadDataBloc.close();
    super.dispose();
  }

  @override
  void onCreated() {
    BlocProvider.of<WalletCmpBloc>(context).listen((state) {
      if (state is UpdateWalletPageState && (state.updateStatus == 0 || state.updateStatus == -1)) {
        _isRefreshBalances = false;
      }
    });
    super.onCreated();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Material(
                color: Theme.of(context).primaryColor,
                borderRadius: BorderRadius.circular(16),
                elevation: 10,
                child: Container(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            InkWell(
                              onTap: () async {
                                plugWallet.Wallet wallet = await Application.router.navigateTo(
                                  context,
                                  Routes.wallet_manager,
                                );
                                if(wallet != null) {
                                  setState(() {
                                    _isRefreshBalances = true;
                                  });
                                  BlocProvider.of<WalletCmpBloc>(context)
                                      .add(ActiveWalletEvent(wallet: wallet));
                                  await Future.delayed(Duration(milliseconds: 300));
                                  BlocProvider.of<WalletCmpBloc>(context).add(UpdateWalletPageEvent());

                                  ///Clear exchange account when switch wallet
                                  BlocProvider.of<ExchangeCmpBloc>(context)
                                      .add(ClearExchangeAccountEvent());
                                }
                              },
                              child: Row(
                                children: <Widget>[
                                  Text(
                                    "${UiUtil.shortString(
                                      widget.walletVo.wallet.keystore.name,
                                      limitLength: 6,
                                    )}",
                                    style: TextStyle(
                                      color: Colors.white,
                                    ),
                                  ),
                                  Icon(
                                    Icons.chevron_right,
                                    color: Colors.white,
                                  ),
                                ],
                              ),
                            ),
                            Spacer(),
                            InkWell(
                              onTap: () async {
                                setState(() {
                                  _isShowBalances = !_isShowBalances;
                                });
                              },
                              child: _isShowBalances
                                  ? Image.asset(
                                      'res/drawable/ic_wallet_show_balances.png',
                                      height: 20,
                                      width: 20,
                                    )
                                  : Image.asset(
                                      'res/drawable/ic_wallet_hide_balances.png',
                                      height: 20,
                                      width: 20,
                                    ),
                            )
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 8.0,
                      ),
                      Row(
                        children: <Widget>[
                          Text(
                            WalletInheritedModel.of(context,
                                        aspect: WalletAspect.quote)
                                    .activeQuotesSign
                                    ?.sign ??
                                '',
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 20,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(
                            width: 8,
                          ),
                          Text(
                            _isShowBalances
                                ? '${FormatUtil.formatPrice(widget.walletVo.balance)}'
                                : '*****',
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 24,
                              color: Colors.white,
                            ),
                          ),
                          Spacer(),
                          if(_isRefreshBalances)
                            SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                backgroundColor: Colors.white,
                                valueColor: new AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor),
                                strokeWidth: 3,
                              ),
                            )
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 16,
            ),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemBuilder: (BuildContext context, int index) {
                var coinVo = widget.walletVo.coins[index];
                var hasPrice = true;
                // if(coinVo.symbol == SupportedTokens.HYN_RP_HRC30_ROPSTEN.symbol){
                //   hasPrice = false;
                // }
                return InkWell(
                    onTap: () {
                      var coinVo = widget.walletVo.coins[index];
                      var coinVoJsonStr =
                          FluroConvertUtils.object2string(coinVo.toJson());
                      Application.router.navigateTo(
                          context,
                          Routes.wallet_account_detail +
                              '?coinVo=$coinVoJsonStr');
                    },
                    child: _buildAccountItem(context, coinVo, hasPrice: hasPrice));
              },
              itemCount: widget.walletVo.coins.length,
            ),
            if (widget.walletVo.wallet.getBitcoinAccount() == null)
              _bitcoinEmptyView(context),
//            _exchangeHYNView(context),
//            if (env.buildType == BuildType.DEV) _testWalletView(context),
            /*Wrap(
              children: [
                Text(
                  S.of(context).atlas_mapping_completed,
                  style: TextStyle(fontSize: 12, color: DefaultColors.color999),
                ),
                SizedBox(
                  width: 4,
                ),
                InkWell(
                  onTap: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => AboutMePage()));
                  },
                  child: Text(
                    S.of(context).contact_us,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.blue,
                    ),
                  ),
                ),
              ],
            ),*/
            SizedBox(
              height: 16,
            ),
            HynBurnBanner(),
//            if (env.buildType == BuildType.DEV) _ropstenTestWalletView(context),
          ]),
    );
  }

  Widget _exchangeHYNView(BuildContext context, CoinVo coin) {
    return Column(
      children: <Widget>[
        _buildAccountItem(context, coin),
        InkWell(
          onTap: () {
            AtlasApi.goToAtlasMap3HelpPage(context);
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(left: 10, right: 6),
                child: Text(
                  S.of(context).exchange_main_block_hyn,
                  style: TextStyle(fontSize: 14, color: HexColor("#1F81FF")),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 14),
                child: Image.asset(
                  "res/drawable/ic_question_remind.png",
                  width: 16,
                  height: 16,
                ),
              ),
            ],
          ),
        )
      ],
    );
  }

  Widget _exchangeHYNViewOld(BuildContext context, CoinVo coin) {
    return InkWell(
      onTap: () {
        AtlasApi.goToAtlasMap3HelpPage(context);
      },
      child: Column(
        children: <Widget>[
          _buildAccountItem(context, coin),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(left: 10, right: 6),
                child: Text(
                  S.of(context).exchange_main_block_hyn,
                  style: TextStyle(fontSize: 14, color: HexColor("#1F81FF")),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 14),
                child: Image.asset(
                  "res/drawable/ic_question_remind.png",
                  width: 16,
                  height: 16,
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _bitcoinEmptyView(BuildContext context) {
    var coinVo = CoinVo(
      name: "BITCOIN",
      symbol: "BTC",
      coinType: 0,
      address: "",
      decimals: 8,
      logo: "res/drawable/ic_btc_logo_empty.png",
      contractAddress: null,
      extendedPublicKey: "",
      balance: BigInt.from(0),
    );
    return InkWell(
      onTap: () async {
        var walletPassword = await UiUtil.showWalletPasswordDialogV2(
          context,
          widget.walletVo.wallet,
        );

        if (walletPassword == null) {
          return;
        }
        try {
          await widget.walletVo.wallet.bitcoinActive(walletPassword);
          BlocProvider.of<WalletCmpBloc>(context)
              .add(LoadLocalDiskWalletAndActiveEvent());
          Future.delayed(Duration(milliseconds: 500), () {
            widget.loadDataBloc.add(LoadingEvent());
          });
        } catch (error) {
          LogUtil.toastException(error);
        }
      },
      child: Column(
        children: <Widget>[
          _buildAccountItem(context, coinVo),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              Image.asset(
                "res/drawable/ic_key_view.png",
                width: 16,
                height: 16,
              ),
              Padding(
                padding: const EdgeInsets.only(left: 10, right: 16),
                child: Text(
                  S.of(context).activate_btc,
                  style: TextStyle(fontSize: 14, color: HexColor("#1F81FF")),
                ),
              )
            ],
          )
        ],
      ),
    );
  }

  Widget _testWalletView(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: <Widget>[
          RaisedButton(
            child: Text('atlas detail'),
            onPressed: () async {
              Application.router.navigateTo(context, Routes.atlas_detail_page);
            },
          ),
          RaisedButton(
            child: Text('-测试申请0.05ETH'),
            onPressed: () async {
              var time = DateTime.now().millisecondsSinceEpoch;
              if (time - _lastRequestCoinTime < 60 * 1000) {
                //1分钟
                UiUtil.toast('-请等待1分钟以上再申请转账');
                return;
              }
              var activeWallet =
                  WalletInheritedModel.of(context).activatedWallet?.wallet;
              final client = WalletUtil.getWeb3Client();
              String privateKey = ContractTestConfig.privateKey;
              final credentials =
                  await client.credentialsFromPrivateKey(privateKey);
              if (activeWallet != null) {
                var toAddress = activeWallet.getEthAccount().address;
                var amount = ConvertTokenUnit.etherToWei(etherDouble: 0.05);
                var txHash = await client.sendTransaction(
                  credentials,
                  Transaction(
                    to: EthereumAddress.fromHex(toAddress),
                    value: EtherAmount.inWei(amount),
                    gasPrice: EtherAmount.inWei(
                        BigInt.from(EthereumConst.SUPER_FAST_SPEED)),
//                    maxGas: EthereumConst.ETH_TRANSFER_GAS_LIMIT,
                    maxGas: SettingInheritedModel.ofConfig(context)
                        .systemConfigEntity
                        .ethTransferGasLimit,
                  ),
                  fetchChainIdFromNetworkId: true,
                );
                _lastRequestCoinTime = DateTime.now().millisecondsSinceEpoch;
                logger.i('has is $txHash');
                UiUtil.toast('-申请ETH成功,请等待2-5分钟');
              }
            },
          ),
          RaisedButton(
            child: Text('-测试申请20万HYN'),
            onPressed: () async {
              var time = DateTime.now().millisecondsSinceEpoch;
              if (time - _lastRequestCoinTime < 60 * 1000) {
                //1分钟
                UiUtil.toast('-请等待1分钟以上再申请转账');
                return;
              }
              var activeWallet =
                  WalletInheritedModel.of(context).activatedWallet?.wallet;
              final client = WalletUtil.getWeb3Client();
              String privateKey = ContractTestConfig.privateKey;
              final credentials =
                  await client.credentialsFromPrivateKey(privateKey);
              if (activeWallet != null) {
                var toAddress = activeWallet.getEthAccount().address;

                var hynErc20Contract = WalletUtil.getHynErc20Contract(
                    ContractTestConfig.hynContractAddress);
                var hynAmount =
                    ConvertTokenUnit.etherToWei(etherDouble: 600000); //二十万
                var txHash = await client.sendTransaction(
                  credentials,
                  Transaction.callContract(
                    contract: hynErc20Contract,
                    function: hynErc20Contract.function('transfer'),
                    parameters: [EthereumAddress.fromHex(toAddress), hynAmount],
                    gasPrice: EtherAmount.inWei(
                        BigInt.from(EthereumConst.SUPER_FAST_SPEED)),
                    maxGas: SettingInheritedModel.ofConfig(context)
                        .systemConfigEntity
                        .erc20TransferGasLimit,
                  ),
                  fetchChainIdFromNetworkId: true,
                );
                logger.i('has is $txHash');

                _lastRequestCoinTime = DateTime.now().millisecondsSinceEpoch;
                UiUtil.toast('-申请HYN成功, 请等待2-5分钟');
              }
            },
          ),
          RaisedButton(
            child: Text('-测试申请100USDT'),
            onPressed: () async {
              var time = DateTime.now().millisecondsSinceEpoch;
              if (time - _lastRequestCoinTime < 60 * 1000) {
                //1分钟
                UiUtil.toast('-请等待1分钟以上再申请转账');
                return;
              }
              var activeWallet =
                  WalletInheritedModel.of(context).activatedWallet?.wallet;
              final client = WalletUtil.getWeb3Client();
              String privateKey = ContractTestConfig.privateKey;
              final credentials =
                  await client.credentialsFromPrivateKey(privateKey);
              if (activeWallet != null) {
                var toAddress = activeWallet.getEthAccount().address;

                var erc20Contract = WalletUtil.getHynErc20Contract(
                    ContractTestConfig.usdtContractAddress);
                var amount = ConvertTokenUnit.numToWei(
                    100, SupportedTokens.USDT_ERC20_ROPSTEN.decimals);
                var txHash = await client.sendTransaction(
                  credentials,
                  Transaction.callContract(
                    contract: erc20Contract,
                    function: erc20Contract.function('transfer'),
                    parameters: [EthereumAddress.fromHex(toAddress), amount],
                    gasPrice: EtherAmount.inWei(
                        BigInt.from(EthereumConst.SUPER_FAST_SPEED)),
                    maxGas: SettingInheritedModel.ofConfig(context)
                        .systemConfigEntity
                        .erc20TransferGasLimit,
                  ),
                  fetchChainIdFromNetworkId: true,
                );
                logger.i('has is $txHash');

                _lastRequestCoinTime = DateTime.now().millisecondsSinceEpoch;
                UiUtil.toast('-申请USDT成功, 请等待2-5分钟');
              }
            },
          ),
          RaisedButton(
            child: Text('API测试'),
            onPressed: () async {
              Navigator.push(
                  context, MaterialPageRoute(builder: (context) => ApiDemo()));
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAccountItem(BuildContext context, CoinVo coin, {bool hasPrice = true}) {
    var symbol = coin.symbol;
    var symbolQuote =
        WalletInheritedModel.of(context).activatedQuoteVoAndSign(symbol);
    var subSymbol = "";

    if (coin.coinType == CoinType.HYN_ATLAS) {
      subSymbol = '';
    } else if (coin.coinType == CoinType.ETHEREUM) {
      var symbolComponents = symbol.split(" ");
      if (symbolComponents.length == 2) {
        symbol = symbolComponents.first;
        subSymbol = symbolComponents.last.toLowerCase();
      }
    }

    var quotePrice;
    var balancePrice;
    if(!hasPrice){
      quotePrice = S.of(context).exchange_soon;
      balancePrice = "";
    }else{
      quotePrice = "${symbolQuote?.sign?.sign ?? ''} ${FormatUtil.formatPrice(symbolQuote?.quoteVo?.price ?? 0.0)}";
      balancePrice = _isShowBalances
          ? "${symbolQuote?.sign?.sign ?? ''} ${FormatUtil.formatPrice(FormatUtil.coinBalanceDouble(coin) * (symbolQuote?.quoteVo?.price ?? 0))}"
          : '${symbolQuote?.sign?.sign ?? ''} *****';
    }

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: <Widget>[
          Container(
            alignment: Alignment.center,
            width: 48,
            height: 48,
            child: ImageUtil.getCoinImage(coin.logo),
          ),
          SizedBox(
            width: 12,
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      symbol,
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF252525)),
                    ),
                    SizedBox(
                      width: 4,
                    ),
                    Text(
                      subSymbol,
                      style: TextStyle(fontSize: 12),
                    ),
                  ],
                ),
                SizedBox(
                  height: 4,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Text(
                        quotePrice,
                        style: TextStyles.textC9b9b9bS12,
                      ),
                    ),
                    if (symbolQuote?.quoteVo?.percentChange24h != null)
                      getPercentChange(symbolQuote?.quoteVo?.percentChange24h)
                  ],
                )
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  Text(
                    _isShowBalances
                        ? "${FormatUtil.coinBalanceHumanReadFormat(coin)}"
                        : '*****',
                    textAlign: TextAlign.right,
                    style: TextStyle(color: Color(0xFF252525), fontSize: 16),
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(
                    height: 4,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Text(balancePrice,
                      style: TextStyles.textC9b9b9bS12,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget getPercentChange(double percentChange) {
    if (percentChange > 0) {
      return Padding(
        padding: const EdgeInsets.only(left: 6),
        child: Text(
          "+${FormatUtil.formatPercentChange(percentChange)}",
          style: TextStyles.textC00ec00S12,
        ),
      );
    } else {
      return Padding(
        padding: const EdgeInsets.only(left: 6),
        child: Text(
          "${FormatUtil.formatPercentChange(percentChange)}",
          style: TextStyles.textCff2d2dS12,
        ),
      );
    }
  }

  _showPasswordBottomSheet() async {
    var walletPassword = await UiUtil.showWalletPasswordDialogV2(
      context,
      widget.walletVo.wallet,
    );
    if (walletPassword == null) {
      return;
    }
//    await UiUtil.showSetBioAuthDialog(
//      context,
//      '提交成功',
//      widget.walletVo.wallet,
//      walletPassword,
//    );

    Fluttertoast.showToast(msg: walletPassword);
  }

  _ropstenTestWalletView(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: <Widget>[
          // Text('Ropsten环境测试'),
          RaisedButton(
            child: Text('-测试申请55万主链HYN'),
            onPressed: () async {
              var activeWallet =
                  WalletInheritedModel.of(context).activatedWallet?.wallet;
              final client = WalletUtil.getWeb3Client(true);
              String privateKey = Config.TEST_WALLET_PRIVATE_KEY;
              final credentials =
                  await client.credentialsFromPrivateKey(privateKey);
              if (activeWallet != null) {
                var toAddress = activeWallet.getAtlasAccount().address;
                var amount = ConvertTokenUnit.etherToWei(etherDouble: 550000);
                var txHash = await client.sendTransaction(
                  credentials,
                  Transaction(
                    to: EthereumAddress.fromHex(toAddress),
                    value: EtherAmount.inWei(amount),
                    gasPrice: EtherAmount.inWei(
                        BigInt.one * BigInt.from(TokenUnit.G_WEI)),
//                    maxGas: EthereumConst.ETH_TRANSFER_GAS_LIMIT,
                    maxGas: 21000,
                    type: MessageType.typeNormal,
                  ),
                );
                logger.i('has is $txHash');
                UiUtil.toast('-申请HYN成功,请等待6秒');
              }
            },
          ),
          RaisedButton(
            child: Text('-一键回收主链HYN'),
            onPressed: () async {
              var activeWallet =
                  WalletInheritedModel.of(context).activatedWallet;
              if (activeWallet != null) {
                var balance = await activeWallet.wallet
                    .getBalance(activeWallet.wallet.getAtlasAccount());
                if (balance <= BigInt.from(5 * TokenUnit.ETHER)) {
                  return;
                }
                balance = balance - BigInt.from(5 * TokenUnit.ETHER);
                var password = await UiUtil.showWalletPasswordDialogV2(
                    context, activeWallet.wallet);
                if (password == null) {
                  return;
                }
                var txHash = await HYNApi.sendTransferHYN(
                  password,
                  activeWallet.wallet,
                  toAddress: "0x5c24A14B797A01BCc8eD74092c31794dDD80FB44",
                  amount: balance,
                );
                logger.i('has is $txHash');
                UiUtil.toast('-回收HYN成功,请等待6秒');
              }
            },
          ),
        ],
      ),
    );
  }
}
