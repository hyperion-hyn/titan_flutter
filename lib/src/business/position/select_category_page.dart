import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:titan/generated/i18n.dart';
import 'package:titan/src/basic/utils/hex_color.dart';
import 'package:titan/src/business/position/bloc/bloc.dart';
import 'package:titan/src/style/titan_sytle.dart';
import 'package:titan/src/widget/custom_input_text.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'model/category_item.dart';

class SelectCategoryPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _SelectCategoryState();
  }
}

class _SelectCategoryState extends State<SelectCategoryPage> {
  PositionBloc _positionBloc = PositionBloc();
  List<CategoryItem> categoryList = [];
  String selectCategory = "";
  TextEditingController _searchTextController = TextEditingController();
  FocusNode _searchFocusNode = FocusNode();
  bool _visibleCloseIcon = false;
  CustomInputText inputText;
  List<String> _tagList = [];

  @override
  void initState() {
    //print('[category] --> initState, $context');

    if (_searchFocusNode.hasFocus) {
      _searchFocusNode.unfocus();
    }

    inputText = CustomInputText(
      controller: _searchTextController,
      fieldCallBack: (textStr) {
        if (textStr.length == 0) {
          _positionBloc.add(SelectCategoryClearEvent());
        } else {
          handleSearch(textStr);
        }
        print("inputText = " + textStr);
      },
    );

    super.initState();

    _positionBloc.add(SelectCategoryInitEvent());

  }

  @override
  void dispose() {
    _positionBloc.close();
    super.dispose();
  }

  void searchTextChangeListener() {
    String currentText = _searchTextController.text.trim();
    if (currentText.isNotEmpty) {
      if (!_visibleCloseIcon) {
        setState(() {
          _visibleCloseIcon = true;
        });
      }
    } else {
      if (_visibleCloseIcon) {
        setState(() {
          _visibleCloseIcon = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: Text(
          S.of(context).select_category,
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: IconThemeData(color: Colors.white),
        centerTitle: true,
      ),
      body: _buildView(context),
    );
  }

  Widget _buildView(BuildContext context) {
    return BlocBuilder<PositionBloc, PositionState>(
      bloc: _positionBloc,
      builder: (BuildContext context, PositionState state) {
        print('state: ${state}');

        if (state is InitialPositionState) {
          categoryList.clear();
//          return _buildBody(state);
          return _buildBody(state);
        } else if (state is SelectCategoryInitState) {
          _tagList.clear();
          _tagList = state.categoryList.map((categoryItem){
            return categoryItem.title;
          }).toList();
//          categoryList.clear();
//          categoryList.addAll(state.categoryList);

          print("tagList ${_tagList[0]}");
          return _buildBody(state);
        } else if (state is SelectCategoryResultState) {
          categoryList.clear();
          categoryList.addAll(state.categoryList);

          return _buildBody(state);
        } else if (state is SelectCategoryLoadingState) {
          return _buildBody(state);
        } else if (state is SelectCategoryClearState) {
          categoryList.clear();
          return _buildBody(state);
        } else {
          return Container(
            width: 0.0,
            height: 0.0,
          );
        }
      },
    );
  }

  Widget _divider() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Divider(
        height: 1.0,
        color: HexColor('#D7D7D7'),
      ),
    );
  }

  Widget _buildInfoContainer(CategoryItem categoryItem) {
    return InkWell(
      onTap: () {
        Navigator.pop(context, categoryItem);
      },
      child: Container(
        height: 41,
        child: Row(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(left: 16),
              child: Text(
                categoryItem.title,
                style: TextStyle(color: HexColor("#333333"), fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(PositionState state) {
    return Container(
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            buildSearchBar(),
            Expanded(child: _buildBottomBody(state))
          ]),
    );
  }

  Widget _buildBottomBody(PositionState state) {
    if (state is SelectCategoryLoadingState) {
      return Center(
        child: SizedBox(
          height: 40,
          width: 40,
          child: CircularProgressIndicator(
            strokeWidth: 3,
          ),
        ),
      );
    } else if (state is SelectCategoryResultState) {
      if(categoryList.length == 0){
        return Container(
          child: Center(
            child: Text(
              "暂无此类别",
              style: TextStyles.textC777S16,
            ),
          ),
        );
      }else{
        return ListView.separated(
            itemBuilder: (context, index) {
              return _buildInfoContainer(categoryList[index]);
            },
            separatorBuilder: (context, index) {
              return _divider();
            },
            itemCount: categoryList.length);
      }
    } else if (state is InitialPositionState ||
        state is SelectCategoryClearState ||
        state is SelectCategoryInitState) {
      return Padding(
        padding: const EdgeInsets.only(top: 48.0),
        child: Wrap(
            alignment: WrapAlignment.center,
            spacing: 10,
            runSpacing: 5,
            children: _tagList.map<Widget>((str) {
              return InkWell(
                  onTap: () {
//                    _searchTextController.text = str;
                    _searchTextController.value = TextEditingValue(
                        // 设置内容
                        text: str,
                        // 保持光标在最后
                        selection: TextSelection.fromPosition(TextPosition(
                            affinity: TextAffinity.downstream,
                            offset: str.length)));
                    handleSearch(str);
                  },
                  child: Chip(
                    label: Text(
                      '$str',
                      style: TextStyle(fontSize: 13),
                    ),
                  ));
            }).toList()),
      );
    }
    return Container(
      width: 0.0,
      height: 0.0,
    );
  }

  Widget buildSearchBar() {
//    double height = 43;
    double height = 50;
    return Container(
      color: Theme.of(context).primaryColor,
      height: height,
      child: Center(
        child: Container(
            margin: EdgeInsets.only(left: 48, right: 48),
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(height * 0.5)),
//            height: 29,
            height: 40,
            child: inputText),
      ),
    );
  }

  String _lastSearch;

  void handleSearch(textOrPoi) {
    if (_lastSearch == textOrPoi) {
      return;
    }

    if (textOrPoi is String) {
      textOrPoi = (textOrPoi as String).trim();
      if ((textOrPoi as String).isEmpty) {
        return;
      }

      _positionBloc.add(SelectCategoryLoadingEvent());
      _positionBloc.add(SelectCategoryResultEvent(searchText: textOrPoi));
      _lastSearch = textOrPoi;
    }
  }
}
