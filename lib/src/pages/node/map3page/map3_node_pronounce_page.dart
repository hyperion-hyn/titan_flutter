import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:titan/generated/l10n.dart';
import 'package:titan/src/basic/utils/hex_color.dart';

class Map3NodePronouncePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _May3NodePronounceState();
  }
}

class _May3NodePronounceState extends State {
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
        centerTitle: true,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
        title: Text(
          "节点公告",
          style: TextStyle(color: Colors.white),
        ),
        actions: <Widget>[
          FlatButton(
            onPressed: (){
              print("[Pronounce] text:1111111");

              print("[Pronounce] text:${_controller.text}");
              Navigator.of(context).pop(_controller.text);
            },
            child: Text(
              "保存",
              style: TextStyle(color: HexColor("#ccffffff")),
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
            keyboardType: TextInputType.text,
            maxLength: 200,
            maxLines: 7,
            style: TextStyle(color: HexColor("#333333"), fontSize: 14),
            decoration: InputDecoration(
              hintStyle: TextStyle(color: HexColor("#B8B8B8"), fontSize: 14),
              //labelStyle: TextStyle(color: HexColor("#333333"), fontSize: 12),
              hintText: "大家快来参与我的节点吧，收益高高！",
              border: InputBorder.none,
            ),
            validator: (textStr) {
              if (textStr.length == 0) {
                return "大家快来参与我的节点吧，收益高高！";
              }
              {
                return null;
              }
            },
            onChanged: (value) {
              print("[NodePronounce] value:$value");
            },
          ),
        ),
      ),
    );
  }
}
