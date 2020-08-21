import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:titan/src/basic/utils/hex_color.dart';

class AtlasOptionEditPage extends StatefulWidget {
  final String title;
  final String hint;
  final TextInputType keyboardType;

  AtlasOptionEditPage({
    this.title,
    this.hint,
    this.keyboardType,
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
      appBar: AppBar(
        elevation: 4,
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(
          color: Colors.black,
        ),
        centerTitle: true,
        title: Text(
          '编辑' + widget.title ?? '编辑',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
          ),
        ),
        actions: <Widget>[
          FlatButton(
            onPressed: () {
              Navigator.of(context).pop(_controller.text);
            },
            child: Text(
              "保存",
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
            maxLength: 200,
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

class AppbarWig {
  static Widget appbar(String title, List<Widget> actions) => new Container(
        child: new AppBar(
          backgroundColor: Colors.white,
          iconTheme: IconThemeData(
            color: Colors.black,
          ),
          centerTitle: true,
          title: Text(
            title,
            style: TextStyle(
              color: Colors.black,
              fontSize: 18,
            ),
          ),
          actions: actions,
        ),
        decoration: BoxDecoration(
          boxShadow: <BoxShadow>[
            BoxShadow(
                color: HexColor("#000000").withOpacity(0.01), blurRadius: 4.0)
          ],
        ),
      );
}
