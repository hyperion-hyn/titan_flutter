import 'package:flutter/material.dart';

typedef void JJTextFieldCallBack(String content);

class JJText extends StatefulWidget {
  final String text;
  final bool password;
  // 是否有更多按钮
  final bool isRightBtn;
  // 是否显示取消按钮
  bool isShowClean;
  final Object onChanged;
  // 更多按钮点击
  final Object onRightBtnClick;
  final int maxLines;
  final double height;
  // 左侧按钮图标
  final Widget icon;
  // 右侧更多按钮图标
  final Widget rightIcon;

  final JJTextFieldCallBack fieldCallBack;
  TextEditingController controller = TextEditingController();

  JJText(
      {Key key,
      this.text = "输入内容",
      this.password = false,
      this.isShowClean = false,
      this.onChanged,
      this.onRightBtnClick,
      this.maxLines = 1,
      this.height = 68,
      this.icon,
      this.rightIcon,
      this.isRightBtn = false,
      this.fieldCallBack,
      this.controller})
      : super(key: key);

  @override
  _JJTextaState createState() => _JJTextaState();
}

class _JJTextaState extends State<JJText> {
  FocusNode _focusNode = new FocusNode();
  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_focusNodeListener);
  }

  Future<Null> _focusNodeListener() async {
    if (_focusNode.hasFocus) {
      setState(() {
        widget.isShowClean = true;
      });
    } else {
      setState(() {
        widget.isShowClean = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Container(
          width: 160,
          color: Colors.red,
          padding: const EdgeInsets.fromLTRB(0, 12, 0, 0),

          child: TextField(
            style: TextStyle(fontSize: 14),
            controller: widget.controller,
            decoration: InputDecoration(
              border: InputBorder.none,
              icon: widget.icon,
              fillColor: Colors.green,
              suffixIcon: Container(
                color: Colors.blue,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
//                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    widget.isShowClean
                        ? IconButton(
                            icon: Image.asset(
                              'res/drawable/ic_select_category_search_bar_clear.png',
                              height: 10,
                              width: 10,
                            ),
                            onPressed: onCancel,
                          )
                        : Text(""),
                    widget.isRightBtn
                        ? IconButton(
                            icon: widget.rightIcon,
                            onPressed: widget.onRightBtnClick,
                          )
                        : Text(""),
                  ],
                ),
              ),
              hintText: widget.text,
              hintStyle: TextStyle(fontSize: 12)
            ),
//            textAlignVertical: TextAlignVertical.bottom,
            textAlign: TextAlign.left,
            onChanged: (v) {
              widget.fieldCallBack(v);
              setState(() {
                widget.isShowClean = v.isNotEmpty;
              });
            },
            onSubmitted: (v) {
              widget.fieldCallBack(v);
              setState(() {
                widget.isShowClean = false;
              });
            },
          ),
        ),
      ],
    );
  }

  onCancel() {
    // 保证在组件build的第一帧时才去触发取消清空内
    WidgetsBinding.instance.addPostFrameCallback((_) => widget.controller.clear());
    setState(() {
      widget.isShowClean = false;
    });
    widget.fieldCallBack("");
  }
}
