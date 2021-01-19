import 'package:flutter/material.dart';
import 'package:titan/src/basic/utils/hex_color.dart';
import 'package:titan/src/basic/widget/base_app_bar.dart';
import 'package:titan/src/basic/widget/base_state.dart';
import 'package:titan/src/components/wallet/vo/wallet_vo.dart';
import 'package:titan/src/widget/loading_button/click_oval_button.dart';

class StylePickerPage extends StatefulWidget {
  final String title;
  final int initIndex;
  final String actionTitle;
  final VoidCallback callback;
  final Widget selectedWidget;
  final List<Widget> children;

  StylePickerPage({
    this.title,
    this.initIndex,
    this.actionTitle,
    this.callback,
    this.selectedWidget,
    this.children,
  });

  @override
  State<StatefulWidget> createState() {
    return _StylePickerPageState();
  }
}

class _StylePickerPageState extends BaseState<StylePickerPage> {
  String _title;
  int _initIndex;
  String _actionTitle;
  VoidCallback _callback;
  Widget _selectedWidget;
  List<Widget> _children;

  ScrollController scrollController = ScrollController();
  WalletVo walletVo;

  @override
  void initState() {
    super.initState();

    _title = widget.title;
    _initIndex = widget.initIndex;
    _actionTitle = widget.actionTitle;
    _callback = widget.callback;
    _selectedWidget = widget.selectedWidget;
    _children = widget.children;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: BaseAppBar(
        baseTitle: _title,
      ),
      body: _body(context),
    );
  }

  Widget _body(BuildContext context) {
    return Column(
      children: <Widget>[
        Expanded(
          child: SingleChildScrollView(
            controller: scrollController,
            child: _selectedWidget,
          ),
        ),
        _bottomImageList(),
        ClickOvalButton(
          _actionTitle,
          _callback,
          btnColor: [HexColor("#FF4D4D"), HexColor("#FF0527")],
          fontSize: 16,
          width: 200,
          height: 38,
        ),
        SizedBox(
          height: 40,
        )
      ],
    );
  }

  Widget _bottomImageList() {
    return Padding(
      padding: EdgeInsets.only(left: 16.0, bottom: 23, right: 16),
      child: Container(
        height: 85,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemBuilder: (context, index) {
            var child = _children[index];
            return Padding(
              padding: const EdgeInsets.only(left: 13, right: 13.0),
              child: InkWell(
                onTap: () {
                  setState(() {
                    _initIndex = index;
                  });
                },
                child: child,
              ),
            );
          },
          itemCount: _children.length,
        ),
      ),
    );
  }
}
