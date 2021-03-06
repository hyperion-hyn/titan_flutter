import 'package:flutter/material.dart';
import 'package:mapbox_gl/mapbox_gl.dart';
import 'package:titan/generated/l10n.dart';
import 'package:titan/src/basic/utils/hex_color.dart';
import 'package:titan/src/basic/widget/base_app_bar.dart';
import 'package:titan/src/basic/widget/base_state.dart';
import 'package:titan/src/components/scaffold_map/map.dart';
import 'package:titan/src/components/setting/setting_component.dart';
import 'package:titan/src/components/wallet/vo/wallet_view_vo.dart';
import 'package:titan/src/components/wallet/wallet_component.dart';
import 'package:titan/src/config/consts.dart';
import 'package:titan/src/pages/red_pocket/entity/rp_util.dart';
import 'package:titan/src/pages/red_pocket/rp_record_detail_page.dart';
import 'package:titan/src/pages/red_pocket/rp_share_edit_info_page.dart';
import 'package:titan/src/widget/loading_button/click_oval_button.dart';

class RpShareSelectTypePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _RpShareSelectTypePageState();
  }
}

class _RpShareSelectTypePageState extends BaseState<RpShareSelectTypePage> {
  final ScrollController _scrollController = ScrollController();
  WalletViewVo _walletVo;

  RpShareTypeEntity _selectedEntity;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  void onCreated() {
    super.onCreated();

    _setupData();
  }

  _setupData() {
    _walletVo = WalletInheritedModel.of(context).activatedWallet;
    _selectedEntity = _selectedEntity = SupportedShareType.normal();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: BaseAppBar(
        baseTitle: S.of(context).rp_type_title,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      ),
      body: _body(context),
    );
  }

  Widget _body(BuildContext context) {
    return Column(
      children: <Widget>[
        Expanded(
          child: SingleChildScrollView(
            controller: _scrollController,
            child: Column(
              children: [
                _titleWidget(),
                _createSelectedWidget(
                  size: Size(220, 300),
                  fontSize: 14,
                  entity: _selectedEntity,
                ),
                _bottomImageList(),
              ],
            ),
          ),
        ),
        _confirmButtonWidget(),
        SizedBox(
          height: 40,
        ),
      ],
    );
  }

  Widget _confirmButtonWidget() {
    return ClickOvalButton(
      S.of(context).next_step,
      () async {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => RpShareEditInfoPage(
              shareTypeEntity: _selectedEntity,
            ),
          ),
        );
      },
      fontColor: Colors.white,
      btnColor: [HexColor("#FF4D4D"), HexColor("#FF0527")],
      fontSize: 16,
      width: 260,
      height: 42,
    );
  }

  Future<LatLng> getLatlng() async {
    var latlng = await (Keys.mapContainerKey.currentState as MapContainerState)
        ?.mapboxMapController
        ?.lastKnownLocation();
    return latlng;
  }

  Widget _bottomImageList() {
    return Padding(
      padding: EdgeInsets.only(left: 8.0, bottom: 23, right: 8, top: 20),
      child: Container(
        // height: 125,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _createChildWidget(entity: SupportedShareType.normal()),
            SizedBox(
              width: 36,
            ),
            _createChildWidget(entity: SupportedShareType.location()),
          ],
        ),
      ),
    );
  }

  Widget _createChildWidget({RpShareTypeEntity entity}) {
    bool isSelected = _selectedEntity.index == entity.index;

    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            InkWell(
              onTap: () {
                setState(() {
                  _selectedEntity = entity;
                });
              },
              child: _createSelectedWidget(
                size: Size(80, 90),
                fontSize: 4,
                gap: 8,
                imageSize: 12,
                padding: 6,
                entity: entity,
              ),
            ),
            if (isSelected)
              Container(
                width: 70,
                height: 90,
                color: HexColor('#000000').withOpacity(0.3),
              ),
            if (isSelected)
              Image.asset(
                'res/drawable/rp_share_checked.png',
                width: 20,
                height: 20,
                //color: HexColor('#1F81FF'),
              )
          ],
        ),
        SizedBox(
          height: 10,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              entity.fullNameZh,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: HexColor('#333333'),
              ),
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.only(
            top: 4,
          ),
          child: Text(
            entity.desc,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.normal,
              color: HexColor('#999999'),
            ),
          ),
        ),
      ],
    );
  }

  Widget _titleWidget() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        36,
        12,
        36,
        20,
      ),
      child: Text(
        _selectedEntity.fullDesc,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: HexColor('#333333'),
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _createSelectedWidget({
    Size size,
    double fontSize,
    double gap = 28,
    double imageSize = 44,
    double padding = 0,
    RpShareTypeEntity entity,
  }) {
    var language = SettingInheritedModel.of(context).languageCode;
    var suffix = language == 'zh' ? 'zh' : 'en';
    var typeName = entity.nameEn;
    var imageName = 'rp_share_${typeName}_$suffix';
    return Container(
      width: size.width,
      height: size.height,
      padding: EdgeInsets.all(padding),
      child: Stack(
        children: <Widget>[
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(
                  'res/drawable/$imageName.png',
                ),
                fit: BoxFit.contain,
              ),
            ),
          ),
          Container(
            width: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                SizedBox(
                  height: gap,
                ),
                Container(
                  width: imageSize,
                  height: imageSize,
                  decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(width: 2, color: Colors.transparent),
                      image: DecorationImage(
                        image: AssetImage("res/drawable/app_invite_default_icon.png"),
                        fit: BoxFit.cover,
                      )),
                ),
                Padding(
                  padding: EdgeInsets.only(top: gap * 0.5, bottom: gap * 0.25, left: 15, right: 15),
                  child: RichText(
                    text: TextSpan(
                      text: "${_walletVo.wallet.keystore.name}  ",
                      style: TextStyle(
                        fontSize: fontSize,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                Text(
                  S.of(context).rp_type_nickname(entity.fullNameZh),
                  style: TextStyle(
                    fontSize: fontSize,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                Spacer(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
