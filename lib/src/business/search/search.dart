import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:titan/generated/i18n.dart';
import 'package:titan/src/basic/bloc/bloc_provider.dart';
import 'package:titan/src/bloc/app_bloc.dart';
import 'package:titan/src/bloc/search_history_bloc.dart';
import 'package:titan/src/consts/consts.dart';

class SearchPage extends StatefulWidget {
  final String searchText;

  SearchPage({this.searchText});

  @override
  State<StatefulWidget> createState() {
    return _SearchPageState();
  }
}

class _SearchPageState extends State<SearchPage> {
  TextEditingController _searchTextController = TextEditingController();

  bool _visibleCloseIcon = false;

  @override
  void initState() {
    _searchTextController.addListener(searchTextChangeListener);
    super.initState();
  }

  @override
  void dispose() {
    _searchTextController.dispose();
    super.dispose();
  }

  void searchTextChangeListener() {
    if (_searchTextController.text.length > 0) {
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
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Material(
              child: Container(
                  height: 50,
                  margin: EdgeInsets.only(left: 16, right: 16, top: 8),
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey[350])),
                  child: Row(children: <Widget>[
                    InkWell(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Icon(Icons.arrow_back_ios, color: Colors.grey[800]),
                      ),
                    ),
                    Expanded(
                        child: Padding(
                      padding: const EdgeInsets.only(left: 16),
                      child: TextField(
                          controller: _searchTextController,
                          autofocus: true,
                          decoration: InputDecoration(hintText: '输入搜索词 / 密文', border: InputBorder.none, hintStyle: TextStyle(color: Colors.grey)),
                          style: Theme.of(context).textTheme.body1),
                    )),
                    if (_visibleCloseIcon)
                      InkWell(
                        onTap: () {
                          _searchTextController.text = "";
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Icon(Icons.close, color: Colors.grey[800]),
                        ),
                      )
                  ])),
            ),
//          ListView.builder(itemBuilder: (BuildContext context, int index) {
//            return null;
//          })
          ],
        ),
      ),
    );
  }
}
