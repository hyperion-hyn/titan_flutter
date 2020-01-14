import 'package:flutter/material.dart';
import 'package:titan/src/basic/utils/hex_color.dart';

class RoundCheckBox extends StatefulWidget {
  var value = false;

  void Function(bool) onChanged;

  RoundCheckBox({Key key, @required this.value, this.onChanged})
      : super(key: key);

  @override
  _RoundCheckBoxState createState() => _RoundCheckBoxState();
}

class _RoundCheckBoxState extends State<RoundCheckBox> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: _buildView(),
    );
  }

  Widget _buildView() {
    if (widget.onChanged == null) {
      return _buildBody();
    } else {
      return GestureDetector(
          onTap: () {
            widget.value = !widget.value;
            widget.onChanged(widget.value);
          },
          child: _buildBody());
    }
  }

  Widget _buildBody() {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: widget.value
          ? Image.asset(
              "res/drawable/widget_checkbox_checked.png",
              width: 18,
              height: 18,
            )
          : Image.asset(
              "res/drawable/widget_checkbox_uncheck.png",
              width: 18,
              height: 18,
            ),
    );
  }
}
