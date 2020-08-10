import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_pickers/image_pickers.dart';
import 'package:mapbox_gl/mapbox_gl.dart';
import 'package:rxdart/rxdart.dart';
import 'package:titan/generated/l10n.dart';
import 'package:titan/src/basic/utils/hex_color.dart';
import 'package:titan/src/basic/widget/base_state.dart';
import 'package:titan/src/components/setting/setting_component.dart';
import 'package:titan/src/components/wallet/wallet_component.dart';
import 'package:titan/src/config/application.dart';
import 'package:titan/src/config/consts.dart';
import 'package:titan/src/pages/contribution/add_poi/bloc/bloc.dart';
import 'package:titan/src/pages/node/widget/custom_stepper.dart';
import 'package:titan/src/pages/webview/webview.dart';
import 'package:titan/src/routes/routes.dart';
import 'package:titan/src/style/titan_sytle.dart';
import 'package:titan/src/utils/log_util.dart';
import 'package:titan/src/utils/utile_ui.dart';
import 'package:titan/src/utils/utils.dart';
import 'package:titan/src/widget/all_page_state/all_page_state.dart';
import 'package:titan/src/widget/all_page_state/all_page_state_container.dart';
import 'package:titan/src/widget/grouped_buttons/src/radio_button_group.dart';
import 'package:titan/src/widget/load_data_widget.dart';
import 'package:titan/src/widget/loading_button/click_oval_button.dart';
import '../add_poi/position_finish_page.dart';
import '../../../data/entity/poi/user_contribution_poi.dart';

class VerifyPoiPageV3 extends StatefulWidget {
  final LatLng userPosition;

  VerifyPoiPageV3({this.userPosition});

  @override
  State<StatefulWidget> createState() {
    return _VerifyPoiPageV3State();
  }
}

class _VerifyPoiPageV3State extends BaseState<VerifyPoiPageV3> {
  PositionBloc _positionBloc = PositionBloc();

  var _addMarkerSubject = PublishSubject<dynamic>();
  PublishSubject<int> _filterSubject = PublishSubject<int>();

  MapboxMapController _mapController;

  UserContributionPoi _confirmPoiItem;

  String _language;
  String _address;
  String _answerOfFirstStep = "";

  int _currentIndex = 0;
  int _sendConfirmCount = 0;

  bool _isSendConfirm = false;
  bool _isEnableNext = false;
  bool _isLoadedMap = false;

  List<String> _titles = [
    "名称",
    "类别",
    "位置",
  ];

  List<String> _questionList = [
    "",
    "",
    "",
    "",
  ];
  String _currentAnswer;
  List<String> _answerExistList = ["存在", "不存在"];
  List<String> _answerTrueList = ["是", "否"];
  List<String> _answerRadiusList = ["偏差小于50米", "偏差小于100米", "偏差小于200米", "偏差较大"]; // 忽略判断
  List<String> _answerRegulationList = ["符合地方法规", "违反地方法规", "不确定"];
  List<String> _answerDefaultList = ["是", "否", "不确定"];
  List<String> _answerList = []; // 忽略判断

  List<Map<String, dynamic>> _answerDetailList = [];
  List<String> _answersLabel = [];

  List<Map<String, dynamic>> _imageAnswers = [];
  List<String> _imageAnswersLabel = [];

  bool _isKo = false;

  // super
  @override
  void onCreated() {
    _language = SettingInheritedModel.of(context).languageCode;
    _address = WalletInheritedModel.of(context).activatedWallet.wallet.accounts[0].address;

    _titles.forEach((element) {
      _answersLabel.add("");
      _answerDetailList.add({});
    });
    _positionBloc.add(GetConfirmPoiDataEvent(widget.userPosition, _language, _address));

    _answerExistList = [S.of(context).exist, S.of(context).does_not_exist];
    _answerTrueList = [S.of(context).isolation_yes, S.of(context).isolation_no];
    _answerRadiusList = [
      S.of(context).deviation_less_than_50_meters,
      S.of(context).deviation_less_than_100_meters,
      S.of(context).deviation_less_than_200_meters,
      S.of(context).deviation_more_than_meters
    ]; // 忽略判断
    _answerRegulationList = [
      S.of(context).compliance_with_local_regulations,
      S.of(context).violation_of_local_regulations,
      S.of(context).uncertain
    ];
    _answerDefaultList = [S.of(context).isolation_yes, S.of(context).isolation_no, S.of(context).uncertain];

    var selectedLanguageModel = SettingInheritedModel.of(context, aspect: SettingAspect.language).languageModel;
    _isKo = selectedLanguageModel.locale.languageCode == "ko";
  }

