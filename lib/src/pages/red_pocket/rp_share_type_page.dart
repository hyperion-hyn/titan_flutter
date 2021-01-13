import 'package:flutter/material.dart';
import 'package:titan/generated/l10n.dart';
import 'package:titan/src/basic/utils/hex_color.dart';
import 'package:titan/src/basic/widget/base_app_bar.dart';
import 'package:titan/src/basic/widget/base_state.dart';
import 'package:titan/src/components/setting/setting_component.dart';
import 'package:titan/src/components/wallet/vo/wallet_vo.dart';
import 'package:titan/src/components/wallet/wallet_component.dart';
import 'package:titan/src/pages/red_pocket/rp_record_detail_page.dart';
import 'package:titan/src/pages/red_pocket/rp_share_edit_page.dart';
import 'package:titan/src/widget/loading_button/click_oval_button.dart';

class RpShareTypePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _RpShareTypePageState();
  }
}

class _RpShareTypePageState extends BaseState<RpShareTypePage> {

  final ScrollController _scrollController = ScrollController();
  WalletVo _walletVo;
  int _initIndex = 0;

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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: BaseAppBar(
        baseTitle: '选择红包类型',
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
                  index: _initIndex,
                ),
                _bottomImageList(),
              ],
            ),
          ),
        ),
        ClickOvalButton(
          S.of(context).next_step,
          (){
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => RpShareEditPage(
                  shareType: RedPocketShareType.values[_initIndex],
                ),
              ),
            );
          },
          btnColor: [HexColor("#FF4D4D"), HexColor("#FF0527")],
          fontSize: 16,
          width: 260,
          height: 42,
        ),
        SizedBox(
          height: 40,
        ),
      ],
    );
  }

  Widget _bottomImageList() {
    return Padding(
      padding: EdgeInsets.only(left: 16.0, bottom: 23, right: 16, top: 20),
      child: Container(
        // height: 125,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _createChildWidget(title: '新人红包', sutTitle: '赞好友', index: 0),
            SizedBox(
              width: 36,
            ),
            _createChildWidget(title: '位置红包', sutTitle: '在附近可领取', index: 1),
          ],
        ),
      ),
    );
  }

  Widget _createChildWidget({String title, String sutTitle, int index = 0}) {
    bool isSelected = _initIndex == index;

    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            InkWell(
              onTap: () {
                setState(() {
                  _initIndex = index;
                });
              },
              child: _createSelectedWidget(
                size: Size(80, 90),
                fontSize: 4,
                gap: 8,
                imageSize: 12,
                padding: 6,
                index: index,
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
              title,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: HexColor('#333333'),
              ),
            ),
            SizedBox(width: 4),
            Tooltip(
              verticalOffset: 16,
              margin: EdgeInsets.symmetric(horizontal: 32.0),
              padding: EdgeInsets.all(16.0),
              message: title,
              child: Image.asset(
                'res/drawable/ic_tooltip.png',
                width: 10,
                height: 10,
                color: HexColor('#1F81FF'),
              ),
            ),
          ],
        ),
        Text(
          sutTitle,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.normal,
            color: HexColor('#999999'),
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
        _initIndex == 0 ? '只有新人才能领取，领取后他将成为你的好友' : '只有在红包投放的位置附近才可以拼手气领取',
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
    int index = 0,
  }) {

    var language = SettingInheritedModel.of(context).languageCode;
    var suffix = language == 'zh'?'zh':'en';
    var typeName = index == 0 ? RpShareEditPage.shareTypeNormal:RpShareEditPage.shareTypeLocation;
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
                  '发的${index == 0 ? '新人' : '位置'}红包',
                  style: TextStyle(
                    fontSize: fontSize,
                    color: Colors.white,
                  ),
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
