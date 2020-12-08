import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:titan/generated/l10n.dart';
import 'package:titan/src/basic/utils/hex_color.dart';
import 'package:titan/src/basic/widget/base_app_bar.dart';
import 'package:titan/src/basic/widget/base_state.dart';
import 'package:titan/src/basic/widget/load_data_container/load_data_container.dart';
import 'package:titan/src/style/titan_sytle.dart';
import 'package:titan/src/utils/utile_ui.dart';
import 'package:titan/src/widget/loading_button/click_oval_button.dart';
import 'package:titan/src/widget/round_border_textfield.dart';
import 'package:titan/src/utils/log_util.dart';
import 'package:titan/src/basic/widget/load_data_container/bloc/bloc.dart';

class RpLevelUpgradePage extends StatefulWidget {
  RpLevelUpgradePage();

  @override
  State<StatefulWidget> createState() {
    return _RpLevelUpgradeState();
  }
}

class _RpLevelUpgradeState extends BaseState<RpLevelUpgradePage> {
  TextEditingController _textEditingController = new TextEditingController();
  final _formKey = GlobalKey<FormState>();
  double minTotal = 0;
  double remainTotal = 0;

  LoadDataBloc _loadDataBloc = LoadDataBloc();

  @override
  void initState() {
    super.initState();
  }

  @override
  void onCreated() {
    // getNetworkData();

    setState(() {
      _loadDataBloc.add(RefreshSuccessEvent());
    });

    super.onCreated();
  }

  @override
  void dispose() {
    print("[${widget.runtimeType}] dispose");

    _loadDataBloc.close();
    super.dispose();
  }

  Future getNetworkData() async {
    try {
      if (mounted) {
        setState(() {
          _loadDataBloc.add(RefreshSuccessEvent());
        });
      }
    } catch (e) {
      LogUtil.toastException(e);

      if (mounted) {
        setState(() {
          _loadDataBloc.add(RefreshFailEvent());
        });
      }
    }
  }

  TextStyle _textStyle = TextStyle(
    fontWeight: FontWeight.w500,
    fontSize: 14,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: BaseAppBar(
        baseTitle: '升级量级',
      ),
      backgroundColor: Colors.white,
      body: Column(
        children: <Widget>[
          Expanded(
            child: LoadDataContainer(
              bloc: _loadDataBloc,
              enablePullUp: false,
              onRefresh: getNetworkData,
              isStartLoading: false,
              child: BaseGestureDetector(
                context: context,
                child: SingleChildScrollView(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16,),
                    color: Colors.white,
                    child: Column(
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.only(top: 18),
                          child: Row(
                            children: <Widget>[
                              Text('提升到 B 持币量级', style: TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 16,
                              )),

                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 20),
                          child: Row(
                            children: <Widget>[
                              Text('需燃烧', style: _textStyle),
                              SizedBox(
                                width: 16,
                              ),
                              Text('30 RP', style: _textStyle),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only( top: 30),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: <Widget>[
                              Text('转入持币', style: _textStyle),
                              SizedBox(width: 5,),
                              Text('（至少31.5 RP）', style: TextStyle(
                                fontWeight: FontWeight.normal,
                                fontSize: 12,
                                color: HexColor('#999999'),
                              )),
                              SizedBox(width: 20,),
                              Text('当前持币 20 RP', style: TextStyle(
                                fontWeight: FontWeight.normal,
                                fontSize: 12,
                                color: HexColor('#999999'),
                              )),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 16, right: 50,),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              Flexible(
                                flex: 1,
                                child: Form(
                                  key: _formKey,
                                  child: RoundBorderTextField(
                                    onChanged: (text) {
                                      _formKey.currentState.validate();
                                    },
                                    controller: _textEditingController,
                                    keyboardType: TextInputType.numberWithOptions(decimal: true),
                                    //inputFormatters: [WhitelistingTextInputFormatter.digitsOnly],
                                    hint: S.of(context).please_enter_withdraw_amount,
                                    validator: (textStr) {
                                      if (textStr.length == 0) {
                                        return '请输入提币数量';
                                      }

                                      var inputValue = Decimal.tryParse(textStr);
                                      if (inputValue == null) {
                                        return S.of(context).please_enter_correct_amount;
                                      }
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Row(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(top: 8,),
                              child: Text(
                                '*',
                                style: TextStyle(
                                  color: HexColor('#FF4C3B'),
                                  fontSize: 24,
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 6,
                            ),
                            Text(
                              '为防止因Y增长导致掉级，建议适当增加持币量',
                              style: TextStyle(
                                color: HexColor('#333333'),
                                fontSize: 12,
                              ),
                            )
                          ],
                        )
                      ],
                    ),
                  ),
                      Padding(
                        padding: const EdgeInsets.only(top: 60, left: 16, right: 16,),
                        child: Text(
                          '提示：因你还没有推荐人，系统将为你随机设定一个量级4以上的账户地址为推荐人',
                          style: TextStyle(
                            color: HexColor('#C3A16D'),
                            fontSize: 12,
                          ),
                        ),
                      ),
                      _confirmButtonWidget(),
                ])),
              ),
            ),
          ),

        ],
      ),
    );
  }

  Widget _confirmButtonWidget() {
    return Container(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.only(top: 30),
        child: Center(
          child: ClickOvalButton(
            '马上提升',
            _confirmAction,
            height: 42,
            width: MediaQuery.of(context).size.width - 37 * 2,
            fontSize: 18,
            btnColor: [HexColor('#FF0527'), HexColor('#FF4D4D')],
          ),
        ),
      ),
    );
  }

  _confirmAction() {
    FocusScope.of(context).requestFocus(FocusNode());

    if (!_formKey.currentState.validate()) {
      return;
    }

    Future.delayed(Duration(milliseconds: 111)).then((_) {
      _showAlertView();
    });
  }

  _showAlertView() {

    UiUtil.showAlertView(
      context,
      title: '重要提醒',
      actions: [
        ClickOvalButton(
          '取回',
              () async {
            Navigator.pop(context, false);

          },
          width: 115,
          height: 36,
          fontSize: 14,
          fontWeight: FontWeight.normal,
          fontColor: DefaultColors.color333,
          btnColor: [Colors.transparent],
        ),
        SizedBox(
          width: 20,
        ),
        ClickOvalButton(
          '再想想',
              () {
            Navigator.pop(context, true);
          },
          width: 115,
          height: 36,
          fontSize: 16,
          fontWeight: FontWeight.normal,
          btnColor: [HexColor('#FF0527'), HexColor('#FF4D4D')],
        ),
      ],
      content: '您要取回50RP到钱包，剩余持币不足当前量级3所需最低持币量，您的量级将掉到量级2，请谨慎操作',
      isInputValue: false,
    );
  }

}
