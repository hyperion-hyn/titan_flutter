import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:mapbox_gl/mapbox_gl.dart';
import 'package:rxdart/rxdart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:titan/generated/l10n.dart';
import 'package:titan/src/basic/utils/hex_color.dart';
import 'package:titan/src/basic/widget/base_app_bar.dart';
import 'package:titan/src/basic/widget/base_state.dart';
import 'package:titan/src/components/setting/setting_component.dart';
import 'package:titan/src/components/wallet/wallet_component.dart';
import 'package:titan/src/config/application.dart';
import 'package:titan/src/config/consts.dart';
import 'package:titan/src/pages/atlas_map/map3/map3_node_public_widget.dart';
import 'package:titan/src/pages/contribution/add_poi/bloc/bloc.dart';
import 'package:titan/src/pages/contribution/add_poi/position_finish_page.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/services.dart';
import 'package:titan/src/pages/contribution/add_poi/select_position_page.dart';
import 'package:titan/src/pages/contribution/verify_poi/verify_poi_page_v2.dart';
import 'package:titan/src/pages/red_pocket/rp_record_detail_page.dart';
import 'package:titan/src/pages/red_pocket/rp_share_confirm_page.dart';
import 'package:titan/src/plugins/wallet/token.dart';
import 'package:titan/src/routes/routes.dart';
import 'package:titan/src/utils/format_util.dart';
import 'package:titan/src/widget/all_page_state/all_page_state.dart';
import 'package:titan/src/widget/loading_button/click_oval_button.dart';

class RpShareEditPage extends StatefulWidget {
  final LatLng userPosition;
  final RedPocketShareType shareType;
  RpShareEditPage({this.userPosition, this.shareType = RedPocketShareType.NEWER});

  @override
  State<StatefulWidget> createState() {
    return _RpShareEditState();
  }
}

class _RpShareEditState extends BaseState<RpShareEditPage> {
  final ScrollController _scrollController = ScrollController();

  final TextEditingController _rpAmountController = TextEditingController();
  final TextEditingController _hynAmountController = TextEditingController();
  final TextEditingController _zoneLengthController = TextEditingController();
  final TextEditingController _rpCountController = TextEditingController();
  final TextEditingController _blessingController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final _rpAmountKey = GlobalKey<FormState>();
  final _hynAmountKey = GlobalKey<FormState>();
  final _zoneLengthKey = GlobalKey<FormState>();
  final _rpCountKey = GlobalKey<FormState>();
  final _blessingKey = GlobalKey<FormState>();
  final _passwordKey = GlobalKey<FormState>();

  final PositionBloc _positionBloc = PositionBloc();
  final _addMarkerSubject = PublishSubject<dynamic>();

  final PublishSubject<int> _filterSubject = PublishSubject<int>();
  final _addressNameKey = GlobalKey<FormState>();

  final StreamController<bool> _validController = StreamController.broadcast();
  GlobalKey<FormState> _focusKey;

  MapboxMapController _mapController;

  String _addressText;

  Map<String, dynamic> _openCageData;

  bool _isUploading = false;

  bool _isOnPressed = false;
  bool _isLoadingOpenCage = false;
  bool _isOnlyNewerGet = true;

  int _requestOpenCageDataCount = 0;
  String language;
  String address;

  LatLng _selectedPosition;
  LatLng _initSelectedPosition;

  String get _baseTitle => widget.shareType == RedPocketShareType.NEWER ? '新人红包' : '位置红包';

  @override
  void onCreated() {
    _initSelectedPosition = widget.userPosition;

    language = SettingInheritedModel.of(context).languageCode;
    address = WalletInheritedModel.of(context).activatedWallet.wallet.accounts[0].address;

    //_positionBloc.add(GetOpenCageEvent(widget.userPosition, language));
    _filterSubject.debounceTime(Duration(seconds: 1)).listen((count) {
      //print('[add] ---> count:$count, _requestOpenCageDataCount:$_requestOpenCageDataCount');
      _positionBloc.add(GetOpenCageEvent(_selectedPosition, language));
    });

    _addMarkerSubject.debounceTime(Duration(milliseconds: 500)).listen((_) {
      var latlng = _selectedPosition;
      //print("[Verify] add, name:${confirmPoiItem.name}, latlng:$latlng");

      var poiName = '';

      _mapController?.clearSymbols();
      _mapController?.addSymbol(
        SymbolOptions(
          textField: poiName,
          textOffset: Offset(0, 1),
          textColor: "#333333",
          textSize: 16,
          geometry: latlng,
          iconImage: "rp_marker",
          iconAnchor: "bottom",
          //iconOffset: Offset(0.0, 3.0),
        ),
      );
      _mapController?.animateCamera(CameraUpdate.newLatLng(latlng));
    });

    _addMarkerAndMoveToPoi();

    super.onCreated();
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    _setupData();
    super.didChangeDependencies();
  }

