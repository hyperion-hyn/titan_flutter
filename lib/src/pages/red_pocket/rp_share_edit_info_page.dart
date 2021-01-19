import 'dart:async';
import 'package:decimal/decimal.dart';
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
import 'package:titan/src/components/rp/bloc/bloc.dart';
import 'package:titan/src/components/rp/redpocket_component.dart';
import 'package:titan/src/components/setting/setting_component.dart';
import 'package:titan/src/components/wallet/wallet_component.dart';
import 'package:titan/src/config/application.dart';
import 'package:titan/src/config/consts.dart';
import 'package:titan/src/pages/atlas_map/map3/map3_node_public_widget.dart';
import 'package:titan/src/pages/contribution/add_poi/bloc/bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/services.dart';
import 'package:titan/src/pages/contribution/add_poi/select_position_page.dart';
import 'package:titan/src/pages/red_pocket/entity/rp_share_config_entity.dart';
import 'package:titan/src/pages/red_pocket/entity/rp_share_req_entity.dart';
import 'package:titan/src/pages/red_pocket/rp_record_detail_page.dart';
import 'package:titan/src/pages/red_pocket/rp_share_send_dialog_page.dart';
import 'package:titan/src/plugins/wallet/config/tokens.dart';
import 'package:titan/src/plugins/wallet/token.dart';
import 'package:titan/src/utils/format_util.dart';
import 'package:titan/src/widget/all_page_state/all_page_state.dart';
import 'package:titan/src/widget/loading_button/click_oval_button.dart';

import 'entity/rp_util.dart';

class RpShareEditInfoPage extends StatefulWidget {
  final LatLng userPosition;
  final RpShareTypeEntity shareTypeEntity;

  RpShareEditInfoPage({
    this.userPosition,
    this.shareTypeEntity = SupportedShareType.NORMAL,
  });

  @override
  State<StatefulWidget> createState() {
    return _RpShareEditInfoState();
  }
}

class _RpShareEditInfoState extends BaseState<RpShareEditInfoPage> {
  final ScrollController _scrollController = ScrollController();
  final PublishSubject<int> _filterSubject = PublishSubject<int>();
  final StreamController<String> _validController = StreamController.broadcast();

  final TextEditingController _rpAmountController = TextEditingController();
  final TextEditingController _hynAmountController = TextEditingController();
  final TextEditingController _rangeController = TextEditingController();
  final TextEditingController _countController = TextEditingController();
  final TextEditingController _greetingController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final _rpAmountKey = GlobalKey<FormState>();
  final _hynAmountKey = GlobalKey<FormState>();
  final _rangeKey = GlobalKey<FormState>();
  final _countKey = GlobalKey<FormState>();
  final _greetingKey = GlobalKey<FormState>();
  final _passwordKey = GlobalKey<FormState>();

  final PositionBloc _positionBloc = PositionBloc();
  final _addMarkerSubject = PublishSubject<dynamic>();

  MapboxMapController _mapController;

  GlobalKey<FormState> _focusKey;
  bool _isInvalidRpAmount = false;
  bool _isInvalidHynAmount = false;
  bool _isInvalidCount = false;
  bool _isInvalidRange = false;

  String _addressText;

  Map<String, dynamic> _openCageData;

  bool _isLoadingOpenCage = false;
  bool _isNewBee = false;

  int _requestOpenCageDataCount = 0;
  String _language;

  LatLng _selectedPosition;
  LatLng _initSelectedPosition;

  bool get _isLocation => widget.shareTypeEntity.index == RedPocketShareType.LOCATION.index;

  RpShareConfigEntity _rpShareConfig;

