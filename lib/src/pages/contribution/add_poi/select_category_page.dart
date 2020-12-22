import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:titan/generated/l10n.dart';
import 'package:titan/src/basic/utils/hex_color.dart';
import 'package:titan/src/basic/widget/base_app_bar.dart';
import 'package:titan/src/basic/widget/base_state.dart';
import 'package:titan/src/components/setting/setting_component.dart';
import 'package:titan/src/components/wallet/wallet_component.dart';
import 'package:titan/src/pages/contribution/add_poi/bloc/bloc.dart';
import 'package:titan/src/pages/contribution/add_poi/model/category_item.dart';
import 'package:titan/src/style/titan_sytle.dart';
import 'package:titan/src/widget/all_page_state/all_page_state.dart';
import 'package:titan/src/widget/all_page_state/all_page_state_container.dart';
import 'package:titan/src/widget/custom_input_text.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SelectCategoryPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _SelectCategoryState();
  }
}

class _SelectCategoryState extends BaseState<SelectCategoryPage> {
  PositionBloc _positionBloc = PositionBloc();
  List<CategoryItem> categoryList = [];
  String selectCategory = "";
  TextEditingController _searchTextController = TextEditingController();
  FocusNode _searchFocusNode = FocusNode();
  CustomInputText inputText;
  List<String> _tagList = [];
  String address;
  String language;
  String _lastSearch;

  @override
  void onCreated() {
    address = WalletInheritedModel.of(context).activatedWallet.wallet.accounts[0].address;
    language = SettingInheritedModel.of(context).languageCode;
    _positionBloc.add(SelectCategoryInitEvent(address,language));
    super.onCreated();
  }

  @override
  void initState() {
    //print('[category] --> initState, $context');

    if (_searchFocusNode.hasFocus) {
      _searchFocusNode.unfocus();
    }

    inputText = CustomInputText(
      controller: _searchTextController,
      fieldCallBack: (textStr,{isForceSearch = false}) {
        if (textStr.length == 0) {
          _positionBloc.add(SelectCategoryClearEvent());
        } else {
          handleSearch(textStr,isForceSearch);
        }
        print("inputText = " + textStr);
      },
    );

    super.initState();

  }

  @override
  void dispose() {
    _positionBloc.close();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: BaseAppBar(
        baseTitle: S.of(context).select_category,
        backgroundColor: Colors.white,
      ),
      body: _buildView(context),
    );
  }

  Widget _buildView(BuildContext context) {
    return BlocBuilder<PositionBloc, AllPageState>(
      bloc: _positionBloc,
      builder: (BuildContext context, AllPageState state) {
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
          return _buildBody(state,isShowSearch: state.isShowSearch);
        } else if (state is SelectCategoryClearState) {
          categoryList.clear();
          return _buildBody(state);
        } else {
          return AllPageStateContainer(state,(){
            _positionBloc.add(SelectCategoryInitEvent(address,language));
          });
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
        if (_lastSearch.isNotEmpty) {
          categoryItem.title = _lastSearch +" / "+ categoryItem.title;
        }
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

  Widget _buildBody(PositionState state,{bool isShowSearch = true}) {
    return Container(
      color: Colors.white,
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            if(isShowSearch) buildSearchBar(),
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
              S.of(context).no_category,
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
      return SingleChildScrollView(
        child: Padding(
              padding: const EdgeInsets.only(top: 28.0, left: 8, right: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(bottom: 20,left: 10),
                    child: Text(S.of(context).hot_search,style: TextStyles.textC777S16,),
                  ),
                  Wrap(
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
                              handleSearch(str,true);
                            },
                            child: Chip(
                              label: Text(
                                '$str',
                                style: TextStyle(fontSize: 13),
                              ),
                            ));
                      }).toList()),
                ],
              ),
            ),
      );
    }
    return Container(
      width: 0.0,
      height: 0.0,
    );
  }

  Widget buildSearchBar() {
//    double height = 43;
    double height = 62;
    return Container(
      //color: Theme.of(context).primaryColor,
      height: height,
      child: Center(
        child: Container(
            margin: EdgeInsets.only(left: 32, right: 32, bottom: 8,top: 8),
            decoration: BoxDecoration(
                color: Color(0xfff2f2f2),
                borderRadius: BorderRadius.circular(height * 0.5)),
//            height: 29,
            height: 46,
            child: inputText),
      ),
    );
  }


  void handleSearch(String textOrPoi,bool isForceSearch) {
    if (_lastSearch == textOrPoi && !isForceSearch) {
      return;
    }

    if (textOrPoi is String) {
      textOrPoi = (textOrPoi as String).trim();
      if ((textOrPoi as String).isEmpty) {
        return;
      }

      _positionBloc.add(SelectCategoryLoadingEvent());
      _positionBloc.add(SelectCategoryResultEvent(address,language,searchText: textOrPoi));
      _lastSearch = textOrPoi;
    }
  }
}
