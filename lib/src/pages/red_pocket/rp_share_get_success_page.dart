import 'package:decimal/decimal.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:titan/generated/l10n.dart';
import 'package:titan/src/basic/utils/hex_color.dart';
import 'package:titan/src/basic/widget/base_state.dart';
import 'package:titan/src/basic/widget/load_data_container/bloc/bloc.dart';
import 'package:titan/src/basic/widget/load_data_container/load_data_container.dart';
import 'package:titan/src/components/wallet/wallet_component.dart';
import 'package:titan/src/config/consts.dart';
import 'package:titan/src/pages/atlas_map/api/atlas_api.dart';
import 'package:titan/src/pages/atlas_map/map3/map3_node_public_widget.dart';
import 'package:titan/src/pages/red_pocket/entity/rp_share_req_entity.dart';
import 'package:titan/src/pages/red_pocket/rp_share_send_success_page.dart';
import 'package:titan/src/pages/wallet/wallet_show_account_info_page.dart';
import 'package:titan/src/plugins/wallet/token.dart';
import 'package:titan/src/plugins/wallet/wallet_util.dart';
import 'package:titan/src/style/titan_sytle.dart';
import 'package:titan/src/utils/format_util.dart';
import 'package:titan/src/utils/log_util.dart';
import 'package:titan/src/utils/utile_ui.dart';
import 'package:titan/src/utils/utils.dart';
import 'package:titan/src/widget/all_page_state/all_page_state.dart';
import 'package:titan/src/widget/all_page_state/all_page_state_container.dart';
import 'package:titan/src/widget/common_page_view/empty_view.dart';
import 'package:titan/src/widget/loading_button/click_oval_button.dart';
import 'api/rp_api.dart';
import 'entity/rp_share_entity.dart';
import 'entity/rp_util.dart';
import 'package:titan/src/widget/all_page_state/all_page_state.dart' as allPage;

class RpShareGetSuccessPage extends StatefulWidget {
  final String id;
  final bool isOpenRpJump;

  RpShareGetSuccessPage(this.id, {this.isOpenRpJump = false});

  @override
  State<StatefulWidget> createState() {
    return _RpShareGetSuccessPageState();
  }
}

class _RpShareGetSuccessPageState extends BaseState<RpShareGetSuccessPage> {
  final RPApi _rpApi = RPApi();
  final LoadDataBloc _loadDataBloc = LoadDataBloc();

  RpShareEntity _shareEntity;
  RpShareOpenEntity myRpOpenEntity;
  TapGestureRecognizer _rpRecognizer;
  TapGestureRecognizer _hynRecognizer;

  String get _walletAddress =>
      WalletInheritedModel.of(Keys.rootKey.currentContext)?.activatedWallet?.wallet?.getEthAccount()?.address ?? "";

  bool get _isShowPwdBtn {
    // return true;

    var rpOwnerAddress = _shareEntity?.info?.address ?? '';

    return _walletAddress.isNotEmpty &&
        rpOwnerAddress.isNotEmpty &&
        _walletAddress.toLowerCase() == rpOwnerAddress.toLowerCase() &&
        (_shareEntity?.info?.hasPWD ?? false);
  }

  @override
  void initState() {
    super.initState();

    _rpRecognizer = TapGestureRecognizer()..onTap = _rpHandlePress;
    _hynRecognizer = TapGestureRecognizer()..onTap = _hynHandlePress;
  }

  void _rpHandlePress() {
    if ((myRpOpenEntity?.rpHash ?? "") == "") {
      return;
    }
    WalletShowAccountInfoPage.jumpToAccountInfoPage(
        context, myRpOpenEntity?.rpHash ?? '', SupportedTokens.HYN_RP_HRC30.symbol);
  }

  void _hynHandlePress() {
    if ((myRpOpenEntity?.hynHash ?? "") == "") {
      return;
    }
    WalletShowAccountInfoPage.jumpToAccountInfoPage(
        context, myRpOpenEntity?.hynHash ?? '', SupportedTokens.HYN_Atlas.symbol);
  }

  @override
  void dispose() {
    _rpRecognizer.dispose();
    _hynRecognizer.dispose();
    _loadDataBloc.close();
    super.dispose();
  }

  @override
  void onCreated() async {
    super.onCreated();

    _getNewBeeInfo();
  }

