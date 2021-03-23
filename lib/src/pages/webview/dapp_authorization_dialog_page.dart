import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:titan/generated/l10n.dart';
import 'package:titan/src/basic/utils/hex_color.dart';
import 'package:titan/src/basic/widget/base_state.dart';
import 'package:titan/src/utils/utile_ui.dart';
import 'package:titan/src/widget/loading_button/click_oval_button.dart';

class DAppAuthorizationDialogPage extends StatefulWidget {
  final DAppAuthorizationDialogEntity entity;
  DAppAuthorizationDialogPage({
    @required this.entity,
  });

  @override
  State<StatefulWidget> createState() {
    return _DAppAuthorizationDialogState();
  }
}

class _DAppAuthorizationDialogState extends BaseState<DAppAuthorizationDialogPage> {
  final ScrollController _scrollController = ScrollController();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: SafeArea(
        child: Column(
          children: <Widget>[
            Expanded(
              child: SingleChildScrollView(
                controller: _scrollController,
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(
                            top: 14,
                          ),
                          child: Text(
                            widget.entity.title,
                            style: TextStyle(
                              color: HexColor('#999999'),
                              fontWeight: FontWeight.w500,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(
                            top: 32,
                          ),
                          child: Image.asset(
                            'res/drawable/wallet_send_dialog.png',
                            width: 44,
                            height: 44,
                            fit: BoxFit.cover,
                            // color: HexColor('#E7C01A'),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(
                            top: 16,
                          ),
                          child: Text(
                            widget.entity.dAppName,
                            style: TextStyle(
                              color: HexColor('#333333'),
                              fontWeight: FontWeight.w600,
                              fontSize: 18,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Wrap(
                      // mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(
                            top: 16,
                            left: 16,
                            right: 16,
                          ),
                          child: Text(
                            '${widget.entity.dAppName} ${S.of(context).dapp_intruct_content}',
                            style: TextStyle(
                              // color: HexColor('#999999'),
                              fontWeight: FontWeight.normal,
                              fontSize: 14,
                              height: 1.8,
                            ),
                            maxLines: 5,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ClickOvalButton(
                  S.of(context).exit,
                  () {
                    Navigator.of(context).pop(false);
                  },
                  width: 160,
                  height: 42,
                  fontSize: 14,
                  fontColor: Theme.of(context).primaryColor,
                  btnColor: [Colors.transparent],
                  borderColor: Theme.of(context).primaryColor,
                ),
                SizedBox(
                  width: 20,
                ),
                ClickOvalButton(
                  S.of(context).confirm,
                  () {
                    Navigator.of(context).pop(true);
                  },
                  btnColor: [HexColor("#E7C01A"), HexColor("#F7D33D")],
                  fontSize: 14,
                  width: 160,
                  height: 42,
                ),
              ],
            ),
            SizedBox(
              height: 40,
            ),
          ],
        ),
      ),
    );
  }

  Widget _rowText({
    String title = '',
    String content = '',
    String subContent = '',
    bool showLine = true,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
      ),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.only(
              top: title.isNotEmpty ? 20 : 2,
            ),
            child: Row(
              children: [
                SizedBox(
                  width: 100,
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      color: HexColor('#999999'),
                    ),
                  ),
                ),
                Text(
                  content,
                  style: TextStyle(
                    fontSize: 14,
                    color: HexColor('#333333'),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  (subContent?.isEmpty ?? true) ? '' : '（$subContent）',
                  style: TextStyle(
                    fontSize: 14,
                    color: HexColor('#999999'),
                  ),
                ),
              ],
            ),
          ),
          if (showLine)
            Container(
              margin: const EdgeInsets.only(top: 10),
              height: 0.5,
              color: HexColor('#F2F2F2'),
            ),
        ],
      ),
    );
  }

  void _sendAction() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
      });
    }

    //...

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }
}

Future<bool> showDAppAuthorizationDialog<T>({
  @required BuildContext context,
  @required DAppAuthorizationDialogEntity entity,
}) {
  return UiUtil.showBottomDialogView(
    context,
    dialogHeight: MediaQuery.of(context).size.height - 290,
    isScrollControlled: true,
    showCloseBtn: false,
    enableDrag: false,
    isDismissible: false,
    customWidget: DAppAuthorizationDialogPage(
      entity: entity,
    ),
  );
}

class DAppAuthorizationDialogEntity {
  final String title;
  final String dAppName;

  DAppAuthorizationDialogEntity({
    this.title,
    this.dAppName,
  });
}
