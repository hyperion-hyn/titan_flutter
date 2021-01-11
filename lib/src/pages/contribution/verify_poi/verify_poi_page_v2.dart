import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_pickers/image_pickers.dart';
import 'package:mapbox_gl/mapbox_gl.dart';
import 'package:rxdart/rxdart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:titan/generated/l10n.dart';
import 'package:titan/src/basic/utils/hex_color.dart';
import 'package:titan/src/basic/widget/base_app_bar.dart';
import 'package:titan/src/basic/widget/base_state.dart';
import 'package:titan/src/components/account/account_component.dart';
import 'package:titan/src/components/account/bloc/bloc.dart';
import 'package:titan/src/components/setting/setting_component.dart';
import 'package:titan/src/components/wallet/wallet_component.dart';
import 'package:titan/src/config/application.dart';
import 'package:titan/src/config/consts.dart';
import 'package:titan/src/data/entity/poi/user_contribution_poi.dart';
import 'package:titan/src/pages/contribution/add_poi/bloc/bloc.dart';
import 'package:titan/src/pages/contribution/add_poi/position_finish_page.dart';
import 'package:titan/src/pages/contribution/add_poi/verify_position_page.dart';
import 'package:titan/src/pages/contribution/contribution_tasks_page.dart';
import 'package:titan/src/pages/contribution/signal_scan/vo/check_in_model.dart';
import 'package:titan/src/pages/mine/api/contributions_api.dart';
import 'package:titan/src/routes/routes.dart';
import 'package:titan/src/style/titan_sytle.dart';
import 'package:titan/src/utils/log_util.dart';
import 'package:titan/src/utils/utile_ui.dart';
import 'package:titan/src/widget/all_page_state/all_page_state.dart';
import 'package:titan/src/widget/all_page_state/all_page_state_container.dart';
import 'package:titan/src/widget/grouped_buttons/grouped_buttons.dart';
import 'package:titan/src/widget/grouped_buttons/src/grouped_buttons_orientation.dart';
import 'package:titan/src/widget/load_data_widget.dart';
import 'package:titan/src/widget/loading_button/click_oval_button.dart';

class VerifyPoiPageV2 extends StatefulWidget {
  final LatLng userPosition;

  VerifyPoiPageV2({this.userPosition});

  @override
  State<StatefulWidget> createState() {
    return _VerifyPoiPageV2State();
  }
}

class _VerifyPoiPageV2State extends BaseState<VerifyPoiPageV2> {
  PositionBloc _positionBloc = PositionBloc();

  PublishSubject<int> _filterSubject = PublishSubject<int>();
  var _addMarkerSubject = PublishSubject<dynamic>();

  MapboxMapController _mapController;

  UserContributionPois _contributionPois;
  UserContributionPoi _confirmPoiItem;

  //用户选择的答案，0：表示为假，1：表示为真
  List<String> _answersLabel = [];

  String _language;

  List<String> _isolationTextList = [];
  String _isolationText = "";
  ScrollController _scrollController = ScrollController();

  int _currentIndex = 0;
  int _sendConfirmCount = 0;

  bool _isSendConfirm = false;
  bool _isEnableNext = false;
  bool _isLoadedMap = false;

  // super
  @override
  void onCreated() {
    _language = SettingInheritedModel.of(context).languageCode;
    _positionBloc.add(GetConfirmPoiDataV2Event(widget.userPosition, _language));
  }

