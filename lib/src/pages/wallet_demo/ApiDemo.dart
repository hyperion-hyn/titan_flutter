import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:titan/src/basic/http/signer.dart';
import 'package:titan/src/components/exchange/bloc/bloc.dart';
import 'package:titan/src/components/setting/setting_component.dart';
import 'package:titan/src/components/wallet/wallet_component.dart';
import 'package:titan/src/config/consts.dart';
import 'package:titan/src/data/cache/app_cache.dart';
import 'package:titan/src/global.dart';
import 'package:titan/src/pages/market/api/exchange_api.dart';
import 'package:titan/src/pages/market/api/exchange_const.dart';
import 'package:titan/src/pages/node/api/node_api.dart';
import 'package:titan/src/pages/wallet_demo/recaptcha_test_page.dart';
import 'package:titan/src/plugins/wallet/contract_const.dart';
import 'package:titan/src/plugins/wallet/convert.dart';
import 'package:titan/src/plugins/wallet/token.dart';
import 'package:titan/src/plugins/wallet/wallet_const.dart';
import 'package:titan/src/plugins/wallet/wallet_util.dart';
import 'package:titan/src/utils/utile_ui.dart';
import 'package:web3dart/web3dart.dart';

class ApiDemo extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _ApiDemoState();
  }
}

class _ApiDemoState extends State {
  ExchangeApi _exchangeApi = ExchangeApi();
  int _lastRequestCoinTime = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('api测试'),
      ),
      body: ListView(
        shrinkWrap: true,
        padding: EdgeInsets.all(16),
        children: <Widget>[
          RaisedButton(
            onPressed: () async {
              var verifyCode = await Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => RecaptchaTestPage(
                            language: 'zh-CN',
                            apiKey: '6LeIXagZAAAAAKXVvQRHPTvmO4XLoxoeBtOjE5xH',
                          )));
              if (verifyCode != null) {
                UiUtil.toast('获得google人机验证码 $verifyCode');
              }
            },
            child: Text('人机验证'),
          ),
          RaisedButton(
            onPressed: () async {
              var wallet = WalletInheritedModel.of(context).activatedWallet;
              if (wallet != null) {
                var address = wallet.wallet.getEthAccount().address;
                var walletPassword = '111111';

                var email = 'moyaying@163.com';
                //1、 获取验证码， 并返回一个token
                dynamic ret = await _exchangeApi.sendSms(email: email);
                print(ret);
              }
            },
            child: Text('获取注册邮件验证码'),
          ),
          RaisedButton(
            onPressed: () async {
              var wallet = WalletInheritedModel.of(context).activatedWallet;
              if (wallet != null) {
                var address = wallet.wallet.getEthAccount().address;
                var walletPassword = await UiUtil.showWalletPasswordDialogV2(
                    context, wallet.wallet);

                var ret = await _exchangeApi.walletLogin(
                  wallet: wallet.wallet,
                  password: walletPassword,
                  address: address,
                );

                print(ret);
              }
            },
            child: Text('使用钱包注册账户'),
          ),
          RaisedButton(
            onPressed: () async {
              var ret = await _exchangeApi.getAssetsList();
              print(ret);
            },
            child: Text('查看用户资产'),
          ),
          RaisedButton(
            onPressed: () async {
              var ret = await _exchangeApi.testRecharge('HYN', 10000);
              print(ret);
              BlocProvider.of<ExchangeCmpBloc>(context)
                  .add(UpdateAssetsEvent());
            },
            child: Text('充10000HYN'),
          ),
          RaisedButton(
            onPressed: () async {
              var ret = await _exchangeApi.testRecharge('USDT', 1000);
              print(ret);
              BlocProvider.of<ExchangeCmpBloc>(context)
                  .add(UpdateAssetsEvent());
            },
            child: Text('充1000USDT'),
          ),
          RaisedButton(
            onPressed: () async {
              var ret = await _exchangeApi.testRecharge('ETH', 1000);
              print(ret);
              BlocProvider.of<ExchangeCmpBloc>(context)
                  .add(UpdateAssetsEvent());
            },
            child: Text('充1000ETH'),
          ),
          RaisedButton(
            onPressed: () async {
              BlocProvider.of<ExchangeCmpBloc>(context)
                  .add(ClearExchangeAccountEvent());
            },
            child: Text('清除当前交易账户'),
          ),
          RaisedButton(
            onPressed: () async {
              var wallet = WalletInheritedModel.of(context).activatedWallet;
              if (wallet != null) {
                AppCache.remove(
                  'exchange_auth_already_${wallet.wallet.getEthAccount().address}',
                );
              }
            },
            child: Text('清除当前交易账户登录记录'),
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
            child: Text('-测试申请60万HYN'),
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
            child: Text('Map3 providers'),
            onPressed: () async {
              NodeApi _nodeApi = NodeApi();
              List list = await _nodeApi.getNodeProviderList();
              print(' Map3 providers ${list.length}');
            },
          )
        ],
      ),
    );
  }
}