  void _getNewBeeInfo() async {
    try {
      var activeWallet = WalletInheritedModel.of(context)?.activatedWallet;
      var _address = activeWallet.wallet.getAtlasAccount().address;
      _shareEntity = await _rpApi.getNewBeeDetail(
        _address,
        id: widget.id,
      );
      if (_shareEntity?.info?.alreadyGot ?? false) {
        _shareEntity.details.forEach((element) {
          if (element.address.toLowerCase() == _address.toLowerCase()) {
            myRpOpenEntity = element;
          }
        });
      }
      setState(() {});
      _loadDataBloc.add(RefreshSuccessEvent());
      print("[$runtimeType] shareEntity:${_shareEntity.info.toJson()}");
    } catch (error) {
      _loadDataBloc.add(LoadFailEvent());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: HexColor('#FF0527'),
      body: _pageWidget(context),
    );
  }

  Widget _pageWidget(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        color: Colors.white,
        child: Stack(children: [
          Image.asset(
            "res/drawable/rp_receiver_detail_top.png",
            width: double.infinity,
            fit: BoxFit.fitHeight,
            height: 124,
          ),
          LoadDataContainer(
            bloc: _loadDataBloc,
            enablePullUp: false,
            onLoadData: () {
              _getNewBeeInfo();
            },
            onRefresh: () {
              _getNewBeeInfo();
            },
            onLoadingMore: () {
              _getNewBeeInfo();
            },
            child: CustomScrollView(
              slivers: <Widget>[
                _headWidget(),
                _listWidget(),
              ],
            ),
          ),
          InkWell(
            onTap: () {
              Navigator.of(context).pop();
            },
            child: Padding(
              padding: const EdgeInsets.only(top: 64, left: 16.0, right: 16, bottom: 16),
              child: Image.asset(
                "res/drawable/rp_receiver_success_arraw_back.png",
                width: 17,
                height: 17,
              ),
            ),
          ),
          if ((_shareEntity?.info?.rpType ?? "") == RpShareType.normal)
            Positioned(
              top: 64,
              right: 16,
              child: InkWell(
                onTap: () {
                  var info = _shareEntity.info;
                  RpShareReqEntity reqEntity = RpShareReqEntity.onlyId(info.id);
                  reqEntity.rpType = info.rpType;
                  reqEntity.greeting = info.greeting;
                  reqEntity.isNewBee = info.isNewBee;
                  reqEntity.count = info.total;
                  reqEntity.range = info.range;
                  reqEntity.location = info.location;
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => RpShareSendSuccessPage(
                        reqEntity: reqEntity,
                        actionType: 1,
                      ),
                    ),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Image.asset(
                    "res/drawable/node_share.png",
                    width: 17,
                    height: 17,
                    // fit: BoxFit.cover,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          if ((_shareEntity?.info?.rpType ?? "") == RpShareType.location)
            Positioned(
              top: 64,
              right: 16,
              child: Text(
                "${_shareEntity?.info?.range ?? ""}千米内可领取",
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.black.withOpacity(0.5),
                ),
              ),
            )
        ]),
      ),
    );
  }