  @override
  void initState() {
    _filterSubject.debounceTime(Duration(milliseconds: 500)).listen((count) async {
      var option = await showConfirmDialog(
          context, S.of(context).please_confirm_answered_verification_question_truthfully_toast,
          title: S.of(context).post_my_check);
      if (option == true) {
        List<int> answers = [];
        // 用户答案信息, 0:假，1: 真，-1: 不确定
        _answersLabel.forEach((element) {
          if (element == S.of(context).isolation_yes) {
            answers.add(1);
          } else if (element == S.of(context).isolation_no) {
            answers.add(0);
          } else {
            answers.add(-1);
          }
        });
        _isSendConfirm = true;
        _positionBloc.add(PostConfirmPoiDataV2Event(answers, _contributionPois));
      }
    });

    _positionBloc.listen((state) {
      if (state is PostConfirmPoiDataV2ResultSuccessState) {
        print("PostConfirmPoiDataV2ResultSuccessState----1111");
        // _finishCheckIn(S.of(context).thank_you_for_contribute_data, []);

        _saveData();

        Application.router.navigateTo(
            context,
            Routes.contribute_position_finish +
                '?entryRouteName=${Uri.encodeComponent(Routes.contribute_tasks_list)}&pageType=${FinishAddPositionPage.FINISH_PAGE_TYPE_CONFIRM}');
      } else if (state is GetConfirmDataV2ResultSuccessState) {
        _contributionPois = state.userContributionPois;
        if (_contributionPois?.pois?.isEmpty ?? true) {
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: Text(S.of(context).no_verifiable_poi_around_hint),
                actions: <Widget>[
                  FlatButton(
                      onPressed: () {
                        // var checkInModel =
                        //     AccountInheritedModel.of(context, aspect: AccountAspect.checkIn).checkInModel;
                        // CheckInModelState confirmPoiState = checkInModel.detail.firstWhere((element) {
                        //   return element.action == ContributionTasksPage.confirmPOI;
                        // }).state;

                        _saveData();

                        Navigator.of(context)..pop()..pop();

                        // if (confirmPoiState.total == 0 || confirmPoiState == null) {
                        //   _finishCheckIn(S.of(context).thank_you_for_contribute_data, []);
                        // } else {
                        //   Navigator.of(context)..pop()..pop();
                        // }
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
      //print("[Verify] add, name:${confirmPoiItem.name}, latlng:$latlng");

      _mapController?.clearSymbols();
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
  void didChangeDependencies() {
    _setupData();
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        var isEnablePop = true;
        if (_isSendConfirm || _isSendCheckIn) {
          isEnablePop = false;
        }

        return isEnablePop;
      },
      child: Scaffold(
        appBar: BaseAppBar(
          baseTitle: S.of(context).check_poi_item_title,
          backgroundColor: Colors.white,
        ),
        body: _buildView(),
      ),
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


  void _setupData() {}

  Widget _buildView() {
    return BlocBuilder<PositionBloc, AllPageState>(
        bloc: _positionBloc,
        builder: (BuildContext context, AllPageState state) {
          if (state is GetConfirmDataV2LoadingState) {
            return LoadDataWidget(
              isLoading: true,
            );
          } else if (state is GetConfirmDataV2ResultSuccessState) {
            _contributionPois = state.userContributionPois;
            if (_contributionPois?.pois?.isEmpty ?? true) {
              return Center(
                child: Container(
                  child: Text(S.of(context).no_verifiable_poi_around_hint),
                ),
              );
            } else {
              _confirmPoiItem = _contributionPois.pois.first;
              _isolationTextList = [];
              _isolationTextList = [
                S.of(context).isolation_yes,
                S.of(context).isolation_no,
              ];

              if (!_confirmPoiItem.myself) {
                _isolationTextList.add(S.of(context).uncertain);
              }

              _contributionPois.pois.forEach((element) {
                _answersLabel.add("");
              });

              return _buildListBody();
            }
          } else if (state is GetConfirmDataV2ResultFailState) {
            UiUtil.toast(S.of(context).failed_to_request_data_to_be_verified_error_code_toast_func(state.code));

            return AllPageStateContainer(LoadFailState(), () {
              _positionBloc.add(GetConfirmPoiDataV2Event(widget.userPosition, _language));
            });
          } else if ((state is UpdateConfirmPoiDataPageState) || (state is PostConfirmPoiDataV2LoadingState)) {
            return _buildListBody();
          } else if (state is PostConfirmPoiDataV2ResultFailState) {
            _isSendConfirm = false;
            UiUtil.toast(S.of(context).failed_to_post_confirm_data_to_be_verified_error_code_toast(state.code));
            return _buildListBody();
          } else {
            _isSendConfirm = false;

            if (state is LoadFailState) {
              UiUtil.toast(S.of(context).network_error_please_check_whether_the_network_connection_normal_toast);
            }

            if (_confirmPoiItem?.name == null || _contributionPois.pois.isEmpty) {
              return AllPageStateContainer(LoadFailState(), () {
                _positionBloc.add(GetConfirmPoiDataV2Event(widget.userPosition, _language));
              });
            } else {
              return _buildListBody();
            }
          }
        });
  }

  Widget _buildListBody() {
    return Stack(
      children: <Widget>[
        SingleChildScrollView(
          controller: _scrollController,
          child: Container(
            height: MediaQuery.of(context).size.height - 88,
            color: Colors.white,
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
              _headerView(),
              _mapView(),
              _detailView(),
            ]),
          ),
        ),
        if (_isLoadedMap) Positioned(bottom: 0, left: 15, right: 15, child: _bottomView()),
      ],
    );
  }

  Widget _mapView() {
    var style;
    if (SettingInheritedModel.of(context)?.areaModel?.isChinaMainland ?? true) {
      style = Const.kWhiteWithoutMapStyleCn;
    } else {
      style = Const.kWhiteWithoutMapStyle;
    }
    var languageCode = Localizations.localeOf(context).languageCode;

    return Stack(
      children: <Widget>[
        InkWell(
          onTap: _pushPosition,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: SizedBox(
              height: 140,
              child: IgnorePointer(
                child: MapboxMap(
                  compassEnabled: false,
                  initialCameraPosition: CameraPosition(
                    target: _confirmPoiItem.latLng,
                    zoom: 16,
                  ),
                  styleString: style,
                  onMapCreated: (controller) {
                    Future.delayed(Duration(milliseconds: 500)).then((value) {
                      _onStyleLoaded(controller);
                    });
                  },
                  onStyleLoadedCallback: () {
                    _isLoadedMap = true;
                    _positionBloc.add(UpdateConfirmPoiDataPageEvent());
                  },
                  myLocationTrackingMode: MyLocationTrackingMode.None,
                  rotateGesturesEnabled: false,
                  zoomGesturesEnabled: false,
                  scrollGesturesEnabled: false,
                  tiltGesturesEnabled: false,
                  enableLogo: false,
                  enableAttribution: false,
                  minMaxZoomPreference: MinMaxZoomPreference(1.1, 21.0),
                  myLocationEnabled: false,
                  languageCode: languageCode,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _headerView() {
    return Container(
      margin: const EdgeInsets.fromLTRB(14, 18, 14, 16),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          RichText(
            text: TextSpan(
                text: _confirmPoiItem.name.isNotEmpty ? _confirmPoiItem.name : "",
                style: TextStyle(color: HexColor("#333333"), fontSize: 16, fontWeight: FontWeight.w500),
                children: [
                  TextSpan(
                    text: _confirmPoiItem.category.isNotEmpty ? _confirmPoiItem.category : "",
                    style: TextStyle(color: HexColor("#333333"), fontSize: 12, fontWeight: FontWeight.w500),
                  )
                ]),
          ),
          SizedBox(
            height: 8,
          ),
          InkWell(
            onTap: _pushPosition,
            child: Row(
              children: [
                Image.asset(
                  "res/drawable/check_in_location.png",
                  width: 12,
                  height: 12,
                ),
                SizedBox(
                  width: 6,
                ),
                Expanded(
                  child: Text(
                    _confirmPoiItem.address.isNotEmpty ? _confirmPoiItem.address : "",
                    style: TextStyle(color: HexColor("#777777"), fontSize: 13, fontWeight: FontWeight.normal),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _detailView() {
    if (!_isLoadedMap) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(14, 64, 14, 12),
        child: LoadDataWidget(
          isLoading: true,
        ),
      );
    }

    return Column(
      children: <Widget>[
        if (_confirmPoiItem.images != null) _buildPicList(_confirmPoiItem.images),
        Padding(
          padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
          child: Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  S.of(context).whether_above_picture_real_picture_of_the_place_toast,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: HexColor("#333333")),
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 32, left: 16, right: 16),
          child: Container(
            decoration: BoxDecoration(
                border: Border.all(color: HexColor("#DEDEDE"), width: 0.5),
                borderRadius: BorderRadius.all(Radius.circular(4))),
            child: RadioButtonGroup(
              key: GlobalKey(),
              orientation: GroupedButtonsOrientation.HORIZONTAL,
              picked: _isolationText,
              labels: _isolationTextList,
              leftMargin: 0,
              labelStyle: TextStyle(
                color: DefaultColors.color333,
                fontWeight: FontWeight.w400,
                fontSize: 16,
              ),
              activeColor: Theme.of(context).primaryColor,
              onChange: (String label, int index) {
                _answersLabel[_currentIndex] = label;
              },
              onSelected: (String label) {
                _isolationText = label;

                _isEnableNext = true;

                _positionBloc.add(UpdateConfirmPoiDataPageEvent());
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPicList(List<String> images) {
    var size = MediaQuery.of(context).size;
    var width = size.width - 14 * 2.0;
    var height = width * (200.0 / 347.0);

    return Container(
      padding: const EdgeInsets.only(top: 20),
      width: width,
      height: height,
      child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemBuilder: (context, index) {
            //print("[verify_poi] --> images:${images.length}, image:${images[index]}");

            return InkWell(
              onTap: () {
                ImagePickers.previewImages(images, index);
              },
              child: Container(
                width: width,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(3.0),
                  child: FadeInImage.assetNetwork(
                    placeholder: 'res/drawable/img_placeholder.jpg',
                    image: images[index],
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            );
          },
          itemCount: images.length),
    );
  }

  Widget _bottomView() {
    int length = 1;
    var lastIndex = 0;
    if (_contributionPois != null && _contributionPois.pois != null) {
      length = _contributionPois.pois.length;
      lastIndex = length - 1;
    }

    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                "${_currentIndex + 1}/${length}",
                style: TextStyle(color: HexColor("#333333"), fontSize: 16),
              )
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 30),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              if (_currentIndex > 0)
                InkWell(
                  onTap: () {
                    print("[verify] 返回");

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
                width: 200,
                child: FlatButton(
                  color: _isEnableNext ? Theme.of(context).primaryColor : HexColor("#DEDEDE"),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                  onPressed: () {
                    if (!_isEnableNext) {
                      //UiUtil.toast("请先完成当前任务");
                      return;
                    }

                    if (_currentIndex == lastIndex) {
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
                      Text(_currentIndex == lastIndex ? S.of(context).submit : S.of(context).next,
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
        ),
      ],
    );
  }

  void _updateUI() {
    _confirmPoiItem = _contributionPois.pois[_currentIndex];

    _isolationText = _answersLabel[_currentIndex];

    _isolationTextList = [];
    _isolationTextList = [
      S.of(context).isolation_yes,
      S.of(context).isolation_no,
    ];

    if (!_confirmPoiItem.myself) {
      _isolationTextList.add(S.of(context).uncertain);
    }

    _addMarkerAndMoveToPoi();

    _isEnableNext = _isolationText.isNotEmpty;

    _positionBloc.add(UpdateConfirmPoiDataPageEvent());
  }

  bool _isSendCheckIn = false;

  void _saveData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt(PrefsKey.VERIFY_DATE, DateTime.now().millisecondsSinceEpoch);
  }

  Future _finishCheckIn(String successTip, List<String> optLogIDs) async {
    var address =
        WalletInheritedModel.of(Keys.rootKey.currentContext)?.activatedWallet?.wallet?.getEthAccount()?.address ?? "";

    if (address?.isEmpty ?? true) {
      Application.router.navigateTo(
          context,
          Routes.contribute_position_finish +
              '?entryRouteName=${Uri.encodeComponent(Routes.contribute_tasks_list)}&pageType=${FinishAddPositionPage.FINISH_PAGE_TYPE_CONFIRM}');
      return;
    }

    if (_isSendCheckIn) {
      return;
    }

    _isSendCheckIn = true;

    ContributionsApi api = ContributionsApi();
    try {
      await api.postCheckIn('confirmPOIV2', _contributionPois.coordinates, optLogIDs);
      UiUtil.toast(successTip);

      BlocProvider.of<AccountBloc>(context).add(UpdateCheckInInfoEvent());

      _isSendCheckIn = false;

    } catch (e) {
      _isSendCheckIn = false;
      setState(() {
        _isSendConfirm = false;
      });
      LogUtil.process(e);
    }
  }

  // Action
  _pushPosition() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => VerifyPositionPage(
          initLocation: _confirmPoiItem.latLng,
          addressName: _confirmPoiItem.name,
        ),
      ),
    );
  }

  void _onStyleLoaded(MapboxMapController controller) {
    _mapController = controller;
    _addMarkerAndMoveToPoi();
  }

  void _addMarkerAndMoveToPoi() {
    if (_mapController != null && _confirmPoiItem?.name != null) {
      _addMarkerSubject.sink.add(1);
    }
  }
}

Future<bool> showConfirmDialog(BuildContext context, String content, {String title = ""}) {
  return UiUtil.showAlertView(
    context,
    title: title.isEmpty ? S.of(context).tips : title,
    actions: [
      ClickOvalButton(
        S.of(context).cancel,
            () {
              Navigator.of(context).pop(false);
        },
        width: 115,
        height: 36,
        fontSize: 14,
        fontWeight: FontWeight.normal,
        fontColor: DefaultColors.color999,
        btnColor: [Colors.transparent],
      ),
      SizedBox(
        width: 20,
      ),
      ClickOvalButton(
        S.of(context).confirm,
            () {
              Navigator.of(context).pop(true);

            },
        width: 115,
        height: 36,
        fontSize: 16,
        fontWeight: FontWeight.normal,
      ),
    ],
    content: content,
  );
}
