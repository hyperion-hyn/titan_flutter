import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_pickers/generated/i18n.dart';
import 'package:titan/src/basic/utils/hex_color.dart';
import 'package:titan/src/config/application.dart';
import 'package:titan/src/routes/routes.dart';
import 'package:titan/src/style/titan_sytle.dart';
import 'package:titan/src/utils/format_util.dart';
import 'package:titan/src/utils/utile_ui.dart';
import 'package:titan/src/widget/click_oval_button.dart';
import 'package:titan/src/widget/click_rectangle_button.dart';
import '../../../extension/navigator_ext.dart';

class RequestMortgagePage extends StatefulWidget {
  final String backRouteName;

  RequestMortgagePage({this.backRouteName});

  @override
  State<StatefulWidget> createState() {
    return _RequestMortgagePageState();
  }
}

class _RequestMortgagePageState extends State<RequestMortgagePage> {
  TextEditingController _textEditingController = new TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(centerTitle: true, title: Text('数据贡献者抵押')),
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Image.asset("res/drawable/atlas_logo.png"),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                    '海伯利安贡献者抵押说明xxxxx。海伯利安贡献者抵押说明xxxxx。海伯利安贡献者抵押说明xxxxx。海伯利安贡献者抵押说明xxxxx。海伯利安贡献者抵押说明xxxxx。海伯利安贡献者抵押说明xxxxx。海伯利安贡献者抵押说明xxxxx。海伯利安贡献者抵押说明xxxxx。海伯利安贡献者抵押说明xxxxx。海伯利安贡献者抵押说明xxxxx。海伯利安贡献者抵押说明xxxxx。海伯利安贡献者抵押说明xxxxx。海伯利安贡献者抵押说明xxxxx。最高5000HYN，每日最高返回xxxx。'),
              ),
            ),
            ClickRectangleButton('抵押', () {
              _showMortgageDialog();
            })
          ],
        ),
      ),
    );
  }

  _showMortgageDialog() {
    Duration insetAnimationDuration = const Duration(milliseconds: 100);
    Curve insetAnimationCurve = Curves.decelerate;
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AnimatedPadding(
            padding: MediaQuery.of(context).viewInsets +
                const EdgeInsets.symmetric(
                  horizontal: 32.0,
                  vertical: 24.0,
                ),
            duration: insetAnimationDuration,
            curve: insetAnimationCurve,
            child: Material(
              color: Colors.transparent,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(4)),
                      color: Colors.white,
                    ),
                    child: Stack(
                      children: <Widget>[
                        Wrap(
                          crossAxisAlignment: WrapCrossAlignment.start,
                          runSpacing: 0.0,
                          children: <Widget>[
                            Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 16.0, vertical: 16.0),
                              child: Text('输入抵押量'),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Form(
                                key: _formKey,
                                child: TextFormField(
                                  controller: _textEditingController,
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [
                                    WhitelistingTextInputFormatter.digitsOnly
                                  ],
                                  decoration: InputDecoration(
                                    focusedErrorBorder: UnderlineInputBorder(
                                      borderSide: BorderSide(
                                          color: HexColor("#FF4C3B")),
                                      borderRadius: BorderRadius.circular(0),
                                    ),
                                    errorStyle: TextStyle(
                                        color: HexColor("#FF4C3B"),
                                        fontSize: 14),
                                    hintStyle: TextStyle(
                                        color: HexColor("#B8B8B8"),
                                        fontSize: 12),
                                    labelStyle: TextStyles.textC333S14,
                                    hintText: '输入抵押HYN量',
                                  ),
                                  validator: (textStr) {},
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: ClickRectangleButton('确定抵押', () {
                                ///Request mortgage
                                ///Navigate to broadcast-finished page when broadcast was sent
                                Application.router.navigateTo(
                                  context,
                                  Routes.contribute_mortgage_broadcast_done,
                                  replace: true,
                                );
                              }),
                            )
                          ],
                        ),
                        Align(
                          child: InkWell(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Icon(Icons.close),
                            ),
                            onTap: () => Navigator.pop(context),
                          ),
                          alignment: Alignment.topRight,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        });
  }

  void _doneAndBack() {
    if (widget.backRouteName == null) {
      Navigator.pop(context);
    } else {
      Navigator.of(context)
          .popUntilRouteName(Uri.decodeComponent(widget.backRouteName));
    }
  }
}
