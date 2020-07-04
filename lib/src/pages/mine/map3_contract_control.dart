import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:titan/src/basic/widget/base_state.dart';
import 'package:titan/src/components/auth/auth_component.dart';
import 'package:titan/src/components/quotes/quotes_component.dart';
import 'package:titan/src/components/setting/setting_component.dart';
import 'package:titan/src/components/wallet/wallet_component.dart';
import 'package:titan/src/global.dart';
import 'package:titan/src/plugins/wallet/convert.dart';
import 'package:titan/src/plugins/wallet/wallet_const.dart';
import 'package:titan/src/plugins/wallet/wallet_util.dart';
import 'package:titan/src/utils/format_util.dart';
import 'package:titan/src/utils/utile_ui.dart';
import 'package:titan/src/widget/enter_wallet_password.dart';
import 'package:web3dart/web3dart.dart';

class Map3ContractControlPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return Map3ContractControlPageState();
  }
}

class Map3ContractControlPageState extends BaseState<Map3ContractControlPage> {
  bool _isLoading = false;
  bool _isCommitting = false;

  Decimal rewardAmount = Decimal.fromInt(0);
  Decimal maxTotalDelegation = Decimal.fromInt(0);
  Decimal annualized30 = Decimal.fromInt(0);
  Decimal annualized90 = Decimal.fromInt(0);
  Decimal annualized180 = Decimal.fromInt(0);

  String annualizedToCommit = '';
  String maxDelegationValue = '';
  String withdrawValue = '';
  String depositValue = '';

  GlobalKey<FormState> _formKey30 = GlobalKey<FormState>(debugLabel: '30天年化');
  GlobalKey<FormState> _formKey90 = GlobalKey<FormState>(debugLabel: '90天年化');
  GlobalKey<FormState> _formKey180 = GlobalKey<FormState>(debugLabel: '90天年化');
  GlobalKey<FormState> _formKeyMaxTotalDelegation =
      GlobalKey<FormState>(debugLabel: '最大抵押量');
  GlobalKey<FormState> _formKeyWithdrawProvision =
      GlobalKey<FormState>(debugLabel: '取回');
  GlobalKey<FormState> _formKeyDepositProvision =
      GlobalKey<FormState>(debugLabel: '存入');

  var textEditorController = TextEditingController();

  var wallet;

  @override
  void didChangeDependencies() {
    wallet = WalletInheritedModel.of(context).activatedWallet?.wallet;
    super.didChangeDependencies();
  }

  @override
  void onCreated() {
    _loadData();
  }