  @override
  void initState() {
    _filterSubject.debounceTime(Duration(milliseconds: 500)).listen((count) async {
      if (_answerOfFirstStep == _answerExistList[0]) {
        var option = await _showConfirmAlertView() ?? false;
        if (option) {
          bool isExistFalse = false;

          for (var itemMap in _answerDetailList) {
            bool itemMapValue;
            itemMap.values.forEach((element) {
              if (element is bool) {
                itemMapValue = element;
                return;
              }
            });
            if (itemMapValue != null && !itemMapValue) {
              isExistFalse = true;
              break;
            }
          }

          var answer = isExistFalse ? 0 : 1;

          _isSendConfirm = true;
          _positionBloc.add(PostConfirmPoiDataEvent(answer, _confirmPoiItem, _address, detail: _answerDetailList));
        }
      } else if (_answerOfFirstStep == _answerExistList[1]) {
        var option = await _showExistAlertView() ?? false;
        if (option) {
          _isSendConfirm = true;
          _positionBloc.add(PostConfirmPoiDataEvent(0, _confirmPoiItem, _address, detail: _answerDetailList));
        }
      }
    });

    _positionBloc.listen((state) {
      if (state is PostConfirmPoiDataResultSuccessState) {

        Application.router.navigateTo(
            context,
            Routes.contribute_position_finish +
                '?entryRouteName=${Uri.encodeComponent(Routes.contribute_tasks_list)}&pageType=${FinishAddPositionPage.FINISH_PAGE_TYPE_CONFIRM}');
      } else if (state is GetConfirmPoiDataResultSuccessState) {
        if (state.confirmPoiItem?.name == null) {
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: Text(S.of(context).no_verifiable_poi_around_hint),
                actions: <Widget>[
                  FlatButton(
                      onPressed: () {

                        Navigator.of(context)..pop()..pop();
                      },
                      child: Text(S.of(context).confirm))
                ],
              );
            },
          );
        }
      }
    });

    _addMarkerSubject.debounceTime(Duration(milliseconds: 500)).listen((_) {
      var latlng = LatLng(_confirmPoiItem.location.coordinates[1], _confirmPoiItem.location.coordinates[0]);
      _mapController?.addSymbol(
        SymbolOptions(
          textField: _confirmPoiItem.name ?? "",
          textOffset: Offset(0, 1),
          textColor: "#333333",
          textSize: 16,
          geometry: latlng,
          iconImage: "hyn_marker_big",
          iconAnchor: "bottom",
          //iconOffset: Offset(0.0, 3.0),
        ),
      );
      _mapController?.animateCamera(CameraUpdate.newLatLng(latlng));
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<PositionBloc, AllPageState>(
          bloc: _positionBloc,
          builder: (BuildContext context, AllPageState state) {
            if (state is GetConfirmPoiDataLoadingState) {
              return LoadDataWidget(
                isLoading: true,
              );
            } else if (state is GetConfirmPoiDataResultSuccessState) {
              _confirmPoiItem = state.confirmPoiItem;

              if (_confirmPoiItem?.name == null) {
                return Scaffold(
                  appBar: AppBar(
                    elevation: 0,
                    title: Text(
                      S.of(context).check_poi_item_title,
                      style: TextStyle(color: Colors.white),
                    ),
                    iconTheme: IconThemeData(color: Colors.white),
                    centerTitle: true,
                  ),
                  body: Center(
                    child: Container(
                      child: Text(S.of(context).no_verifiable_poi_around_hint),
                    ),
                  ),
                );
              } else {
                _titles = [];

                /*

                _confirmPoiItem.category = "美食-中国餐";
                _confirmPoiItem.images = [
                  "https://www.baidu.com/",
                  "https://pics3.baidu.com/feed/cc11728b4710b9122238ede90bbd1405934522f7.jpeg?token=7aca45fcd4779b15793c037001d537c7",
                  "https://pics2.baidu.com/feed/a50f4bfbfbedab648a35c27f3e7647c578311e95.jpeg?token=9d23b9631d027a122299c5f698d88a48",
                  "https://pics3.baidu.com/feed/cc11728b4710b9122238ede90bbd1405934522f7.jpeg?token=7aca45fcd4779b15793c037001d537c7",
                ];
                _confirmPoiItem.workTime = "周一-周五 08:23-22:02";
                _confirmPoiItem.phone = "020-1321343";
                _confirmPoiItem.website = "https://www.xxx.com";
              */

                if (_confirmPoiItem.name.isNotEmpty) {
                  _titles.add(S.of(context).name);
                }

                if (_confirmPoiItem.category.isNotEmpty) {
                  _titles.add(S.of(context).category);
                }

                if (_confirmPoiItem.address.isNotEmpty) {
                  _titles.add(S.of(context).address);
                }

                if (_confirmPoiItem.images != null && _confirmPoiItem.images.isNotEmpty) {
                  _titles.add(S.of(context).photo);

                  _imageAnswers = [];
                  _imageAnswersLabel = [];

                  _confirmPoiItem.images.forEach((element) {
                    _imageAnswers.add({});
                    _imageAnswersLabel.add("");
                  });
                }

                if (_confirmPoiItem.workTime.isNotEmpty) {
                  _titles.add(S.of(context).work_time);
                }

                //_confirmPoiItem.phone = "13250348525";
                if (_confirmPoiItem.phone.isNotEmpty) {
                  _titles.add(S.of(context).telphone);
                }

                if (_confirmPoiItem.website.isNotEmpty) {
                  _titles.add(S.of(context).website);
                }

                _titles.add(S.of(context).regulation);

                _answersLabel = [];
                _answerDetailList = [];
                _titles.forEach((element) {
                  _answersLabel.add("");
                  _answerDetailList.add({});
                });

                _updateUI(isPost: false);

                addMarkerAndMoveToPoi();

                return _buildListBody();
              }
            } else if (state is GetConfirmPoiDataResultFailState) {
              UiUtil.toast(S.of(context).failed_to_request_data_to_be_verified_error_code_toast);

              return Scaffold(
                appBar: AppBar(
                  elevation: 0,
                  title: Text(
                    S.of(context).check_poi_item_title,
                    style: TextStyle(color: Colors.white),
                  ),
                  iconTheme: IconThemeData(color: Colors.white),
                  centerTitle: true,
                ),
                body: AllPageStateContainer(LoadFailState(), () {
                  _positionBloc.add(GetConfirmPoiDataEvent(widget.userPosition, _language, _address));
                }),
              );
            } else if ((state is UpdateConfirmPoiDataPageState) || (state is PostConfirmPoiDataLoadingState)) {
              return _buildListBody();
            } else if (state is PostConfirmPoiDataResultFailState) {
              _isSendConfirm = false;
              UiUtil.toast(S.of(context).failed_to_post_confirm_data_to_be_verified_error_code);
              return _buildListBody();
            } else {
              _isSendConfirm = false;

              if (state is LoadFailState) {
                UiUtil.toast(S.of(context).network_error_please_check_whether_the_network_connection_normal_toast);
              }

              if (_confirmPoiItem?.name == null || _confirmPoiItem == null) {
                return Scaffold(
                  appBar: AppBar(
                    elevation: 0,
                    title: Text(
                      S.of(context).check_poi_item_title,
                      style: TextStyle(color: Colors.white),
                    ),
                    iconTheme: IconThemeData(color: Colors.white),
                    centerTitle: true,
                  ),
                  body: AllPageStateContainer(LoadFailState(), () {
                    _positionBloc.add(GetConfirmPoiDataEvent(widget.userPosition, _language, _address));
                  }),
                );
              } else {
                return _buildListBody();
              }
            }
          }),
    );
  }

  @override
  void dispose() {
    _positionBloc.close();
    _addMarkerSubject.close();
    _filterSubject.close();

    super.dispose();
  }

  // UI
  Widget _buildListBody() {
    return Stack(
      children: <Widget>[
        Column(children: <Widget>[
          _mapView(),
          Visibility(visible: _isLoadedMap, child: _headerView()),
          Visibility(
            visible: _isLoadedMap,
            child: Expanded(
              child: Container(
                color: Colors.white,
                child: ListView(
                  padding: EdgeInsets.only(bottom: 16),
                  children: <Widget>[
                    _titles[_currentIndex] == S.of(context).photo ? _imageView() : _bodyView(),
                  ],
                ),
              ),
            ),
          ),
          Visibility(visible: _isLoadedMap, child: _bottomView()),
          Visibility(
            visible: !_isLoadedMap,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(14, 64, 14, 12),
              child: LoadDataWidget(
                isLoading: true,
              ),
            ),
          ),
        ]),
      ],
    );
  }

  Widget _mapView() {
    var style;
    if (SettingInheritedModel.of(context).areaModel.isChinaMainland) {
      style = Const.kWhiteWithoutMapStyleCn;
    } else {
      style = Const.kWhiteWithoutMapStyle;
    }

    var languageCode = Localizations.localeOf(context).languageCode;

    return Stack(
      children: <Widget>[
        SizedBox(
          height: 330,
          child: MapboxMap(
            compassEnabled: false,
            initialCameraPosition: CameraPosition(
              target: Application.recentlyLocation,
              zoom: 16,
            ),
            styleString: style,
            onMapCreated: (controller) {
              Future.delayed(Duration(milliseconds: 500)).then((value) {
                onStyleLoaded(controller);
              });
            },
            onStyleLoadedCallback: () {
              _isLoadedMap = true;
              _positionBloc.add(UpdateConfirmPoiDataPageEvent());
            },
            myLocationTrackingMode: MyLocationTrackingMode.None,
            rotateGesturesEnabled: false,
            tiltGesturesEnabled: false,
            enableLogo: false,
            enableAttribution: false,
            minMaxZoomPreference: MinMaxZoomPreference(1.1, 21.0),
            myLocationEnabled: false,
            languageCode: languageCode,
          ),
        ),
        Positioned(
          top: 48,
          right: 18,
          child: InkWell(
            onTap: () {
              Navigator.of(context).pop();
            },
            child: Image.asset(
              "res/drawable/verify_position_close.png",
              width: 16,
              height: 16,
            ),
          ),
        )
      ],
    );
  }

  Widget _headerView() {
    return Container(
      decoration: BoxDecoration(
//        borderRadius: BorderRadius.only(topLeft: Radius.circular(50), topRight: Radius.circular(50)),
        color: Colors.white,
//          boxShadow: [
//            BoxShadow(
//              color: Colors.black26,
//              blurRadius: 20.0,
//            ),
//          ]
      ),
      child: Padding(
        padding: EdgeInsets.only(left: 15, right: 15, top: 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  S.of(context).verification_location,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ],
            ),
            _customStepperWidget(),
          ],
        ),
      ),
    );
  }

  Widget _bodyView() {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(left: 30, right: 15, top: 8),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: RichText(
                    text: TextSpan(
                      text: _questionList[0],
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.normal, color: HexColor("#333333")),
                      children: [
                        TextSpan(
                          text: _questionList[1],
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: HexColor("#333333")),
                        ),
                        TextSpan(
                          text: _questionList[2],
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.normal, color: HexColor("#333333")),
                        )
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (_questionList.length > 3 && _questionList[3].isNotEmpty)
            InkWell(
              onTap: () {
                if (_titles[_currentIndex] == S.of(context).website) {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => WebViewContainer(
                                initUrl: _questionList[3],
                                title: S.of(context).check_poi_item_title,
                              )));
                } else if (_titles[_currentIndex] == S.of(context).telphone) {
                  launchUrl("tel:" + _questionList[3]);
                }
              },
              child: Padding(
                padding: EdgeInsets.only(left: 30, right: 30, top: 8),
                child: Row(
                  children: <Widget>[
                    if (_titles[_currentIndex] == S.of(context).position)
                      Image.asset(
                        "res/drawable/check_in_location.png",
                        width: 12,
                        height: 12,
                      ),
                    if (_titles[_currentIndex] == S.of(context).position)
                      SizedBox(
                        width: 6,
                      ),
                    Expanded(
                      child: Text(
                        _questionList[3],
                        style: TextStyle(
                            fontSize: 14,
                            color: _titles[_currentIndex] == S.of(context).website ||
                                    _titles[_currentIndex] == S.of(context).telphone
                                ? HexColor("#1F81FF")
                                : HexColor("#999999"),
                            height: 1.5),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          Padding(
            padding: EdgeInsets.only(left: 18, right: 15, top: 8),
            child: RadioButtonGroup(
              key: GlobalKey(),
              picked: _currentAnswer,
              labels: _answerList,
              labelStyle: TextStyle(
                color: DefaultColors.color333,
                fontWeight: FontWeight.w400,
                fontSize: 14,
              ),
              leftMargin: 0,
              rowHeight: 40,
              activeColor: Theme.of(context).primaryColor,
              onChange: (String label, int index) {
                var title = _titles[_currentIndex];
                String key = "";
                bool value = false;
                if (title == S.of(context).name) {
                  key = "name";
                  value = label == _answerExistList[0];

                  _answerOfFirstStep = label;
                } else if (title == S.of(context).category) {
                  key = "category";
                  value = label == _answerTrueList[0];
                } else if (title == S.of(context).address) {
                  key = "position";
                  value = true;
                } else if (title == S.of(context).photo) {
                  // --> 转imageView判断
                  // ...
                } else if (title == S.of(context).work_time) {
                  key = "workTime";
                  value = label == _answerDefaultList[0];
                } else if (title == S.of(context).telphone) {
                  key = "phone";
                  value = label == _answerDefaultList[0];
                } else if (title == S.of(context).website) {
                  key = "website";
                  value = label == _answerDefaultList[0];
                } else if (title == S.of(context).regulation) {
                  key = "regulation";
                  value = label == _answerRegulationList[0];
                }
                Map<String, dynamic> detailMap = {"key": key, "value": value};
                _answerDetailList[_currentIndex] = detailMap;
              },
              onSelected: (String label) {
                _currentAnswer = label;
                _answersLabel[_currentIndex] = label;

                _isEnableNext = true;

                _positionBloc.add(UpdateConfirmPoiDataPageEvent());
              },
            ),
          ),
          if (S.of(context).name == _titles[_currentIndex])
            InkWell(
              onTap: () async {
                var option = await _showIgnoreAlertView();
                if (option) {
                  _currentIndex = 0;
                  _isEnableNext = false;
                  _isSendConfirm = false;
                  _positionBloc
                      .add(GetConfirmPoiDataEvent(widget.userPosition, _language, _address, id: _confirmPoiItem.id));
                }
              },
              child: Padding(
                padding: EdgeInsets.only(left: 30, right: 30, top: 8),
                child: Text(
                  S.of(context).uncertain + "，" + S.of(context).another,
                  style: TextStyle(color: HexColor("#1F81FF"), fontSize: 14),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _imageView() {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(left: 30, right: 15, top: 18),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: RichText(
                    text: TextSpan(
                      text: _questionList[0],
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.normal, color: HexColor("#333333")),
                    ),
                  ),
                ),
              ],
            ),
          ),
          ListView.separated(
              physics: NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemBuilder: (context, value) {
                var imageUrl = _confirmPoiItem?.images[value];
                var imageAnswer = "";
                if (_imageAnswersLabel.isNotEmpty && _imageAnswersLabel.length > value) {
                  imageAnswer = _imageAnswersLabel[value];
                }
                return Padding(
                  padding: const EdgeInsets.only(left: 30),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8.0),
                        child: InkWell(
                          onTap: () {
                            ImagePickers.previewImages(_confirmPoiItem.images, value);
                          },
                          child: FadeInImage.assetNetwork(
                            placeholder: 'res/drawable/img_placeholder.jpg',
                            image: imageUrl.isNotEmpty ? imageUrl : "",
                            fit: BoxFit.cover,
                            width: 160,
                            height: 96,
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(left: _isKo?0:8, right: 15, top: 8),
                        child: RadioButtonGroup(
                          key: GlobalKey(),
                          picked: imageAnswer,
                          labels: _answerDefaultList,
                          labelStyle: TextStyle(
                            color: DefaultColors.color333,
                            fontWeight: FontWeight.w400,
                            fontSize: 14,
                          ),
                          leftMargin: 0,
                          rowHeight: 36,
                          activeColor: Theme.of(context).primaryColor,
                          onChange: (String label, int index) {
                            Map<String, dynamic> imageDetailMap = {
                              "key": "image$value",
                              "value": label == _answerDefaultList[0],
                            };
                            _imageAnswers[value] = imageDetailMap;
                          },
                          onSelected: (String label) {
                            _imageAnswersLabel[value] = label;

                            // imageDict
                            var isExistFalse = false;
                            for (var item in _imageAnswersLabel) {
                              if (item == _answerDefaultList[1]) {
                                isExistFalse = true;
                                break;
                              }
                            }
                            Map<String, dynamic> detailMap = {
                              "key": "image",
                              "value": !isExistFalse,
                            };
                            _answerDetailList[_currentIndex] = detailMap;

                            // 图片任务
                            var isFinishImageTask = true;
                            for (var item in _imageAnswersLabel) {
                              if (item.isEmpty) {
                                isFinishImageTask = false;
                                break;
                              }
                            }

                            if (isFinishImageTask) {
                              _isEnableNext = true;

                              _answersLabel[_currentIndex] = label;

                              _positionBloc.add(UpdateConfirmPoiDataPageEvent());
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                );
              },
              separatorBuilder: (context, index) {
                return Container(
                  height: 8,
                );
              },
              itemCount: _confirmPoiItem.images.length),
        ],
      ),
    );
  }

  Widget _bottomView() {
    var lastIndex = _titles.length - 1;

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          if (_currentIndex > 0)
            InkWell(
              onTap: () {
                _currentIndex -= 1;
                if (_currentIndex <= 0) {
                  _currentIndex = 0;
                }

                _updateUI();
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 12),
                child: Text(
                  S.of(context).back,
                  style: TextStyle(color: HexColor("#1F81FF"), fontSize: 14),
                ),
              ),
            ),
          SizedBox(
            height: 38,
            width: 180,
            child: FlatButton(
              color: _isEnableNext ? Theme.of(context).primaryColor : HexColor("#DEDEDE"),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              onPressed: () async {
                if (!_isEnableNext) {
                  //UiUtil.toast("请先完成当前任务");
                  return;
                }

                if (_currentIndex == lastIndex || _answerOfFirstStep != _answerExistList[0]) {
                  if (!_isSendConfirm) {
                    _sendConfirmCount += 1;
                    _filterSubject.sink.add(_sendConfirmCount);
                  }
                } else {
                  _currentIndex += 1;
                  if (_currentIndex > lastIndex) {
                    _currentIndex = lastIndex;
                  }
                  _updateUI();
                }
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                      (_currentIndex == lastIndex || _answerOfFirstStep != _answerExistList[0])
                          ? S.of(context).submit
                          : S.of(context).next,
                      style: TextStyle(fontSize: 16, color: Colors.white)),
                  Visibility(
                      visible: _isSendConfirm,
                      child: SizedBox(
                        width: 25,
                      )),
                  Visibility(
                    visible: _isSendConfirm,
                    child: SizedBox(
                      height: 15,
                      width: 15,
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        strokeWidth: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
              //style: TextStyles.textC906b00S13),
            ),
          ),
        ],
      ),
    );
  }

  Widget _customStepperWidget() {
    return Container(
      height: 80,
      child: CustomStepper(
        currentStepProgress: 1,
        currentStep: _currentIndex,
        topMargin: 0,
        steps: _titles.map(
          (title) {
            return CustomStep(
              title: Text(
                title,
                style: TextStyle(fontSize: 12, color: HexColor("#999999"), fontWeight: FontWeight.normal),
              ),
              content: Container(),
              isActive: true,
            );
          },
        ).toList(),
      ),
    );
  }

  void addMarkerAndMoveToPoi() {
    if (_mapController != null && _confirmPoiItem?.name != null) {
      _addMarkerSubject.sink.add(1);
    }
  }

  void onStyleLoaded(MapboxMapController controller) {
    _mapController = controller;
    addMarkerAndMoveToPoi();
  }

/*
  "category": "类别",
  "postal_code": "邮编",
  "phone_number": "电话",
  "website": "网址",
  "work_time": "工作时间",
  "category_cannot_be_empty_hint": "请选择地点类别",
  "take_pictures_must_not_be_empty_hint": "请添加地点现场照片",
  "poi_upload_protocol_not_accepted_hint": "请接受地点上传协议",
  "upload_protocol": "上传协议",
  "submit": "提交",
  "detail": "详情",
  "details_of_street": "街道详情",
  "house_number": "门牌号码",
  "please_add_streets_hint": "请输入街道",
  "please_enter_door_number_hint": "请输入门牌号码",
  "please_enter_postal_code": "请输入邮政编码",
  "click_auto_get_hint": "点击自动获取",
  "scene_photographed": "现场拍照",
  "please_select_category_hint": "请选择地点类别",
  "please_add_business_hours_hint": "请添加营业时间",
  "add_failed_hint": "添加失败!",
  "name": "名称",
  "place_name_cannot_
  */

  void _updateUI({bool isPost = true}) {
    var title = _titles[_currentIndex];
    if (title == S.of(context).name) {
      _questionList = [S.of(context).map_in_title, "  ${_confirmPoiItem.name}  ", S.of(context).map_in_exist_subtitle];
      _answerList = _answerExistList;
    } else if (title == S.of(context).category) {
      _questionList = [S.of(context).category_title, _confirmPoiItem.category, S.of(context).category_suffix_title];
      _answerList = _answerTrueList;
    } else if (title == S.of(context).address) {
      _questionList = [
        S.of(context).map_in_title,
        "  ${_confirmPoiItem.name}  ",
        S.of(context).map_in_subtitle,
        _confirmPoiItem.address
      ];
      _answerList = _answerRadiusList;
    } else if (title == S.of(context).photo) {
      _questionList = [S.of(context).image_toast_title, "", ""];
      _answerList = _answerDefaultList;
    } else if (title == S.of(context).work_time) {
      _questionList = [S.of(context).work_time_title, "", "", _confirmPoiItem.workTime];
      _answerList = _answerDefaultList;
    } else if (title == S.of(context).telphone) {
      _questionList = [S.of(context).telphone_title, "", "", _confirmPoiItem.phone];
      _answerList = _answerDefaultList;
    } else if (title == S.of(context).website) {
      _questionList = [S.of(context).website_title, "", "", _confirmPoiItem.website];
      _answerList = _answerDefaultList;
    } else if (title == S.of(context).regulation) {
      _questionList = [S.of(context).regulation_title, "", "", S.of(context).regulation_subtitle];
      _answerList = _answerRegulationList;
    }

    if (_answersLabel.isNotEmpty && _answersLabel.length > _currentIndex) {
      _currentAnswer = _answersLabel[_currentIndex];
    }

    _isEnableNext = _currentAnswer.isNotEmpty;

    if (isPost) {
      _positionBloc.add(UpdateConfirmPoiDataPageEvent());
    }
  }

  // alertView
  Future<bool> _showAlertView({String content, String detail, String confirmTitle = ""}) {
    return UiUtil.showAlertView(
      context,
      title: S.of(context).tips,
      actions: [
        FlatButton(
          onPressed: () {
            Navigator.pop(context, false);
          },
          child: Text(
            S.of(context).return_check,
            style: TextStyle(color: HexColor("#333333"), fontSize: 16),
          ),
        ),
        SizedBox(
          width: _isKo?10:20,
        ),
        ClickOvalButton(
          confirmTitle.isEmpty ? S.of(context).correct : confirmTitle,
          () {
            Navigator.pop(context, true);
          },
          width: 120,
          height: 38,
          fontSize: 16,
        ),
      ],
      content: content,
      detail: detail,
    );
  }

  Future<bool> _showExistAlertView() {
    return _showAlertView(
      content: S.of(context).exist_alert_view_content,
      detail: S.of(context).exist_alert_view_detail,
    );
  }

  Future<bool> _showConfirmAlertView() {
    return _showAlertView(
      content: S.of(context).confirm_alert_view_content,
      detail: S.of(context).confirm_alert_view_detail,
    );
  }

  Future<bool> _showIgnoreAlertView() {
    return _showAlertView(
      content: S.of(context).ignore_alert_view_content,
      detail: S.of(context).ignore_alert_view_detail,
      confirmTitle: S.of(context).another,
    );
  }
}
