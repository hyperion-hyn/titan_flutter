import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';

typedef void TextFieldCallBack(String content);

class CustomInputText extends StatefulWidget {
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

  final TextFieldCallBack fieldCallBack;
  TextEditingController controller = TextEditingController();

  CustomInputText(
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
  _TextaState createState() => _TextaState();
}

class _TextaState extends State<CustomInputText> {
  FocusNode _focusNode = new FocusNode();
  PublishSubject<String> _filterSubject = PublishSubject<String>();
  String oldText = "";

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(searchTextChangeListener);
    _filterSubject.debounceTime(Duration(seconds: 2)).listen((text) {
      widget.fieldCallBack(text);
    });
//    _focusNode.addListener(_focusNodeListener);
  }

  @override
  void dispose() {
    _filterSubject.close();
    super.dispose();
  }

  void searchTextChangeListener() {
    String currentText = widget.controller.text.trim();
    widget.controller.selection = TextSelection(baseOffset:currentText.length , extentOffset:currentText.length);
    if(oldText != currentText){
      _filterSubject.sink.add(currentText);
      oldText = currentText;
    }
    if (currentText.isNotEmpty) {
      setState(() {
          widget.isShowClean = true;
        });
    } else {
      widget.fieldCallBack("");
        setState(() {
          widget.isShowClean = false;
        });
    }
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
    return Container(
      width: 220,
      height: 28,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        // // 主轴方向（横向）对齐方式
        crossAxisAlignment: CrossAxisAlignment.center,
        // 交叉轴（竖直）对其方式
        children: <Widget>[
          SizedBox(
            height: 28,
            width: 150,
            child: TextFormField(
              textInputAction: TextInputAction.search,
              onFieldSubmitted: (value){
                widget.fieldCallBack(value);
              },
              focusNode: _focusNode,
              textAlign: TextAlign.left,
              controller: widget.controller,
              style: TextStyle(fontSize: 14),
              onChanged: (value){
                searchTextChangeListener();
              },
              decoration: InputDecoration(
                contentPadding: EdgeInsets.all(9),
                border: InputBorder.none,
                hintText: '请输入搜索词',
                hintStyle: TextStyle(fontSize: 14, color: Color(0xff777777)),
              ),
              keyboardType: TextInputType.text,
            ),
          ),
          Spacer(),
          Container(
            child: Row(
              mainAxisSize: MainAxisSize.min,
//                  mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                widget.isShowClean
                    ? IconButton(
                  icon: Image.asset(
                    'res/drawable/ic_select_category_search_bar_clear.png',
                    height: 13,
                    width: 13,
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
          )
        ],
      ),
    );
  }

  onCancel() {
//    _filterSubject.sink.add("");
    // 保证在组件build的第一帧时才去触发取消清空内
    WidgetsBinding.instance.addPostFrameCallback((_) => widget.controller.clear());
    setState(() {
      widget.isShowClean = false;
    });
    widget.fieldCallBack("");
  }
}