  void _setupData() {}

  @override
  void dispose() {
    _positionBloc.close();
    _filterSubject.close();
    _addMarkerSubject.close();
    _validController.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: BaseAppBar(
        baseTitle: _baseTitle,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      ),
      body: _buildView(context),
    );
  }

  // build view
  Widget _buildView(BuildContext context) {
    return BlocBuilder<PositionBloc, AllPageState>(
      bloc: _positionBloc,
      condition: (AllPageState fromState, AllPageState state) {
        if (state is PostPoiDataV2ResultSuccessState) {
          if (_isUploading) {
            Application.router.navigateTo(
                context,
                Routes.contribute_position_finish +
                    '?entryRouteName=${Uri.encodeComponent(Routes.contribute_tasks_list)}&pageType=${FinishAddPositionPage.FINISH_PAGE_TYPE_ADD}');
          }
        } else if (state is PostPoiDataV2ResultFailState) {
          setState(() {
            _isUploading = false;
          });

          var msg = S.of(context).add_failed_hint + "," + S.of(context).error_code_func(state.code);
          if (state.code == -409) {
            msg = S.of(context).add_failed_exist_hint;
          } else if (state.code == -1) {
            msg = S.of(context).network_connection_timeout_please_try_again_later_toast;
          } else if (state.code == -10004) {
            msg = S.of(context).picture_format_is_not_supported_yet_toast;
          }
          Fluttertoast.showToast(msg: msg);
        } else if (state is GetOpenCageState) {
          _openCageData = state.openCageData;

          var country = _openCageData["country"] ?? "";
          var provinces = _openCageData["state"];
          var city = _openCageData["city"];
          var road = _openCageData["road"];
          var building = _openCageData["building"];

          String countryCode = _openCageData["country_code"] ?? "CN";
          _saveCountryCode(countryCode: countryCode.toUpperCase());

          /*
          "components": {
          "ISO_3166-1_alpha-2": "CN",
          "ISO_3166-1_alpha-3": "CHN",
          "_type": "building",
          "building": "东区181",
          "city": "海珠区",
          "continent": "Asia",
          "country": "中国",
          "country_code": "cn",
          "county": "",
          "postcode": "510275",
          "road": "园东路",
          "state": "广东省"
          },
          "confidence": 10,
          "formatted": "东区181, 181 园东路, 新港街道, 510275 广东省, 中国",
        */
          setState(() {
            //_addressText = country + " " + provinces + " " + city + " " + county;
            //_addressText = county + "，" + city + "，" + provinces + "，" + country;
            //_addressText = "中国 广东省 广州市 天河区 中山大道 环球都会广场 2601楼";
            _addressText = country + provinces + city + road + building;
          });
        }

        return true;
      },
      builder: (BuildContext context, AllPageState state) {
        if (state is GetOpenCageLoadingState) {
          _isLoadingOpenCage = true;
        } else if (state is GetOpenCageState) {
          _isLoadingOpenCage = false;
        }
        return _buildBody();
      },
    );
  }

  void _saveCountryCode({String countryCode = "CN"}) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(PrefsKey.mapboxCountryCode, countryCode);
  }

  Widget _buildLoading() {
    return Visibility(
      visible: _isUploading,
      child: Center(
        child: SizedBox(
          height: 40,
          width: 40,
          child: CircularProgressIndicator(
            strokeWidth: 1.5,
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    Widget child;
    if (widget.shareType == RedPocketShareType.NEWER) {
      child = Column(
        children: <Widget>[
          SizedBox(
            height: 10,
          ),
          _buildAmountCell(),
          SizedBox(
            height: 20,
          ),
          _buildRpCountCell(),
          _buildBlessingCell(),
          _buildPasswordCell(),
          _buildTipsView(),
          _confirmButtonWidget(),
        ],
      );
    } else {
      child = Column(
        children: <Widget>[
          SizedBox(
            height: 10,
          ),
          _buildAmountCell(),
          SizedBox(
            height: 20,
          ),
          _buildAddressCell(),
          _buildZoneCell(),
          SizedBox(
            height: 20,
          ),
          _buildRpCountCell(),
          _buildBlessingCell(),
          _buildSwitchCell(),
          SizedBox(
            height: 20,
          ),
          _buildPasswordCell(),
          _buildTipsView(),
          _confirmButtonWidget(),
        ],
      );
    }

    return Stack(
      children: <Widget>[
        BaseGestureDetector(
          context: context,
          child: SingleChildScrollView(
            controller: _scrollController,
            child: child,
          ),
        ),
        _buildLoading(),
      ],
    );
  }

  Widget _rowInputWidget({
    GlobalKey<FormState> key,
    TextEditingController controller,
    String hintText,
    String title,
    String unit,
    String leftTitle = '',
    bool showLeft = false,
    int maxLength = 18,
    TextInputType keyboardType,
    String error,
    bool isOptional = false,
  }) {
    return StreamBuilder<Object>(
        stream: _validController.stream,
        builder: (context, snapshot) {
          bool invalid = false;

          var errorText = error ?? hintText;

          if (snapshot?.data == null || isOptional) {
            invalid = false;
          } else {
            // 分：检查所有 / 检查某个
            if (_focusKey == null) {
              invalid = (controller?.text?.isEmpty ?? true);
            } else {
              invalid = !(snapshot?.data ?? true) && _focusKey == key && (controller?.text?.isEmpty ?? true);
            }
          }
          print("[$runtimeType] invalid: $invalid");

          var textColor = invalid ? HexColor('#FF001B') : HexColor('#333333');
          return Column(
            children: [
              Container(
                // color: Colors.blue,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (showLeft)
                      leftTitle.isNotEmpty
                          ? Container(
                              margin: const EdgeInsets.only(
                                right: 16,
                                top: 16,
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 5,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                colors: [
                                  HexColor('#FF0527'),
                                  HexColor('#FF4D4D'),
                                ],
                              )),
                              child: Text(
                                leftTitle,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                ),
                              ),
                            )
                          : SizedBox(
                              width: 50,
                            ),
                    Padding(
                      padding: const EdgeInsets.only(
                        top: 16,
                      ),
                      child: Text(
                        title,
                        style: TextStyle(
                          color: textColor,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 16,
                    ),
                    Flexible(
                      child: Form(
                        key: key,
                        child: TextFormField(
                          controller: controller,
                          textAlign: TextAlign.end,
                          onChanged: (String inputText) {
                            print('[$runtimeType] --> onChanged, inputText:$inputText');

                            _focusKey = key;

                            bool isValid = key.currentState.validate();

                            if (inputText.isEmpty || inputText.length == 0) {
                              isValid = false;
                            }

                            _validController.add(isValid);
                          },
                          onEditingComplete: () {
                            //_onEditingComplete();
                          },
                          onFieldSubmitted: (String inputText) {
                            FocusScope.of(context).requestFocus(FocusNode());
                          },
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                          cursorColor: Theme.of(context).primaryColor,
                          //光标圆角
                          cursorRadius: Radius.circular(5),
                          //光标宽度
                          cursorWidth: 1.8,
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: hintText,
                            errorStyle: TextStyle(fontSize: 14, color: Colors.blue),
                            hintStyle: TextStyle(
                              fontSize: 12,
                              color: HexColor('#999999'),
                            ),
                          ),
                          keyboardType: keyboardType ?? TextInputType.numberWithOptions(decimal: false),
                          inputFormatters: [
                            LengthLimitingTextInputFormatter(maxLength),
                          ],
                        ),
                      ),
                    ),
                    if (unit.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(
                          left: 16,
                          top: 16,
                        ),
                        child: Text(
                          unit,
                          style: TextStyle(
                            color: textColor,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              invalid
                  ? Padding(
                      padding: const EdgeInsets.only(
                        bottom: 8,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            errorText,
                            style: TextStyle(
                              color: HexColor('#FF001B'),
                              fontWeight: FontWeight.normal,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    )
                  : Container(),
            ],
          );
        });
  }

  Widget _clipRectWidget({
    Widget child,
    String desc = '',
    double vertical = 16,
  }) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: 16,
            vertical: vertical,
          ),
          margin: const EdgeInsets.symmetric(
            horizontal: 16,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.all(
              Radius.circular(12),
            ),
          ),
          child: child,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(
                  left: 16,
                  right: 16,
                  top: 8,
                ),
                child: Text(
                  desc,
                  maxLines: 3,
                  textAlign: TextAlign.end,
                  style: TextStyle(
                    color: HexColor('#999999'),
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          ],
        )
      ],
    );
  }

  Widget _buildAmountCell() {
    var rpBalanceStr = '--';
    var hynBalanceStr = '--';

    var rpToken = WalletInheritedModel.of(context).getCoinVoBySymbol(
      SupportedTokens.HYN_RP_HRC30_ROPSTEN.symbol,
    );
    var hynToken = WalletInheritedModel.of(context).getCoinVoBySymbol(
      SupportedTokens.HYN_Atlas.symbol,
    );
    try {
      rpBalanceStr = FormatUtil.coinBalanceHumanReadFormat(
        rpToken,
      );
      hynBalanceStr = FormatUtil.coinBalanceHumanReadFormat(
        hynToken,
      );
    } catch (e) {}

    var rpBalance = '$rpBalanceStr RP';
    var hynBalance = '$hynBalanceStr HYN';

    return _clipRectWidget(
        vertical: 8,
        desc: '${S.of(context).wallet_balance} $rpBalance，$hynBalance',
        child: Column(
          children: [
            _rowInputWidget(
              key: _rpAmountKey,
              controller: _rpAmountController,
              hintText: '0.00',
              error: '请输入RP金额',
              title: 'RP金额',
              unit: 'RP',
              showLeft: true,
              leftTitle: widget.shareType == RedPocketShareType.NEWER ? '新人' : '位置',
            ),
            Padding(
              padding: const EdgeInsets.only(
                left: 60,
              ),
              child: Container(
                height: 0.5,
                color: HexColor('#F2F2F2'),
              ),
            ),
            _rowInputWidget(
              key: _hynAmountKey,
              controller: _hynAmountController,
              hintText: '0.00',
              error: '请输入HYN金额',
              title: 'HYN金额',
              unit: 'HYN',
              showLeft: true,
            ),
          ],
        ));
  }

  Widget _buildZoneCell() {
    return _clipRectWidget(
        vertical: 4,
        desc: '最大距离100千米',
        child: _rowInputWidget(
          key: _zoneLengthKey,
          controller: _zoneLengthController,
          hintText: '填写附近可领取距离',
          title: '可领取范围',
          unit: '米',
        ));
  }

  Widget _buildRpCountCell() {
    return _clipRectWidget(
        vertical: 4,
        child: _rowInputWidget(
          key: _rpCountKey,
          controller: _rpCountController,
          hintText: '填写个数，平均领取',
          error: '请填写个数',
          title: '红包个数',
          unit: '个',
        ));
  }

  Widget _buildBlessingCell() {
    return _clipRectWidget(
        vertical: 4,
        child: _rowInputWidget(
          key: _blessingKey,
          controller: _blessingController,
          hintText: '填写祝福语，例如：恭喜发财（可选）',
          error: '请填写祝福语',
          title: '祝福',
          unit: '',
          keyboardType: TextInputType.text,
          isOptional: true,
        ));
  }

  Widget _buildPasswordCell() {
    return _clipRectWidget(
        vertical: 4,
        desc: '新人正确输入口令才能拆解红包 (可选)',
        child: _rowInputWidget(
          key: _passwordKey,
          controller: _passwordController,
          hintText: '填写红包口令，例如：888，发发发',
          error: '请填写红包口令',
          title: '口令',
          unit: '',
          keyboardType: TextInputType.text,
          isOptional: true,
        ));
  }

  Widget _buildSwitchCell() {
    return _clipRectWidget(
        desc: '如果只允许新人领取，你要为每个新人至少要塞 0.001 HYN 作为他之后矿工费所用',
        vertical: 4,
        child: Row(
          children: [
            Text(
              '只允许新人领取',
              style: TextStyle(
                color: HexColor('#333333'),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            Spacer(),
            Switch(
              value: _isOnlyNewerGet,
              activeColor: Colors.white,
              activeTrackColor: HexColor('#FF4D4D'),
              onChanged: (bool value) {
                setState(() {
                  _isOnlyNewerGet = value;
                });
              },
            )
          ],
        ));
  }

  Widget _buildAddressCell() {
    var style;
    if (SettingInheritedModel.of(context)?.areaModel?.isChinaMainland ?? true) {
      style = Const.kWhiteWithoutMapStyleCn;
    } else {
      style = Const.kWhiteWithoutMapStyle;
    }
    var languageCode = Localizations.localeOf(context).languageCode;

    var address = _addressText ?? '';
    if (_selectedPosition != null) {
      if (_openCageData == null) {
        address = S.of(context).click_auto_get_hint;
      }
    }
    return _clipRectWidget(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                InkWell(
                  onTap: _pushPosition,
                  child: RichText(
                    text: TextSpan(
                      text: '投放位置',
                      style: TextStyle(
                        color: HexColor('#333333'),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                InkWell(
                  onTap: () {
                    if (_selectedPosition != null && _openCageData == null) {
                      _requestOpenCageDataCount += 1;
                      _filterSubject.sink.add(_requestOpenCageDataCount);
                    } else {
                      _pushPosition();
                    }
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 4,
                    ),
                    child: RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: '$address',
                            style: TextStyle(
                                color: _openCageData == null ? HexColor('#1F81FF') : HexColor('#999999'), fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                InkWell(
                  onTap: _pushPosition,
                  child: RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: (_selectedPosition != null) ? '  ${S.of(context).edit_location}' : "",
                          style: TextStyle(color: HexColor('#1F81FF'), fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          (_selectedPosition == null)
              ? InkWell(
                  onTap: _pushPosition,
                  child: clipRRectWidget(
                    child: Stack(
                      children: <Widget>[
                        Container(
                            width: double.infinity,
                            height: 150,
                            child: Image.asset(
                              'res/drawable/rp_map_background.png',
                              fit: BoxFit.cover,
                            )),
                        Container(
                          width: double.infinity,
                          height: 125,
                          color: Colors.black.withOpacity(0.30),
                          child: Center(
                            child: Text(
                              _isLoadingOpenCage ? "" : S.of(context).click_where_to_edit,
                              style: TextStyle(color: Colors.white, fontSize: 14),
                            ),
                          ),
                        ),
                        Visibility(
                          visible: _isLoadingOpenCage,
                          child: Container(
                            width: double.infinity,
                            height: 125,
                            child: SizedBox(
                              height: 25,
                              width: 25,
                              child: Center(
                                child: CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                  strokeWidth: 1.5,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : SizedBox(
                  height: 150,
                  child: clipRRectWidget(
                    child: MapboxMap(
                      compassEnabled: false,
                      initialCameraPosition: CameraPosition(
                        target: Application.recentlyLocation,
                        zoom: 16,
                      ),
                      styleString: style,
                      onMapCreated: (controller) {
                        Future.delayed(Duration(milliseconds: 500)).then((value) {
                          _onStyleLoaded(controller);
                        });
                      },
                      myLocationTrackingMode: MyLocationTrackingMode.None,
                      rotateGesturesEnabled: false,
                      scrollGesturesEnabled: false,
                      zoomGesturesEnabled: false,
                      tiltGesturesEnabled: false,
                      enableLogo: false,
                      enableAttribution: false,
                      minMaxZoomPreference: MinMaxZoomPreference(1.1, 21.0),
                      myLocationEnabled: false,
                      languageCode: languageCode,
                    ),
                  )),
        ],
      ),
    );
  }

  void _onStyleLoaded(MapboxMapController controller) {
    _mapController = controller;
    _addMarkerAndMoveToPoi();
  }

  void _addMarkerAndMoveToPoi() {
    if (_mapController != null) {
      _addMarkerSubject.sink.add(1);
    }
  }

  Widget _buildTipsView() {
    return Padding(
      padding: const EdgeInsets.only(
        top: 60,
        left: 16,
        right: 16,
        bottom: 46,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(
              top: 16.0,
              bottom: 8,
            ),
            child: Text(S.of(context).precautions,
                style: TextStyle(
                  color: HexColor("#333333"),
                  fontSize: 16,
                )),
          ),
          rowTipsItem('只有新人才能领取，领取后他将成为你的好友；'),
          rowTipsItem('你要为每个新人至少要塞 0.001 HYN作为他之后矿工费所用；'),
          rowTipsItem('24小时候后，如果还剩红包没领取，将自动退回你的钱包；'),
        ],
      ),
    );
  }

  Widget _confirmButtonWidget() {
    return Padding(
      padding: const EdgeInsets.only(
        bottom: 36,
      ),
      child: ClickOvalButton(
        S.of(context).next_step,
        () {
          setState(() {
            _isOnPressed = true;
          });
          Future.delayed(Duration(seconds: 1), () {
            setState(() {
              _isOnPressed = false;
            });
          });
          //_uploadPoiData();

          _focusKey = null;
          _validController.add(false);

          //showSendAlertView(context);
        },
        isLoading: _isOnPressed,
        btnColor: [HexColor("#FF4D4D"), HexColor("#FF0527")],
        fontSize: 16,
        width: 260,
        height: 42,
      ),
    );
  }

  _pushPosition() async {
    FocusScope.of(context).requestFocus(FocusNode());

    var position = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SelectPositionPage(
          initLocation: _selectedPosition != null ? _selectedPosition : _initSelectedPosition,
          type: SelectPositionPage.SELECT_PAGE_TYPE_POI,
        ),
      ),
    );

    if (position == null) {
      return;
    }

    var isSame = false;
    if (_selectedPosition != null) {
      if ((_selectedPosition != position) &&
          (position is LatLng) &&
          position.latitude != _selectedPosition.latitude &&
          position.longitude != _selectedPosition.longitude) {
        _selectedPosition = position;
      } else {
        isSame = true;
      }
    } else {
      _selectedPosition = position;
    }

    if (!isSame) {
      _addMarkerAndMoveToPoi();

      _requestOpenCageDataCount += 1;
      _filterSubject.sink.add(_requestOpenCageDataCount);
    }
  }

  _uploadPoiData() async {
    print('[add] --> 存储中。。。');

    // 0. 检测地点名称
    if (!_addressNameKey.currentState.validate()) {
      _scrollController.animateTo(0, duration: Duration(milliseconds: 300, microseconds: 33), curve: Curves.linear);
      return;
    }

    // 2.检测网络数据
    if (_openCageData == null) {
      _positionBloc.add(GetOpenCageEvent(_selectedPosition, language));
      Fluttertoast.showToast(msg: S.of(context).please_edit_location_hint);
      _scrollController.animateTo(0, duration: Duration(milliseconds: 300, microseconds: 33), curve: Curves.linear);
      return;
    }

    var option =
        await showConfirmDialog(context, S.of(context).add_location_data_please_confirm_actual_situation_toast);
    if (!option) return;

    _positionBloc.add(PostPoiDataV2Event(null, address));
    setState(() {
      _isUploading = true;
    });
  }

  static Future<bool> showSendAlertView<T>(
    BuildContext context,
  ) {
    return showDialog<bool>(
      barrierDismissible: true,
      // 传入 context
      context: context,
      // 构建 Dialog 的视图
      builder: (context) {
        return _buildAlertView();
      },
    );
  }

  static Widget _buildAlertView({
    String hynAmount = '0',
    String rpAmount = '0',
    String hynFee = '0',
    String rpFee = '0',
  }) {
    return RpShareConfirmPage(
      hynAmount: hynAmount,
      rpAmount: rpAmount,
      hynFee: hynFee,
      rpFee: rpFee,
    );
  }

  String _maxLengthLimit(TextEditingController controller, {bool isDetailAddress = false}) {
    String text = controller.text ?? "";
    if (isDetailAddress) {
      if (text.length > 200) {
        text = text.substring(0, 200);
      }
    } else {
      if (text.length > 50) {
        text = text.substring(0, 50);
      }
    }
    return text;
  }
}

Widget clipRRectWidget({Widget child, double width, double height}) {
  return Card(
    clipBehavior: Clip.antiAlias,
    shadowColor: Colors.white,
    shape: RoundedRectangleBorder(
      side: const BorderSide(width: 0.5, color: Colors.white),
      borderRadius: BorderRadius.all(
        Radius.circular(12.0),
      ),
    ),
    child: child,
  );
}