  _headWidget() {
    if (_shareEntity == null) {
      return SliverToBoxAdapter(
        child: Container(),
      );
    }

    var total = '总${_shareEntity?.info?.total ?? ""}个红包； ';
    var amount = total + amountValueToString(hyn: _shareEntity?.info?.hynAmount, rp: _shareEntity?.info?.rpAmount);

    var hynValueMy = double?.tryParse(myRpOpenEntity?.hynAmount ?? "0") ?? 0;
    var rpValueMy = double?.tryParse(myRpOpenEntity?.rpAmount ?? "0") ?? 0;

    return SliverToBoxAdapter(
      child: Column(
        children: [
          Column(
            children: [
              Container(
                height: 134,
                color: Colors.transparent,
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 30,
                      height: 30,
                      margin: const EdgeInsets.only(right: 12.0),
                      decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          image: DecorationImage(
                            image: AssetImage("res/drawable/ic_rp_invite_friend_head_img_no_border.png"),
                            fit: BoxFit.cover,
                          )),
                    ),
                    Text(
                      "${_shareEntity?.info?.owner ?? ""}发的${(_shareEntity?.info?.rpType ?? "") == RpShareType.location ? "位置" : "新人"}红包",
                      style: TextStyle(fontSize: 18, color: HexColor("#333333"), fontWeight: FontWeight.bold),
                    ),
                    if (_isShowPwdBtn)
                      IconButton(
                        tooltip: '点击可获取红包口令',
                        icon: const Icon(
                          Icons.info,
                          size: 16,
                        ),
                        onPressed: () async {
                          try {
                            var walletVo = WalletInheritedModel.of(context).activatedWallet;
                            var wallet = walletVo.wallet;
                            var password = await UiUtil.showWalletPasswordDialogV2(context, wallet);
                            if (password == null) {
                              return;
                            }

                            var result = await _rpApi.getRpPwdInfo(
                              address: _walletAddress,
                              id: widget.id,
                              wallet: wallet,
                              password: password,
                            );
                            print("[$runtimeType] getRpPwdInfo, result:$result");

                            _showPwdDialog(password: result);
                          } catch (e) {
                            LogUtil.toastException(e);
                          }
                        },
                      ),
                  ],
                ),
              ),
              Text(
                ((_shareEntity?.info?.greeting ?? '')?.isNotEmpty ?? false) ? _shareEntity.info.greeting : '恭喜发财，大吉大利！',
                style: TextStyles.textC999S14,
              ),
              if ((_shareEntity?.info?.rpType ?? "") == RpShareType.location)
                Padding(
                  padding: const EdgeInsets.only(
                    top: 6.0,
                    left: 32,
                    right: 32,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        "res/drawable/check_in_location.png",
                        width: 10,
                        height: 14,
                      ),
                      SizedBox(
                        width: 6,
                      ),
                      Flexible(
                        child: Text(
                          "${_shareEntity?.info?.location ?? ""}",
                          style: TextStyles.textC999S12,
                        ),
                      )
                    ],
                  ),
                ),
              SizedBox(
                height: 26,
              ),
              if ((_shareEntity?.info?.alreadyGot ?? false) && myRpOpenEntity != null)
                Column(
                  // crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (rpValueMy > 0)
                          Flexible(
                            child: RichText(
                                textAlign: TextAlign.center,
                                text: TextSpan(
                                    text: getCoinAmount(myRpOpenEntity.rpAmount),
                                    style: TextStyle(
                                        fontSize: 28, color: HexColor("#D09100"), fontWeight: FontWeight.w500),
                                    recognizer: _rpRecognizer,
                                    children: [
                                      TextSpan(
                                        text: " RP",
                                        style: TextStyle(
                                            fontSize: 16, color: HexColor("#D09100"), fontWeight: FontWeight.normal),
                                        recognizer: _rpRecognizer,
                                      ),
                                    ])),
                          ),
                        if (rpValueMy > 0 && hynValueMy > 0)
                          Text(" + ",
                              style:
                                  TextStyle(fontSize: 30, color: HexColor("#333333"), fontWeight: FontWeight.normal)),
                        if (hynValueMy > 0)
                          Flexible(
                            child: RichText(
                                text: TextSpan(
                                    text: getCoinAmount(myRpOpenEntity.hynAmount),
                                    style: TextStyle(
                                        fontSize: 28, color: HexColor("#D09100"), fontWeight: FontWeight.w500),
                                    recognizer: _hynRecognizer,
                                    children: [
                                  TextSpan(
                                    text: " HYN",
                                    style: TextStyle(
                                        fontSize: 16, color: HexColor("#D09100"), fontWeight: FontWeight.normal),
                                    recognizer: _hynRecognizer,
                                  ),
                                ])),
                          ),
                      ],
                    ),
                    if (widget.isOpenRpJump)
                      Padding(
                        padding: const EdgeInsets.only(
                          top: 2.0,
                        ),
                        child: Text("已领取红包，请稍后查看钱包记录", style: TextStyles.textC333S12),
                      ),
                    Container(
                      margin: const EdgeInsets.only(top: 50.0),
                      height: 10,
                      color: HexColor("#F2F2F2"),
                    ),
                  ],
                ),
              Padding(
                padding: const EdgeInsets.only(top: 16, left: 16.0, right: 16),
                child: Row(
                  children: [
                    Text(
                      amount,
                      style: TextStyles.textC999S12,
                    ),
                    Spacer(),
                    Text(
                      "${FormatUtil.formatDate(_shareEntity?.info?.createdAt ?? "", isSecond: true)}",
                      style: TextStyles.textC999S12,
                    )
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  _showPwdDialog({String password = ''}) {
    UiUtil.showAlertView(
      context,
      title: '口令',
      actions: [
        ClickOvalButton(
          S.of(context).confirm,
          () {
            Navigator.pop(context);
          },
          width: 100,
          height: 30,
          fontSize: 12,
          fontWeight: FontWeight.normal,
          btnColor: [HexColor("#FF4D4D"), HexColor("#FF0527")],
        ),
      ],
      content: password,
    );
  }

  _listWidget() {
    if (_shareEntity == null) {
      return SliverToBoxAdapter(
        child: Container(),
      );
    }

    var childCount = _shareEntity?.details?.length ?? 0;
    if (childCount == 0) {
      return emptyListWidget(
        title: '暂无人认领',
        paddingTop: 100,
      );
    }

    return SliverList(
        delegate: SliverChildBuilderDelegate(
      (context, index) {
        var item = _shareEntity.details[index];

        var hynValue = double?.tryParse(item?.hynAmount ?? "0") ?? 0;
        var rpValue = double?.tryParse(item?.rpAmount ?? "0") ?? 0;

        print("hynValue:$hynValue, rpValue:$rpValue");

        return InkWell(
          onTap: () {
            AtlasApi.goToHynScanPage(context, item.address);
          },
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 21, left: 16, right: 16, bottom: 17),
                child: Row(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(
                        right: 10,
                      ),
                      child: iconWidget("", item.username, item.address, isCircle: true),
                    ),
                    Expanded(
                      child: Column(
                        children: <Widget>[
                          Row(
                            children: [
                              Text(
                                item.username,
                                style: TextStyle(
                                  color: HexColor("#333333"),
                                  fontSize: 16,
                                ),
                              ),
                              Spacer(),
                              //todo
                              if (rpValue > 0)
                                GestureDetector(
                                  onTap: () {
                                    WalletShowAccountInfoPage.jumpToAccountInfoPage(
                                        context, item?.rpHash ?? '', SupportedTokens.HYN_RP_HRC30.symbol);
                                  },
                                  child: Text(
                                    "${getCoinAmount(item.rpAmount)} RP",
                                    style: TextStyle(
                                      color: HexColor("#333333"),
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    maxLines: 3,
                                    textAlign: TextAlign.right,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),

                              if (rpValue > 0 && hynValue > 0)
                                Text(
                                  ", ",
                                  style: TextStyle(
                                    color: HexColor("#333333"),
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  maxLines: 3,
                                  textAlign: TextAlign.right,
                                  overflow: TextOverflow.ellipsis,
                                ),

                              if (hynValue > 0)
                                GestureDetector(
                                  onTap: () {
                                    WalletShowAccountInfoPage.jumpToAccountInfoPage(
                                        context, item?.hynHash ?? '', SupportedTokens.HYN_Atlas.symbol);
                                  },
                                  child: Text(
                                    "${getCoinAmount(item.hynAmount)} HYN",
                                    style: TextStyle(
                                      color: HexColor("#333333"),
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    maxLines: 3,
                                    textAlign: TextAlign.right,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.only(
                              top: 4,
                            ),
                            child: Row(
                              children: [
                                Text(
                                  shortBlockChainAddress(WalletUtil.ethAddressToBech32Address(item.address)),
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: HexColor('#999999'),
                                  ),
                                ),
                                Spacer(),
                                if (item.isBest)
                                  Text(
                                    "最佳",
                                    style: TextStyle(fontSize: 12, color: HexColor('#E8AC13')),
                                    textAlign: TextAlign.right,
                                  ),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Divider(
                height: 0.5,
                color: HexColor("#F2F2F2"),
                indent: 16,
                endIndent: 16,
              )
            ],
          ),
        );
      },
      childCount: childCount,
    ));
  }

  String getCoinAmount(String coinAmount) {
    if (coinAmount == null || coinAmount.isEmpty) {
      return "";
    }
    return FormatUtil.truncateDecimalNum(Decimal.parse(coinAmount), 4);
  }
}

String amountValueToString({String hyn, String rp}) {
  var hynAmount = '${hyn ?? ""} HYN';
  var hynValue = double?.tryParse(hyn ?? "0") ?? 0;

  var rpAmount = '${rp ?? ""} RP';
  var rpValue = double?.tryParse(rp ?? "0") ?? 0;

  var amount = '';
  if (rpValue > 0 && hynValue > 0) {
    amount = hynAmount + ', ' + rpAmount;
  } else {
    if (hynValue > 0) {
      amount = hynAmount;
    }

    if (rpValue > 0) {
      amount = rpAmount;
    }
  }
  return amount;
}