  void _loadData() async {
    if (wallet != null) {
      setState(() {
        _isLoading = true;
      });

      var contract =
          WalletUtil.getMap3Contract(WalletConfig.map3ContractAddress);
      var provisionFun = contract.function('provision');
      var maxTotalDelegationFun = contract.function('maxTotalDelegation');
      var getAnnualizedYieldFun = contract.function('getAnnualizedYield');
      var rets = await Future.wait([
        WalletUtil.getWeb3Client()
            .call(contract: contract, function: provisionFun, params: []),
        WalletUtil.getWeb3Client().call(
            contract: contract, function: maxTotalDelegationFun, params: []),
        WalletUtil.getWeb3Client().call(
            contract: contract,
            function: getAnnualizedYieldFun,
            params: [BigInt.from(0)]),
        WalletUtil.getWeb3Client().call(
            contract: contract,
            function: getAnnualizedYieldFun,
            params: [BigInt.from(1)]),
        WalletUtil.getWeb3Client().call(
            contract: contract,
            function: getAnnualizedYieldFun,
            params: [BigInt.from(2)]),
      ]);
      rewardAmount = ConvertTokenUnit.weiToDecimal(rets[0].first);
      maxTotalDelegation = ConvertTokenUnit.weiToDecimal(rets[1].first);
      annualized30 = ConvertTokenUnit.weiToDecimal(rets[2].first, 2);
      annualized90 = ConvertTokenUnit.weiToDecimal(rets[3].first, 2);
      annualized180 = ConvertTokenUnit.weiToDecimal(rets[4].first, 2);

      setState(() {
        _isLoading = false;
      });
    } else {
      UiUtil.toast('-请先导入钱包');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Row(
        children: <Widget>[
          Text('map3合约管理'),
          if (_isCommitting)
            Container(
              margin: EdgeInsets.only(left: 16),
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                valueColor: new AlwaysStoppedAnimation<Color>(Colors.white),
                strokeWidth: 2,
              ),
            )
        ],
      )),
      backgroundColor: Theme.of(context).backgroundColor,
      body: Builder(
        builder: (context) {
          return SingleChildScrollView(
            child: Column(
              children: <Widget>[
                _buildItem(
                    '奖励池剩: ${FormatUtil.formatCoinNum(rewardAmount.toDouble())} hyn',
                    [
                      _buildButton('取回', () {
                        textEditorController.text = '';
                        UiUtil.showDialogWidget(context,
                            title: Text('从奖励池取回hyn'),
                            content: _buildWithdrawProvisionForm(
                                context, rewardAmount),
                            actions: [
                              FlatButton(
                                  child: Text('提交'),
                                  onPressed: () async {
                                    if (_formKeyWithdrawProvision.currentState
                                        .validate()) {
                                      _formKeyWithdrawProvision.currentState
                                          .save();

                                      Navigator.pop(context);

                                      handleCommitWithdraw(context,
                                          Decimal.parse(withdrawValue));
                                    }
                                  })
                            ]);
                      }),
                      SizedBox(
                        width: 8,
                      ),
                      _buildButton('转入', () {
                        UiUtil.showDialogWidget(context,
                            title: Text('转入hyn到奖励池'),
                            content: _buildDepositProvisionForm(
                                context, rewardAmount),
                            actions: [
                              FlatButton(
                                  child: Text('提交'),
                                  onPressed: () async {
                                    if (_formKeyDepositProvision.currentState
                                        .validate()) {
                                      _formKeyDepositProvision.currentState
                                          .save();

                                      Navigator.pop(context);

                                      handleCommitDeposit(
                                          context, Decimal.parse(depositValue));
                                    }
                                  })
                            ]);
                      }),
                    ]),
                Divider(
                  height: 1,
                ),
                _buildItem(
                    '最大抵押量: ${FormatUtil.formatCoinNum(maxTotalDelegation.toDouble())} hyn',
                    [
                      _buildButton('修改', () {
                        UiUtil.showDialogWidget(context,
                            title: Text('修改最大抵押量'),
                            content: _buildChangeMaxDelegationForm(
                                context, maxTotalDelegation),
                            actions: [
                              FlatButton(
                                  child: Text('提交'),
                                  onPressed: () async {
                                    if (_formKeyMaxTotalDelegation.currentState
                                        .validate()) {
                                      _formKeyMaxTotalDelegation.currentState
                                          .save();

                                      Navigator.pop(context);

                                      handleCommitChangeMaxDelegation(context,
                                          Decimal.parse(maxDelegationValue));
                                    }
                                  })
                            ]);
                      }),
                    ]),
                Divider(
                  height: 1,
                ),
                _buildItem('180天年化: $annualized180%', [
                  _buildButton('修改', () {
                    UiUtil.showDialogWidget(context,
                        title: Text('修改180天年化'),
                        content: _buildAnnualizedForm(
                            annualized180.toString(), _formKey180),
                        actions: [
                          FlatButton(
                              child: Text('提交'),
                              onPressed: () async {
                                if (_formKey180.currentState.validate()) {
                                  _formKey180.currentState.save();

                                  Navigator.pop(context);

                                  handleCommitAnnualized(
                                      context,
                                      2,
                                      (double.parse(annualizedToCommit) * 100)
                                          .toInt());
                                }
                              })
                        ]);
                  }),
                ]),
                Divider(
                  height: 1,
                ),
                _buildItem('90天年化: $annualized90%', [
                  _buildButton('修改', () {
                    UiUtil.showDialogWidget(context,
                        title: Text('修改90天年化'),
                        content: _buildAnnualizedForm(
                            annualized90.toString(), _formKey90),
                        actions: [
                          FlatButton(
                              child: Text('提交'),
                              onPressed: () async {
                                if (_formKey90.currentState.validate()) {
                                  _formKey90.currentState.save();

                                  Navigator.pop(context);

                                  handleCommitAnnualized(
                                      context,
                                      1,
                                      (double.parse(annualizedToCommit) * 100)
                                          .toInt());
                                }
                              })
                        ]);
                  }),
                ]),
                Divider(
                  height: 1,
                ),
                _buildItem('30天年化: $annualized30%', [
                  _buildButton(
                    '修改',
                    () {
                      UiUtil.showDialogWidget(context,
                          title: Text('修改30天年化'),
                          content: _buildAnnualizedForm(
                              annualized30.toString(), _formKey30),
                          actions: [
                            FlatButton(
                                child: Text('提交'),
                                onPressed: () async {
                                  if (_formKey30.currentState.validate()) {
                                    _formKey30.currentState.save();

                                    Navigator.pop(context);

                                    handleCommitAnnualized(
                                        context,
                                        0,
                                        (double.parse(annualizedToCommit) * 100)
                                            .toInt());
                                  }
                                })
                          ]);
                    },
                  ),
                ]),
                SizedBox(height: 16),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    RaisedButton(
                      child: Text('刷新'),
                      onPressed: () {
                        _loadData();
                      },
                    ),
                    if (_isLoading)
                      Container(
                        margin: EdgeInsets.only(left: 16),
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 3,
                        ),
                      )
                  ],
                )
              ],
            ),
          );
        },
      ),
    );
  }

  void handleCommitAnnualized(context, type, int value) async {
    var password = await UiUtil.showWalletPasswordDialogV2(
      context,
      wallet,
    );
    if (password != null) {
      setState(() {
        _isCommitting = true;
      });

      var contract =
          WalletUtil.getMap3Contract(WalletConfig.map3ContractAddress);
      var setProvisionFun = contract.function('setAnnualizedYield');
      try {
        final client = WalletUtil.getWeb3Client();
        var credentials = await wallet.getCredentials(password);
        var response = await client.sendTransaction(
          credentials,
          Transaction.callContract(
            contract: contract,
            function: setProvisionFun,
            parameters: [BigInt.from(type), BigInt.from(value)],
            gasPrice: EtherAmount.inWei(BigInt.from(
                QuotesInheritedModel.of(context)
                    .gasPriceRecommend
                    .fast
                    .toInt())),
            maxGas: 2800000,
          ),
          fetchChainIdFromNetworkId: true,
        );

        print('-提交成功 hash $response');

        await UiUtil.showSetBioAuthDialog(
          context,
          '提交成功',
          wallet,
          password,
        );

        UiUtil.showSnackBar(context, '提交成功，请留意钱包划账记录');
      } catch (e) {
        logger.e(e);
        UiUtil.toast(e.message);
      }

      setState(() {
        _isCommitting = false;
      });
    }
  }

  Widget _buildAnnualizedForm(currentValue, key) {
    return Form(
      key: key,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Expanded(
                child: TextFormField(
                  decoration: InputDecoration(
                    hintText: '范围 0～100',
                  ),
                  validator: (value) {
                    if (value.length == 0) {
                      return '请输入年化值';
                    }
                    var valueDouble = double.parse(value);
                    if (valueDouble < 0 || valueDouble > 100) {
                      return '年化取值范围为0~100';
                    }
                    return null;
                  },
                  keyboardType: TextInputType.number,
                  onSaved: (value) {
                    annualizedToCommit = value;
                  },
                ),
              ),
              Text('%'),
            ],
          ),
          SizedBox(
            height: 8,
          ),
          Text('当前值 $currentValue%'),
        ],
      ),
    );
  }

  Widget _buildChangeMaxDelegationForm(context, currentValue) {
    return Form(
      key: _formKeyMaxTotalDelegation,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Expanded(
                child: TextFormField(
                  decoration: InputDecoration(
                    hintText: '请输入...',
                  ),
                  validator: (value) {
                    if (value.length == 0) {
                      return '请输入HYN抵押量';
                    }
                    var valueDouble = double.parse(value);
                    if (valueDouble <= 0) {
                      return '必须大于0';
                    }
                    return null;
                  },
                  keyboardType: TextInputType.number,
                  onSaved: (value) {
                    maxDelegationValue = value;
                  },
                ),
              ),
              Text('hyn'),
            ],
          ),
          SizedBox(
            height: 8,
          ),
          Text('当前值 $currentValue hyn'),
        ],
      ),
    );
  }

  Widget _buildDepositProvisionForm(context, Decimal currentValue) {
    return Form(
      key: _formKeyDepositProvision,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Expanded(
                child: TextFormField(
                  decoration: InputDecoration(
                    hintText: '请输入...',
                  ),
                  validator: (value) {
                    if (value.length == 0) {
                      return '请输入转入HYN数量';
                    }
                    var valueDouble = double.parse(value);
                    if (valueDouble <= 0) {
                      return '必须大于0';
                    }
                    return null;
                  },
                  keyboardType: TextInputType.number,
                  onSaved: (value) {
                    depositValue = value;
                  },
                ),
              ),
              Text('hyn'),
//              InkWell(child: Text('全部', style: TextStyle(color: Colors.blue),), onTap: () {
//                textEditorController.text = currentValue.toString();
//              },),
            ],
          ),
          SizedBox(
            height: 8,
          ),
          Text(
              '当前奖励池 ${FormatUtil.formatCoinNum(currentValue.toDouble())} hyn'),
        ],
      ),
    );
  }

  Widget _buildWithdrawProvisionForm(context, Decimal currentValue) {
    return Form(
      key: _formKeyWithdrawProvision,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Expanded(
                child: TextFormField(
                  controller: textEditorController,
                  decoration: InputDecoration(
                    hintText: '请输入...',
                  ),
                  validator: (value) {
                    if (value.length == 0) {
                      return '请输入取回HYN数量';
                    }
                    var valueDouble = double.parse(value);
                    if (valueDouble <= 0) {
                      return '必须大于0';
                    }
                    return null;
                  },
                  keyboardType: TextInputType.number,
                  onSaved: (value) {
                    withdrawValue = value;
                  },
                ),
              ),
//              Text('hyn'),
              InkWell(
                child: Text(
                  '全部',
                  style: TextStyle(color: Colors.blue),
                ),
                onTap: () {
                  textEditorController.text = currentValue.toString();
                },
              ),
            ],
          ),
          SizedBox(
            height: 8,
          ),
          Text(
              '当前奖励池 ${FormatUtil.formatCoinNum(currentValue.toDouble())} hyn'),
        ],
      ),
    );
  }

  void handleCommitDeposit(context, Decimal value) async {
    var password = await UiUtil.showWalletPasswordDialogV2(
      context,
      wallet.getEthAccount().address,
    );
    if (password != null) {
      setState(() {
        _isCommitting = true;
      });

      try {
        var wallet = WalletInheritedModel.of(context).activatedWallet?.wallet;

        var password = await UiUtil.showWalletPasswordDialogV2(
          context,
          wallet,
        );
        var hynAssetToken = wallet.getHynToken();
        var hynErc20ContractAddress = hynAssetToken?.contractAddress;
        var approveToAddress = WalletConfig.map3ContractAddress;

        final client = WalletUtil.getWeb3Client();
        var count = await client.getTransactionCount(
            EthereumAddress.fromHex(wallet.getEthAccount().address));

        var approveHex = await wallet.sendApproveErc20Token(
            contractAddress: hynErc20ContractAddress,
            approveToAddress: approveToAddress,
            amount: ConvertTokenUnit.decimalToWei(value),
            password: password,
            gasPrice: BigInt.from(QuotesInheritedModel.of(context)
                .gasPriceRecommend
                .fast
                .toInt()),
            gasLimit: SettingInheritedModel.ofConfig(context)
                .systemConfigEntity
                .erc20ApproveGasLimit,
            nonce: count);
        print('approve has: $approveHex');

        var contract =
            WalletUtil.getMap3Contract(WalletConfig.map3ContractAddress);
        var contractFun = contract.function('depositProvision');
        var credentials = await wallet.getCredentials(password);
        var response = await client.sendTransaction(
          credentials,
          Transaction.callContract(
            contract: contract,
            function: contractFun,
            parameters: [ConvertTokenUnit.decimalToWei(value)],
            gasPrice: EtherAmount.inWei(BigInt.from(
                QuotesInheritedModel.of(context)
                    .gasPriceRecommend
                    .fast
                    .toInt())),
            maxGas: 2800000,
            nonce: count + 1,
          ),
          fetchChainIdFromNetworkId: true,
        );

        print('-提交成功 hash $response');

        await UiUtil.showSetBioAuthDialog(
          context,
          '提交成功',
          wallet,
          password,
        );

        UiUtil.showSnackBar(context, '提交成功，请留意钱包划账记录');
      } catch (e) {
        logger.e(e);
        UiUtil.toast(e.message);
      }

      setState(() {
        _isCommitting = false;
      });
    }
  }

  void handleCommitWithdraw(context, Decimal value) async {
    var password = await UiUtil.showWalletPasswordDialogV2(
      context,
      wallet.getEthAccount().address,
    );
    if (password != null) {
      setState(() {
        _isCommitting = true;
      });

      var contract =
          WalletUtil.getMap3Contract(WalletConfig.map3ContractAddress);
      var contractFun = contract.function('withdrawProvision');
      try {
        final client = WalletUtil.getWeb3Client();
        var credentials = await wallet.getCredentials(password);
        var response = await client.sendTransaction(
          credentials,
          Transaction.callContract(
            contract: contract,
            function: contractFun,
            parameters: [ConvertTokenUnit.decimalToWei(value)],
            gasPrice: EtherAmount.inWei(BigInt.from(
                QuotesInheritedModel.of(context)
                    .gasPriceRecommend
                    .fast
                    .toInt())),
            maxGas: 2800000,
          ),
          fetchChainIdFromNetworkId: true,
        );

        print('-提交成功 hash $response');

        await UiUtil.showSetBioAuthDialog(
          context,
          '提交成功',
          wallet,
          password,
        );

        UiUtil.showSnackBar(context, '提交成功，请留意钱包划账记录');
      } catch (e) {
        logger.e(e);
        UiUtil.toast(e.message);
      }

      setState(() {
        _isCommitting = false;
      });
    }
  }

  void handleCommitChangeMaxDelegation(context, Decimal value) async {
    var password = await UiUtil.showWalletPasswordDialogV2(
      context,
      wallet.getEthAccount().address,
    );
    if (password != null) {
      setState(() {
        _isCommitting = true;
      });

      var contract =
          WalletUtil.getMap3Contract(WalletConfig.map3ContractAddress);
      var contractFun = contract.function('setMaxTotalDelegation');
      try {
        final client = WalletUtil.getWeb3Client();
        var credentials = await wallet.getCredentials(password);
        var response = await client.sendTransaction(
          credentials,
          Transaction.callContract(
            contract: contract,
            function: contractFun,
            parameters: [ConvertTokenUnit.decimalToWei(value)],
            gasPrice: EtherAmount.inWei(BigInt.from(
                QuotesInheritedModel.of(context)
                    .gasPriceRecommend
                    .fast
                    .toInt())),
            maxGas: 2800000,
          ),
          fetchChainIdFromNetworkId: true,
        );

        print('-提交成功 hash $response');

        await UiUtil.showSetBioAuthDialog(
          context,
          '提交成功',
          wallet,
          password,
        );

        UiUtil.showSnackBar(context, '提交成功，请留意钱包划账记录');
      } catch (e) {
        logger.e(e);
        UiUtil.toast(e.message);
      }

      setState(() {
        _isCommitting = false;
      });
    }
  }

  Widget _buildButton(String text, onTap) {
    return Ink(
        child: InkWell(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: Text(text, style: TextStyle(color: Colors.blue)),
            ),
            onTap: onTap));
  }

  Widget _buildItem(String title, [List<Widget> widgets]) {
    return Material(
      color: Colors.white,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        child: Row(
          children: <Widget>[
            Expanded(child: Text(title)),
            if (widgets != null) ...widgets,
          ],
        ),
      ),
    );
  }
}
