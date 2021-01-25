import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:pinput/pin_put/pin_put.dart';
import 'package:flutter/services.dart';
import 'package:titan/generated/l10n.dart';
import 'package:titan/src/basic/utils/hex_color.dart';
import 'package:titan/src/basic/widget/load_data_container/bloc/bloc.dart';
import 'package:titan/src/basic/widget/load_data_container/load_data_container.dart';
import 'package:titan/src/pages/red_pocket/rp_share_get_success_page.dart';
import 'package:titan/src/pages/red_pocket/rp_share_get_dialog_page.dart';
import 'package:titan/src/pages/red_pocket/widget/fl_pie_chart.dart';
import 'package:titan/src/pages/red_pocket/widget/rp_airdrop_widget.dart';
import 'package:titan/src/pages/red_pocket/widget/rp_statistics_widget.dart';
import 'package:titan/src/pages/wallet/wallet_new_page/wallet_safe_lock.dart';
import 'package:titan/src/style/titan_sytle.dart';
import 'package:titan/src/utils/utile_ui.dart';
import 'package:titan/src/widget/round_border_textfield.dart';

import 'atlas_map_widget.dart';
import 'clip_tab_bar.dart';
import 'loading_button/click_oval_button.dart';

class WidgetDemoPage extends StatefulWidget {
  WidgetDemoPage();

  @override
  State<StatefulWidget> createState() {
    return _WidgetDemoPageState();
  }
}

class _WidgetDemoPageState extends State<WidgetDemoPage> with SingleTickerProviderStateMixin {
  ///

  LoadDataBloc _loadDataBloc = LoadDataBloc();
  final TextEditingController _textEditController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _pinPutController = TextEditingController();
  final FocusNode _pinPutFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.black),
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Widget Demo',
          style: TextStyle(
            color: Colors.black,
          ),
        ),
      ),
      body: Container(
          width: double.infinity,
          height: double.infinity,
          child: CustomScrollView(
            physics: BouncingScrollPhysics(),
            slivers: <Widget>[
              // _statisticsWidget(),
              SliverToBoxAdapter(
                child: FlatButton(
                  onPressed: () {
                    showShareRpOpenDialog(context, id: "WBY657");
                    // showShareRpOpenDialog(context,id: "53K7RE");
                  },
                  child: Text("分享红包"),
                  color: DefaultColors.color999,
                ),
              ),
              SliverToBoxAdapter(
                child: FlatButton(
                  onPressed: () {
                    _showStakingAlertView();
                  },
                  child: Text("口令弹窗"),
                  color: DefaultColors.color999,
                ),
              ),
              SliverToBoxAdapter(
                child: FlatButton(
                  onPressed: () {
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (BuildContext context) => RpShareGetSuccessPage(null),
                    ));
                  },
                  child: Text("红包详情"),
                  color: DefaultColors.color999,
                ),
              ),
              SliverToBoxAdapter(
                child: FlatButton(
                  onPressed: () {
                    _showBottomDialogView(
                        imagePath: "res/drawable/ic_wallet_setting_delete_account.png",
                        dialogTitle: "退出身份",
                        dialogSubTitle: "退出身份后将删除所有钱包数据，请务必确保助记词已经备份",
                        imageHeight: 66,
                        actions: [ClickOvalButton("确认退出", () async {

                        },width: 300,height: 44,btnColor: [HexColor("#FF4B4B")],fontSize: 16,)]);
                  },
                  child: Text("底部弹窗"),
                  color: DefaultColors.color999,
                ),
              ),
            ],
          )),
    );
  }

  Future<String> _showStakingAlertView() async {
    _textEditController.text = "";

    String rpSecret = await UiUtil.showAlertViewNew<String>(
      context,
      actions: [
        ClickOvalButton(
          S.of(context).confirm,
          () {
            Navigator.pop(context, _textEditController.text);
          },
          width: 200,
          height: 38,
          fontSize: 16,
          fontWeight: FontWeight.normal,
        ),
      ],
      contentWidget: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 19, bottom: 32.0),
            child: Text("输入红包口令",
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: HexColor("#333333"),
                    decoration: TextDecoration.none)),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 24, right: 24.0, bottom: 20),
            child: Material(
              child: Form(
                key: _formKey,
                child: RoundBorderTextField(
                  controller: _textEditController,
                  keyboardType: TextInputType.text,
                  inputFormatters: [
                    LengthLimitingTextInputFormatter(20),
                  ],
                  hintText: "请输入口令",
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  _statisticsWidget() {
    return SliverToBoxAdapter(
        child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.all(Radius.circular(16.0)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                WalletSafeLock(),
              ],
            )));
  }

  _showBottomDialogView({
    double dialogHeight = 288,
    Widget customWidget,
    String imagePath,
    double imageHeight,
    String dialogTitle,
    String dialogSubTitle,
    bool enableDrag = true,
    List<Widget> actions,
  }) async {
    showModalBottomSheet(
        context: context,
        enableDrag: enableDrag,
        shape: RoundedRectangleBorder(
          borderRadius:
              BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
        ),
        builder: (BuildContext context) {
          return Container(
            height: dialogHeight,
            child: Stack(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    if (customWidget != null) customWidget,
                    if (imagePath != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 24.0),
                        child: Image.asset(
                          imagePath,
                          height: imageHeight,
                        ),
                      ),
                    if (dialogTitle != null)
                      Padding(
                        padding: const EdgeInsets.only(
                          top: 19,
                          left: 49,
                          right: 49,
                        ),
                        child: Text(
                          dialogTitle,
                          style: TextStyle(
                            fontSize: 16,
                            color: DefaultColors.color333,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    if (dialogSubTitle != null)
                      Padding(
                        padding: const EdgeInsets.only(
                          top: 16,
                          left: 49,
                          right: 49,
                        ),
                        child: Text(
                          dialogSubTitle,
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 14, color: HexColor('#666666')),
                        ),
                      ),
                    if (actions != null)
                      Padding(
                        padding: EdgeInsets.only(top: 26, bottom: 26),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: actions,
                        ),
                      )
                  ],
                ),
                Positioned(
                  child: InkWell(
                    child: Image.asset(
                      'res/drawable/ic_close.png',
                      width: 16,
                      height: 16,
                    ),
                    onTap: () {
                      Navigator.of(context).pop();
                    },
                  ),
                  left: 24,
                  top: 24,
                )
              ],
            ),
          );
        });
  }
}
