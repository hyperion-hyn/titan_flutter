import 'dart:async';
import 'dart:io';

import 'package:android_intent/android_intent.dart';
import 'package:app_settings/app_settings.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:rxdart/rxdart.dart';
import 'package:titan/generated/i18n.dart';
import 'package:titan/src/basic/utils/hex_color.dart';
import 'package:titan/src/business/home/contribution_page.dart';
import 'package:titan/src/business/position/bloc/bloc.dart';
import 'package:titan/src/business/wallet/service/wallet_service.dart';
import 'package:titan/src/plugins/titan_plugin.dart';
import 'package:titan/src/utils/utils.dart';
import 'package:titan/src/widget/jj_text.dart';
import '../wallet/wallet_create_new_account_page.dart';
import 'package:titan/src/business/wallet/wallet_import_account_page.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:titan/src/business/wallet/wallet_bloc/wallet_bloc.dart';
import 'package:titan/src/business/wallet/wallet_bloc/wallet_event.dart';
import 'package:titan/src/business/wallet/wallet_bloc/wallet_state.dart';
import 'package:titan/src/global.dart';
import '../wallet/wallet_manager/wallet_manager.dart';
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
  bool _isLoading = true;

//  PublishSubject<String> _filterSubject = PublishSubject<String>();
  List<String> _tagList = [];

  @override
  void initState() {
    _tagList.add("书店");
    _tagList.add("西饼店");
    _tagList.add("巧克力店");
    _tagList.add("布艺店");
    _tagList.add("健康食品店");
    _tagList.add("美甲店");

//    _searchTextController.addListener(searchTextChangeListener);

//    _positionBloc.add(SelectCategoryLoadingEvent());

    if (_searchFocusNode.hasFocus) {
      _searchFocusNode.unfocus();
    }

    super.initState();

    /*_filterSubject.debounceTime(Duration(seconds: 2)).listen((text) {
      handleSearch(text);
    });*/
  }

  void searchTextChangeListener() {
    String currentText = _searchTextController.text.trim();
    if (currentText.isNotEmpty) {
//      _filterSubject.sink.add(currentText);
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
          '选择类别',
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: IconThemeData(color: Colors.white),
        centerTitle: true,
        /*actions: <Widget>[
          InkWell(
            onTap: () {
              Navigator.pop(context,"");
            },
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              alignment: Alignment.centerRight,
              child: Text(
                '完成',
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),
          )
        ],*/
      ),
      body: _buildView(context),
    );
  }

  Widget _buildView(BuildContext context) {
    return BlocBuilder<PositionBloc, PositionState>(
      bloc: _positionBloc,
      builder: (BuildContext context, PositionState state) {
        if (state is InitialPositionState) {
          categoryList.clear();
//          _searchTextController.text = "";
          return _buildBody(state);
        } else if (state is SelectCategoryResultState) {
          _isLoading = false;
          categoryList.clear();
          categoryList.addAll(state.categoryList);

          return _buildBody(state);
        } else if (state is SelectCategoryLoadingState) {
          _isLoading = true;
//          setState(() {
//
//          });
          return _buildBody(state);
        } else if (state is SelectCategoryClearState) {
          categoryList.clear();
//          _searchTextController.text = "";
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

  @override
  void dispose() {
    _positionBloc.close();
//    _filterSubject.close();
    super.dispose();
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
        /*setState(() {
          selectCategory = categoryItem.title;
        });*/
      },
      child: Container(
        height: 41,
        child: Row(
//          mainAxisAlignment: MainAxisAlignment.left,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(left: 16),
              child: Text(
                categoryItem.title,
                style: TextStyle(color: HexColor("#333333"), fontSize: 16),
              ),
            ),
            /*Spacer(),
            Visibility(
              visible: selectCategory == categoryItem.title,
              child: Padding(
                padding: const EdgeInsets.only(right: 16),
                child: Icon(
                  Icons.check,
                  color: Colors.green,
                ),
              ),
            )*/
          ],
        ),
      ),
    );
  }

  Widget _buildBody(PositionState state) {
    return Container(
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[buildSearchBar(), Expanded(child: _buildBottomBody(state))]),
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
      return ListView.separated(
          itemBuilder: (context, index) {
            return _buildInfoContainer(categoryList[index]);
          },
          separatorBuilder: (context, index) {
            return _divider();
          },
          itemCount: categoryList.length);
    } else if (state is InitialPositionState || state is SelectCategoryClearState) {
      return Wrap(
          alignment: WrapAlignment.center,
          spacing: 10,
          runSpacing: 5,
          children: _tagList.map<Widget>((s) {
            return InkWell(
                onTap: () {
                  _searchTextController.text = s;
                  handleSearch(s);
                },
                child: Chip(
                  label: Text('$s'),
                ));
          }).toList());
    }
    return Container(
      width: 0.0,
      height: 0.0,
    );
  }

  Widget buildSearchBar() {
    double height = 43;
    return Container(
      color: Theme.of(context).primaryColor,
      height: height,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
            margin: EdgeInsets.only(left: 48, right: 48),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(height * 0.5)),
            height: 29,
            child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(17, 8, 11, 8),
                    child: Image.asset('res/drawable/ic_select_category_search_bar.png', width: 13, height: 13),
                  ),
                  JJText(
                    controller: _searchTextController,
                    fieldCallBack: (textStr) {
                      if (textStr.length == 0) {
                        _positionBloc.add(SelectCategoryClearEvent());
                      }
                      print("jjtext = " + textStr);
                    },
                  ),
                ])),
      ),
    );
  }

  void handleSearch(textOrPoi) async {
    if (textOrPoi is String) {
      textOrPoi = (textOrPoi as String).trim();
      if ((textOrPoi as String).isEmpty) {
        return;
      }

      _positionBloc.add(SelectCategoryResultEvent(searchText: textOrPoi));
    }
  }
}
