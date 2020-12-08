import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:titan/generated/l10n.dart';
import 'package:titan/src/basic/utils/hex_color.dart';
import 'package:titan/src/basic/widget/base_app_bar.dart';
import 'package:titan/src/basic/widget/base_state.dart';
import 'package:titan/src/basic/widget/load_data_container/load_data_container.dart';
import 'package:titan/src/widget/loading_button/click_oval_button.dart';
import 'package:titan/src/widget/round_border_textfield.dart';
import 'package:titan/src/utils/log_util.dart';
import 'package:titan/src/basic/widget/load_data_container/bloc/bloc.dart';

class RpLevelUnStakingPage extends StatefulWidget {
  RpLevelUnStakingPage();

  @override
  State<StatefulWidget> createState() {
    return _RpLevelUnStakingState();
  }
}

class _RpLevelUnStakingState extends BaseState<RpLevelUnStakingPage> {
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
        baseTitle: '取回持币',
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
                              Text('当前持币', style: _textStyle),
                              SizedBox(
                                width: 16,
                              ),
                              Text('100 RP', style: _textStyle),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 20),
                          child: Row(
                            children: <Widget>[
                              Text('当前量级C需持币', style: _textStyle),
                              SizedBox(
                                width: 16,
                              ),
                              Text('63 RP', style: _textStyle),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only( top: 30),
                          child: Row(
                            children: <Widget>[
                              Text('取回持币', style: _textStyle),
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
                                        return S.of(context).please_input_hyn_count;
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
                            Text(
                              '*',
                              style: TextStyle(
                                color: HexColor('#FF4C3B'),
                                fontSize: 24,
                              ),
                            ),
                            SizedBox(
                              width: 6,
                            ),
                            Text(
                              '为保证当前量级不下降，请保持持币量大于63RP',
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
                ])),
              ),
            ),
          ),
          _confirmButtonWidget(),
        ],
      ),
    );
  }

  Widget _confirmButtonWidget() {
    return Container(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 18.0, top: 10),
        child: Center(
          child: ClickOvalButton(
            '取回持币',
            _confirmAction,
            height: 46,
            width: MediaQuery.of(context).size.width - 37 * 2,
            fontSize: 18,
          ),
        ),
      ),
    );
  }

  _confirmAction() async {
    if (!_formKey.currentState.validate()) {
      return;
    }

    /*
    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => Map3NodeConfirmPage(
            message: 'message',
          ),
        ));
        */
  }
}