  @override
  void onCreated() {
    _initSelectedPosition = widget.userPosition;

    _language = SettingInheritedModel.of(context).languageCode;

    _filterSubject.debounceTime(Duration(seconds: 1)).listen((count) {
      _positionBloc.add(GetOpenCageEvent(_selectedPosition, _language));
    });

    _addMarkerSubject.debounceTime(Duration(milliseconds: 500)).listen((_) {
      var latLng = _selectedPosition;

      var poiName = '';

      _mapController?.clearSymbols();
      _mapController?.addSymbol(
        SymbolOptions(
          textField: poiName,
          textOffset: Offset(0, 1),
          textColor: "#333333",
          textSize: 16,
          geometry: latLng,
          // iconImage: "rp_marker",
          iconImage: "hyn_marker_big",
          iconAnchor: "bottom",
          //iconOffset: Offset(0.0, 3.0),
        ),
      );
      _mapController?.animateCamera(CameraUpdate.newLatLng(latLng));
    });

    _addMarkerAndMoveToPoi();

    if (context != null) {
      BlocProvider.of<RedPocketBloc>(context).add(UpdateShareConfigEvent());
    }

    _isNewBee = !_isLocation;

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

  void _setupData() {
    _rpShareConfig = RedPocketInheritedModel.of(context).rpShareConfig;

    //print("[$runtimeType] _setupData, _rpShareConfig:${_rpShareConfig?.toJson()}");
  }

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
        baseTitle: widget.shareTypeEntity.fullNameZh,
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
        if (state is GetOpenCageState) {
          _openCageData = state.openCageData;

          var country = _openCageData["country"] ?? "";
          var provinces = _openCageData["state"];
          var city = _openCageData["city"];
          var road = _openCageData["road"];
          var building = _openCageData["building"];
          var county = _openCageData["county"];

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
            if (country == '中国') {
              _addressText = provinces + city + road + building;
            } else {
              _addressText = county + "," + city + "," + provinces + "," + country;
            }
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

  Widget _buildBody() {
    Widget child;
    if (!_isLocation) {
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
          _buildPasswordCell(),
          _buildSwitchCell(),
          // SizedBox(
          //   height: 20,
          // ),
          _buildTipsView(),
          _confirmButtonWidget(),
        ],
      );
    }

    return BaseGestureDetector(
      context: context,
      child: SingleChildScrollView(
        controller: _scrollController,
        child: child,
      ),
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
    String defaultErrorText,
    bool isOptional = false,
    FormFieldValidator<String> validator,
  }) {
    return StreamBuilder<Object>(
        stream: _validController.stream,
        builder: (context, snapshot) {
          var errorText = '';

          //print("[$runtimeType] snapshot?.data: ${snapshot?.data}");

          if (snapshot?.data == null || isOptional) {
            errorText = '';
          } else {
            // 分：检查所有 / 检查某个

            // todo:
            errorText = validator(controller.text);

            if (snapshot?.data == '-1' && errorText.isEmpty) {
              errorText = (controller?.text?.isEmpty ?? true) ? defaultErrorText ?? hintText : '';
            }
          }
          //print("[$runtimeType] errorText: $errorText");

          var textColor = errorText.isNotEmpty ? HexColor('#FF001B') : HexColor('#333333');
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
                          color: HexColor('#333333'),
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
                        child: Container(
                          // color: Colors.red,
                          child: TextFormField(
                            controller: controller,
                            textAlign: TextAlign.end,

                            onChanged: (String inputValue) {
                              _focusKey = key;
                              _validController.add(inputValue);
                            },
                            onFieldSubmitted: (String inputText) {
                              FocusScope.of(context).requestFocus(FocusNode());
                            },
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: textColor,
                            ),
                            cursorColor: Theme.of(context).primaryColor,
                            //光标圆角
                            cursorRadius: Radius.circular(5),
                            //光标宽度
                            cursorWidth: 1.8,
                            decoration: InputDecoration(
                              contentPadding: EdgeInsets.only(
                                top: unit.isNotEmpty ? 18 : 0,
                              ),
                              border: InputBorder.none,
                              hintText: hintText,
                              errorStyle: TextStyle(fontSize: 14, color: Colors.blue),
                              hintStyle: TextStyle(
                                fontSize: 12,
                                color: HexColor('#999999'),
                              ),
                              suffixIcon: (unit.isNotEmpty)
                                  ? Padding(
                                      padding: EdgeInsets.only(
                                        left: 16,
                                        top: (key == _hynAmountKey || key == _rpAmountKey) ? 18 : 16,
                                      ),
                                      child: Text(
                                        unit,
                                        textAlign: TextAlign.end,
                                        style: TextStyle(
                                          color: HexColor('#333333'),
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    )
                                  : null,
                            ),
                            keyboardType: keyboardType ?? TextInputType.numberWithOptions(decimal: false),
                            inputFormatters: [
                              LengthLimitingTextInputFormatter(maxLength),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              errorText.isNotEmpty
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
      SupportedTokens.HYN_RP_HRC30.symbol,
    );
    var hynToken = WalletInheritedModel.of(context).getCoinVoBySymbol(
      SupportedTokens.HYN_Atlas.symbol,
    );
    try {
      rpBalanceStr = FormatUtil.coinBalanceHumanReadFormat(
        rpToken,
        decimal: 4,
      );
      hynBalanceStr = FormatUtil.coinBalanceHumanReadFormat(
        hynToken,
        decimal: 4,
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
            defaultErrorText: '请输入RP金额',
            title: 'RP金额',
            unit: 'RP',
            showLeft: true,
            leftTitle: widget.shareTypeEntity.nameZh,
            validator: (String inputText) {
              if (inputText.isEmpty || inputText == null) {
                return '';
              }
              var errorText = '';
              var inputValue = Decimal.tryParse(inputText ?? '0') ?? Decimal.zero;

              var coinVo = WalletInheritedModel.of(
                context,
                aspect: WalletAspect.activatedWallet,
              ).getCoinVoBySymbol('RP');
              var rpBalance = Decimal.parse(FormatUtil.coinBalanceHumanRead(coinVo));

              var minRp = _rpShareConfig?.rpMin ?? '0.01';
              var count = int?.tryParse(_countController.text ?? '1') ?? 1;
              var multiMinRp = Decimal.parse(minRp) * Decimal.fromInt(count);
              if (inputValue > Decimal.zero && inputValue < multiMinRp) {
                errorText = '至少$multiMinRp RP（人均$minRp）';
              }

              if (rpBalance >= Decimal.zero && inputValue > rpBalance) {
                errorText = 'RP余额不足';
              }

              _isInvalidRpAmount = errorText.isNotEmpty;

              //print("[TextField], errorText:$errorText, rp:$inputText, _isInvalidRpAmount:$_isInvalidRpAmount");

              return errorText;
            },
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
            defaultErrorText: '请输入HYN金额',
            title: 'HYN金额',
            unit: 'HYN',
            showLeft: true,
            validator: (String inputText) {
              if (inputText.isEmpty || inputText == null) {
                return '';
              }
              var errorText = '';
              var inputValue = Decimal.tryParse(inputText ?? '0') ?? Decimal.zero;

              var coinVo = WalletInheritedModel.of(
                context,
                aspect: WalletAspect.activatedWallet,
              ).getCoinVoBySymbol('HYN');

              var hynBalance = Decimal.parse(FormatUtil.coinBalanceHumanRead(coinVo));

              var minHyn = _rpShareConfig?.hynMin ?? '0.01';
              var count = int?.tryParse(_countController.text ?? '1') ?? 1;
              var multiMinHyn = Decimal.parse(minHyn) * Decimal.fromInt(count);
              if (inputValue > Decimal.zero && inputValue < multiMinHyn) {
                errorText = '至少$multiMinHyn HYN（人均$minHyn）';
              }

              if (hynBalance >= Decimal.zero && inputValue > hynBalance) {
                errorText = S.of(context).hyn_balance_no_enough;
              }

              _isInvalidHynAmount = errorText.isNotEmpty;

              return errorText;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildZoneCell() {
    return _clipRectWidget(
      vertical: 4,
      desc: '最大距离100千米',
      child: _rowInputWidget(
        key: _rangeKey,
        controller: _rangeController,
        hintText: '填写附近可领取距离',
        title: '领取范围',
        unit: '千米',
        validator: (String inputText) {
          if (inputText.isEmpty || inputText == null) {
            return '';
          }

          var inputValue = double.tryParse(inputText ?? '0') ?? 0;

          var errorText = '';

          if (inputValue > 0 && inputValue > 100) {
            errorText = '最大距离100千米';
          }

          _isInvalidRange = errorText.isNotEmpty;

          return errorText;
        },
      ),
    );
  }

  Widget _buildRpCountCell() {
    return _clipRectWidget(
      vertical: 4,
      child: _rowInputWidget(
        key: _countKey,
        controller: _countController,
        hintText: '填写个数',
        defaultErrorText: '请填写红包个数',
        keyboardType: TextInputType.numberWithOptions(decimal: true),
        title: '红包个数',
        unit: '个',
        validator: (String inputText) {
          if (inputText.isEmpty || inputText == null) {
            return '';
          }

          var inputValue = int.tryParse(inputText ?? '0') ?? 0;

          var errorText = '';

          // if (inputValue > 0 && inputValue > 100) {
          //   errorText = '一次最多发100个红包';
          // }

          if (inputValue < 0) {
            errorText = '至少1个红包';
          }

          _isInvalidCount = errorText.isNotEmpty;

          return errorText;
        },
      ),
    );
  }

  Widget _buildBlessingCell() {
    return _clipRectWidget(
        vertical: 4,
        child: _rowInputWidget(
          key: _greetingKey,
          controller: _greetingController,
          hintText: '恭喜发财，大吉大利',
          defaultErrorText: '请填写祝福语',
          title: '祝福语',
          unit: '',
          keyboardType: TextInputType.text,
          isOptional: true,
        ));
  }

  Widget _buildPasswordCell() {
    return _clipRectWidget(
        vertical: 4,
        // desc: '新人正确输入口令才能拆解红包 (可选)',
        child: _rowInputWidget(
          key: _passwordKey,
          controller: _passwordController,
          hintText: '选填',
          defaultErrorText: '请填写红包口令',
          title: '口令',
          unit: '',
          keyboardType: TextInputType.text,
          isOptional: true,
        ));
  }

  Widget _buildSwitchCell() {
    var hynMin = _rpShareConfig?.hynMin ?? '0.01';

    return _clipRectWidget(
        // desc: '如果只允许新人领取，你要为每个新人至少要塞 $hynMin HYN 作为他之后矿工费所用',
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
              value: _isNewBee,
              activeColor: Colors.white,
              activeTrackColor: HexColor('#FF4D4D'),
              onChanged: (bool value) {
                setState(() {
                  _isNewBee = value;
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
                Flexible(
                  child: InkWell(
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
                                  color: _openCageData == null ? HexColor('#1F81FF') : HexColor('#999999'),
                                  fontSize: 12),
                            ),
                          ],
                        ),
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
                          height: 150,
                          color: Colors.black.withOpacity(0.30),
                          child: Center(
                            child: Padding(
                              padding: const EdgeInsets.only(top: 60, left: 20),
                              child: Text(
                                _isLoadingOpenCage ? "" : '点击编辑投放位置',
                                style: TextStyle(color: Colors.white, fontSize: 14),
                              ),
                            ),
                          ),
                        ),
                        Visibility(
                          visible: _isLoadingOpenCage,
                          child: Container(
                            width: double.infinity,
                            height: 150,
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
    var minHyn = _rpShareConfig?.hynMin ?? '0.01';

    return Padding(
      padding: const EdgeInsets.only(
        top: 10,
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
          rowTipsItem('如果开启新人才能领取，领取后他将成为你的好友；\n但你要为每个新人至少要塞 $minHyn HYN作为他之后矿工费所用；'),
          // rowTipsItem('你要为每个新人至少要塞 $minHyn HYN作为他之后矿工费所用；'),
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
        _confirmAction,
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

  _confirmAction() async {
    print('[$runtimeType] _confirmDataAction, 1');

    RpShareReqEntity reqEntity = RpShareReqEntity.onlyId('0');

    _focusKey = null;
    _validController.add('-1');

    if ((_isInvalidHynAmount && _isInvalidRpAmount) || _isInvalidCount || (_isInvalidRange && _isLocation)) {
      _scrollController.animateTo(0, duration: Duration(milliseconds: 300, microseconds: 33), curve: Curves.linear);

      return;
    }
    /*
    * 1.检查数据有效性
    * 2.检查是否超过余额
    * */

    // rpAmount
    var rpValue = Decimal.tryParse(_rpAmountController?.text ?? '0') ?? Decimal.zero;

    // hynAmount
    var hynValue = Decimal.tryParse(_hynAmountController?.text ?? '0') ?? Decimal.zero;

    if (_isNewBee) {
      if (rpValue <= Decimal.zero) {
        Fluttertoast.showToast(msg: '请输入RP金额！');
        _scrollController.animateTo(0, duration: Duration(milliseconds: 300, microseconds: 33), curve: Curves.linear);

        return;
      }
      reqEntity.rpAmount = rpValue.toDouble();

      var hynMin = _rpShareConfig?.hynMin ?? '0.01';
      if (hynValue <= Decimal.zero) {
        Fluttertoast.showToast(msg: '请输入HYN金额！');
        _scrollController.animateTo(0, duration: Duration(milliseconds: 300, microseconds: 33), curve: Curves.linear);

        return;
      } else if (hynValue > Decimal.zero && hynValue < Decimal.parse(hynMin)) {
        Fluttertoast.showToast(msg: '你要为每个新人至少要塞 $hynMin HYN作为他之后矿工费所用');
        _scrollController.animateTo(0, duration: Duration(milliseconds: 300, microseconds: 33), curve: Curves.linear);

        return;
      }
      reqEntity.hynAmount = hynValue.toDouble();
    } else {
      if (rpValue <= Decimal.zero && hynValue <= Decimal.zero) {
        Fluttertoast.showToast(msg: '请输入RP金额 或 输入HYN金额！');
        _scrollController.animateTo(0, duration: Duration(milliseconds: 300, microseconds: 33), curve: Curves.linear);
        return;
      }

      if (rpValue <= Decimal.zero && hynValue > Decimal.zero) {
        if ((_rpAmountController?.text ?? '').isEmpty) {
          _rpAmountController?.text = '0';
        }

        if (_isInvalidHynAmount) {
          _scrollController.animateTo(0, duration: Duration(milliseconds: 300, microseconds: 33), curve: Curves.linear);
          return;
        }
      }

      if (rpValue > Decimal.zero && hynValue <= Decimal.zero) {
        if ((_hynAmountController?.text ?? '').isEmpty) {
          _hynAmountController?.text = '0';
        }

        if (_isInvalidRpAmount) {
          _scrollController.animateTo(0, duration: Duration(milliseconds: 300, microseconds: 33), curve: Curves.linear);
          return;
        }
      }

      reqEntity.rpAmount = rpValue.toDouble();
      reqEntity.hynAmount = hynValue.toDouble();
    }

    // amount
    var count = int.tryParse(_countController.text ?? '0') ?? 0;
    if (count <= 0) {
      Fluttertoast.showToast(msg: '请填写红包个数！');
      _scrollController.animateTo(0, duration: Duration(milliseconds: 300, microseconds: 33), curve: Curves.linear);

      return;
    }
    reqEntity.count = count;

    if (count > 1 && hynValue > Decimal.zero && rpValue > Decimal.zero) {
      _focusKey = null;
      _validController.add('-1');
    }

    // password
    reqEntity.password = _maxLengthLimit(_passwordController);

    // greeting
    reqEntity.greeting = _maxLengthLimit(_greetingController);

    // rpType
    reqEntity.rpType = widget.shareTypeEntity.nameEn;

    // address
    var walletVo = WalletInheritedModel.of(context).activatedWallet;
    var wallet = walletVo.wallet;
    var address = wallet.getAtlasAccount().address;
    reqEntity.address = address;

    // only location rp
    if (_isLocation) {
      // location
      if (_openCageData == null) {
        _positionBloc.add(GetOpenCageEvent(_selectedPosition, _language));
        Fluttertoast.showToast(msg: S.of(context).please_edit_location_hint);
        _scrollController.animateTo(0, duration: Duration(milliseconds: 300, microseconds: 33), curve: Curves.linear);
        return;
      }
      reqEntity.location = _addressText ?? '';

      // coordinates
      //var coordinates = [_selectedPosition.latitude, _selectedPosition.longitude];
      reqEntity.lat = _selectedPosition?.latitude ?? 0;
      reqEntity.lng = _selectedPosition?.longitude ?? 0;

      // range
      var rangeValue = Decimal.tryParse(_rangeController?.text ?? '0') ?? Decimal.zero;
      if (rangeValue <= Decimal.zero) {
        Fluttertoast.showToast(msg: '请填写可领取的距离！');

        return;
      } else if (hynValue > Decimal.zero && hynValue > Decimal.parse('100')) {
        Fluttertoast.showToast(msg: '最大距离不能超过100千米');
        return;
      }
      reqEntity.range = rangeValue.toDouble();
    } else {
      // isNewBee: 新人可以领
      _isNewBee = true;

      // range
      reqEntity.range = 0;

      // coordinates
      reqEntity.lat = 0;
      reqEntity.lng = 0;
    }

    // isNewBee: 新人可以领
    reqEntity.isNewBee = _isNewBee;

    print('[$runtimeType] _confirmDataAction, 2, reqEntity.toJson:${reqEntity.toJson()}');

    showShareRpSendDialog(context, reqEntity);
  }

  String _maxLengthLimit(TextEditingController controller, {int length = 20}) {
    String text = controller.text ?? "";
    if (text.length > length) {
      text = text.substring(0, length);
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
