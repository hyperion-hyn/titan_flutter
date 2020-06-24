import 'package:flutter/material.dart';
import 'package:flutter_bugly/flutter_bugly.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:titan/src/basic/utils/hex_color.dart';
import 'package:titan/src/basic/widget/load_data_container/bloc/bloc.dart';
import 'package:titan/src/components/quotes/quotes_component.dart';
import 'package:titan/src/components/setting/setting_component.dart';
import 'package:titan/src/components/wallet/bloc/bloc.dart';
import 'package:titan/src/components/wallet/vo/coin_vo.dart';
import 'package:titan/src/components/wallet/vo/wallet_vo.dart';
import 'package:titan/src/components/wallet/wallet_component.dart';
import 'package:titan/src/config/application.dart';
import 'package:titan/src/plugins/wallet/contract_const.dart';
import 'package:titan/src/plugins/wallet/convert.dart';
import 'package:titan/src/plugins/wallet/token.dart';
import 'package:titan/src/plugins/wallet/wallet_const.dart';
import 'package:titan/src/plugins/wallet/wallet_util.dart';
import 'package:titan/src/routes/fluro_convert_utils.dart';
import 'package:titan/src/routes/routes.dart';
import 'package:titan/src/style/titan_sytle.dart';
import 'package:titan/src/utils/format_util.dart';
import 'package:titan/src/utils/image_util.dart';
import 'package:titan/src/utils/utile_ui.dart';
import 'package:titan/src/widget/enter_wallet_password.dart';
import 'package:web3dart/web3dart.dart';

import '../../../../../env.dart';
import '../../../../global.dart';

class ShowWalletView extends StatelessWidget {
  final WalletVo walletVo;
  final LoadDataBloc loadDataBloc;

  ShowWalletView(this.walletVo, this.loadDataBloc);

  int _lastRequestCoinTime = 0;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 54, 16, 0),
