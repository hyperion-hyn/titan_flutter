import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:titan/generated/l10n.dart';
import 'package:titan/src/basic/utils/hex_color.dart';
import 'package:titan/src/basic/widget/base_app_bar.dart';

class AtlasOptionEditPage extends StatefulWidget {
  final String title;
  final String content;
  final String hint;
  final TextInputType keyboardType;
  final int maxLength;

  AtlasOptionEditPage({
    this.title,
    this.content,
    this.hint,
    this.keyboardType,
    this.maxLength = 200,
  });

  @override
  State<StatefulWidget> createState() {
    return _AtlasNodeOptionEditState();
  }
}

class _AtlasNodeOptionEditState extends State<AtlasOptionEditPage> {
  TextEditingController _controller = TextEditingController();
  GlobalKey<FormState> formKey;

  @override
  void initState() {
    super.initState();
    if (widget.content != null) {
      _controller.text = widget.content;
    }
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
        baseTitle: S.of(context).edit + widget.title ?? S.of(context).edit,
        actions: [
          FlatButton(
            onPressed: () {
              Navigator.of(context).pop(_controller.text);
            },
            child: Text(
              S.of(context).save,
              style: TextStyle(color: HexColor("#1F81FF")),
            ),
          )
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
            maxLength: widget.maxLength,
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
            onChanged: (value) {},
          ),
        ),
      ),
    );
  }
}
