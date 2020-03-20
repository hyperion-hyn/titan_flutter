import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rxdart/rxdart.dart';
import 'package:titan/generated/i18n.dart';

typedef void TextFieldCallBack(String content,{bool isForceSearch});

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
      this.text = "",
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

    print('[CustomInputText] ---> initState');
    widget.controller.addListener(searchTextChangeListener);
    _filterSubject.debounceTime(Duration(seconds: 2)).listen((text) {
      widget.fieldCallBack(text);
    });
  }

  @override
  void dispose() {
    print('[CustomInputText] ---> dispose');

    _filterSubject.close();
    super.dispose();
  }

  void searchTextChangeListener() {
    String currentText = widget.controller.text.trim();
    if(oldText != currentText){
      if (!_filterSubject.isClosed) {
      _filterSubject.sink.add(currentText);
      }
      oldText = currentText;
    }
    if (currentText.isNotEmpty) {
      if (mounted){
        setState(() {
          widget.isShowClean = true;
        });
      }
    } else {
      widget.fieldCallBack("");
      if (mounted){
        setState(() {
          widget.isShowClean = false;
        });
      }
    }
  }

  Future<Null> _focusNodeListener() async {
    if (_focusNode.hasFocus) {
      if (mounted){
        setState(() {
          widget.isShowClean = true;
        });
      }
    } else {
      if (mounted){
        setState(() {
          widget.isShowClean = false;
        });
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      // // 主轴方向（横向）对齐方式
      crossAxisAlignment: CrossAxisAlignment.center,
      // 交叉轴（竖直）对其方式
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
          child: Image.asset('res/drawable/ic_select_category_search_bar.png', width: 16, height: 16),
        ),
        Expanded(
          child: TextFormField(
            textInputAction: TextInputAction.search,
            onFieldSubmitted: (value){
              widget.fieldCallBack(value,isForceSearch: true);
            },
            controller: widget.controller,
            autofocus: false,
            style: TextStyle(fontSize: 14),
            onChanged: (value){
              searchTextChangeListener();
            },
            maxLines: 1,
            textAlign: TextAlign.left,
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: S.of(context).please_enter_category_keywords_hint,
              hintStyle: TextStyle(fontSize: 14, color: Color(0xff777777)),
            ),
            keyboardType: TextInputType.text,
          ),
        ),
        Container(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              widget.isShowClean
                  ? IconButton(
                icon: Image.asset(
                  'res/drawable/ic_select_category_search_bar_clear.png',
                  height: 16,
                  width: 16,
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