//        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 44),
      child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Material(
                borderRadius: BorderRadius.circular(16),
                elevation: 10,
                child: Container(
                  padding: EdgeInsets.only(top: 16, bottom: 16, left: 24, right: 16),
                  child: Row(
                    children: <Widget>[
                      //balance
                      Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            "${QuotesInheritedModel.of(context, aspect: QuotesAspect.quote).activeQuotesSign?.quote ?? ''}",
                            style: TextStyle(color: Color(0xFF9B9B9B), fontSize: 16),
                          ),
                          SizedBox(
                            height: 8,
                          ),
                          Row(
                            children: <Widget>[
                              Text(
                                QuotesInheritedModel.of(context, aspect: QuotesAspect.quote).activeQuotesSign?.sign ??
                                    '',
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                              ),
                              SizedBox(
                                width: 8,
                              ),
                              Text(
                                "${FormatUtil.formatPrice(walletVo.balance)}",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 24, color: Theme.of(context).primaryColor),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Spacer(),
                      InkWell(
                        onTap: () {
                          Application.router.navigateTo(context, Routes.wallet_manager);
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Text(
                                "${UiUtil.shortString(walletVo.wallet.keystore.name, limitLength: 6)}",
                                style: TextStyle(color: Color(0xFF252525)),
                              ),
                              Icon(
                                Icons.chevron_right,
                                color: Color(0xFF9B9B9B),
                              )
                            ],
                          ),
                        ),
                      )
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
                return InkWell(
                    onTap: () {
                      var coinVo = walletVo.coins[index];
                      var coinVoJsonStr = FluroConvertUtils.object2string(coinVo.toJson());
                      Application.router.navigateTo(context, Routes.wallet_account_detail + '?coinVo=$coinVoJsonStr');
                    },
                    child: _buildAccountItem(context, walletVo.coins[index]));
              },
              itemCount: walletVo.coins.length,
            ),
            if(walletVo.wallet.getBitcoinAccount() == null)
              _bitcoinEmptyView(context),
            if (env.buildType == BuildType.DEV)
              _testWalletView(context),
          ]),
    );
  }

  Widget _bitcoinEmptyView(BuildContext context){
    /*FlatButton(
      onPressed: () {
        showModalBottomSheet(
            isScrollControlled: true,
            context: context,
            builder: (BuildContext context) {
              return EnterWalletPasswordWidget();
            }).then((walletPassword) async {
          if (walletPassword == null) {
            return;
          }

          await walletVo.wallet.bitcoinActive(walletPassword);
          BlocProvider.of<WalletCmpBloc>(context)
              .add(LoadLocalDiskWalletAndActiveEvent());
//                    Future.delayed(Duration(milliseconds: 1000),(){
//                      loadDataBloc.add(LoadingEvent());
//                    });
        });
      },
      child: Text("激活比特币"),
    ),*/
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
      onTap: (){
        showModalBottomSheet(
            isScrollControlled: true,
            context: context,
            builder: (BuildContext context) {
              return EnterWalletPasswordWidget();
            }).then((walletPassword) async {
          if (walletPassword == null) {
            return;
          }

          await walletVo.wallet.bitcoinActive(walletPassword);
          BlocProvider.of<WalletCmpBloc>(context)
              .add(LoadLocalDiskWalletAndActiveEvent());
          Future.delayed(Duration(milliseconds: 500),(){
            loadDataBloc.add(LoadingEvent());
          });
        });
      },
      child: Column(
        children: <Widget>[
          _buildAccountItem(context, coinVo),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
            Image.asset("res/drawable/ic_key_view.png",width: 16,height: 16,),
            Padding(
              padding: const EdgeInsets.only(left:10,right: 16),
              child: Text("激活BTC",style: TextStyle(fontSize: 14,color: HexColor("#1F81FF")),),
            )
          ],)
        ],
      ),
    );
  }

  Widget _testWalletView(BuildContext context) {
    return  Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: <Widget>[
          RaisedButton(
            child: Text('-测试申请0.05ETH'),
            onPressed: () async {
              var time = DateTime.now().millisecondsSinceEpoch;
              if(time - _lastRequestCoinTime < 60 * 1000) { //1分钟
                UiUtil.toast('-请等待1分钟以上再申请转账');
                return ;
              }
              var activeWallet = WalletInheritedModel.of(context).activatedWallet?.wallet;
              final client = WalletUtil.getWeb3Client();
              String privateKey = ContractTestConfig.privateKey;
              final credentials = await client.credentialsFromPrivateKey(privateKey);
              if (activeWallet != null) {
                var toAddress = activeWallet.getEthAccount().address;
                var amount = ConvertTokenUnit.etherToWei(etherDouble: 0.05);
                var txHash = await client.sendTransaction(
                  credentials,
                  Transaction(
                    to: EthereumAddress.fromHex(toAddress),
                    value: EtherAmount.inWei(amount),
                    gasPrice: EtherAmount.inWei(BigInt.from(EthereumConst.SUPER_FAST_SPEED)),
//                    maxGas: EthereumConst.ETH_TRANSFER_GAS_LIMIT,
                    maxGas: SettingInheritedModel.ofConfig(context).systemConfigEntity.ethTransferGasLimit,
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
              if(time - _lastRequestCoinTime < 60 * 1000) { //1分钟
                UiUtil.toast('-请等待1分钟以上再申请转账');
                return ;
              }
              var activeWallet = WalletInheritedModel.of(context).activatedWallet?.wallet;
              final client = WalletUtil.getWeb3Client();
              String privateKey = ContractTestConfig.privateKey;
              final credentials = await client.credentialsFromPrivateKey(privateKey);
              if (activeWallet != null) {
                var toAddress = activeWallet.getEthAccount().address;

                var hynErc20Contract = WalletUtil.getHynErc20Contract(ContractTestConfig.hynContractAddress);
                var hynAmount = ConvertTokenUnit.etherToWei(etherDouble: 600000); //二十万
                var txHash = await client.sendTransaction(
                  credentials,
                  Transaction.callContract(
                    contract: hynErc20Contract,
                    function: hynErc20Contract.function('transfer'),
                    parameters: [EthereumAddress.fromHex(toAddress), hynAmount],
                    gasPrice: EtherAmount.inWei(BigInt.from(EthereumConst.SUPER_FAST_SPEED)),
                    maxGas: SettingInheritedModel.ofConfig(context).systemConfigEntity.erc20TransferGasLimit,
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
              if(time - _lastRequestCoinTime < 60 * 1000) { //1分钟
                UiUtil.toast('-请等待1分钟以上再申请转账');
                return ;
              }
              var activeWallet = WalletInheritedModel.of(context).activatedWallet?.wallet;
              final client = WalletUtil.getWeb3Client();
              String privateKey = ContractTestConfig.privateKey;
              final credentials = await client.credentialsFromPrivateKey(privateKey);
              if (activeWallet != null) {
                var toAddress = activeWallet.getEthAccount().address;

                var erc20Contract = WalletUtil.getHynErc20Contract(ContractTestConfig.usdtContractAddress);
                var amount = ConvertTokenUnit.numToWei(100, SupportedTokens.USDT_ERC20_ROPSTEN.decimals);
                var txHash = await client.sendTransaction(
                  credentials,
                  Transaction.callContract(
                    contract: erc20Contract,
                    function: erc20Contract.function('transfer'),
                    parameters: [EthereumAddress.fromHex(toAddress), amount],
                    gasPrice: EtherAmount.inWei(BigInt.from(EthereumConst.SUPER_FAST_SPEED)),
                    maxGas: SettingInheritedModel.ofConfig(context).systemConfigEntity.erc20TransferGasLimit,
                  ),
                  fetchChainIdFromNetworkId: true,
                );
                logger.i('has is $txHash');

                _lastRequestCoinTime = DateTime.now().millisecondsSinceEpoch;
                UiUtil.toast('-申请USDT成功, 请等待2-5分钟');
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAccountItem(BuildContext context, CoinVo coin) {
    var symbolQuote = QuotesInheritedModel.of(context).activatedQuoteVoAndSign(coin.symbol);
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: <Widget>[
          Container(
            alignment: Alignment.center,
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              border: Border.all(color: Color(0xFF9B9B9B), width: 0),
              shape: BoxShape.circle,
            ),
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
                Text(
                  coin.symbol,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF252525)),
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
                        "${symbolQuote?.sign?.sign ?? ''} ${FormatUtil.formatPrice(symbolQuote?.quoteVo?.price ?? 0.0)}",
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
                    "${FormatUtil.coinBalanceHumanReadFormat(coin)}",textAlign: TextAlign.right,
                    style: TextStyle(color: Color(0xFF252525), fontSize: 16),overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(
                    height: 4,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Text(
                      "${symbolQuote?.sign?.sign ?? ''} ${FormatUtil.formatPrice(FormatUtil.coinBalanceDouble(coin) * (symbolQuote?.quoteVo?.price ?? 0))}",
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
}
