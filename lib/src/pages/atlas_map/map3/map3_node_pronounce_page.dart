import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:titan/generated/l10n.dart';
import 'package:titan/src/basic/utils/hex_color.dart';
import 'package:titan/src/basic/widget/base_app_bar.dart';

class Map3NodePronouncePage extends StatefulWidget {
  final String title;
  final String text;
  final String hint;
  final TextInputType keyboardType;

  Map3NodePronouncePage({this.title, this.text, this.hint, this.keyboardType});

  @override
  State<StatefulWidget> createState() {
    return _May3NodePronounceState();
  }
}

class _May3NodePronounceState extends State<Map3NodePronouncePage> {
  TextEditingController _controller = TextEditingController();
  GlobalKey<FormState> formKey;

  @override
  void initState() {
    if (widget?.text?.isNotEmpty??false) {
      _controller.text = widget.text;
    }
    super.initState();
  }

  @override
  void dispose() {
    print("[Pronounce] dispose");

    formKey = GlobalKey();
    super.dispose();
  }

  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: BaseAppBar(
        baseTitle: S.of(context).edit + ' ' + widget.title ?? S.of(context).create_map3_node,
        actions: <Widget>[
          FlatButton(
            onPressed: () {
              print("[${widget.runtimeType}] text:${_controller?.text??''}");
              Navigator.of(context).pop(_controller.text);
            },
            child: Text(
              S.of(context).save,
              style: TextStyle(color: HexColor("#1F81FF")),
            ),
          ),
        ],
      ),
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Form(
          key: formKey,
          child: TextFormField(
            autofocus: true,
            controller: _controller,
            keyboardType: widget.keyboardType ?? TextInputType.text,
            maxLength: 60,
            maxLines: 7,
            style: TextStyle(color: HexColor("#333333"), fontSize: 14),
            decoration: InputDecoration(
              hintStyle: TextStyle(color: HexColor("#B8B8B8"), fontSize: 14),
              hintText: widget.hint,
              border: InputBorder.none,
            ),
            validator: (textStr) {
              if (textStr.length == 0) {
                return widget.hint;
              }
              {
                return null;
              }
            },
            onChanged: (value) {
              print("[${widget.runtimeType}] value:${value??''}");
            },
          ),
        ),
      ),
    );
  }
}
