import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:titan/generated/l10n.dart';
import 'package:titan/src/basic/utils/hex_color.dart';
import 'package:titan/src/basic/widget/base_app_bar.dart';
import 'package:titan/src/basic/widget/base_state.dart';
import 'package:titan/src/components/quotes/quotes_component.dart';
import 'package:titan/src/components/wallet/wallet_component.dart';
import 'package:titan/src/config/application.dart';
import 'package:titan/src/config/consts.dart';
import 'package:titan/src/pages/atlas_map/entity/atlas_message.dart';
import 'package:titan/src/pages/atlas_map/entity/map3_info_entity.dart';
import 'package:titan/src/config/extends_icon_font.dart';
import 'package:titan/src/plugins/wallet/wallet_util.dart';
import 'package:titan/src/routes/fluro_convert_utils.dart';
import 'package:titan/src/routes/routes.dart';
import 'package:titan/src/utils/format_util.dart';
import 'package:titan/src/utils/log_util.dart';
import 'package:titan/src/utils/utile_ui.dart';
import 'package:titan/src/widget/loading_button/click_oval_button.dart';

class Map3NodeConfirmPage extends StatefulWidget {
  final AtlasMessage message;
  final AtlasMessage editMessage;

  Map3NodeConfirmPage({
    this.message,
    this.editMessage,
  });

  @override
  State<StatefulWidget> createState() {
    return _Map3NodeConfirmState();
  }
}

class _Map3NodeConfirmState extends BaseState<Map3NodeConfirmPage> {
  var _isTransferring = false;

  List<String> _titleList = ["From", "To", ""];
  List<String> _subList = [
    S.of(Keys.rootKey.currentContext).wallet,
    S.of(Keys.rootKey.currentContext).map3_node,
    S.of(Keys.rootKey.currentContext).gas_fee
  ];
  List<String> _detailList = ["*** (***…***)", "节点号: PB2020", "0.0000021 HYN"];
  String _pageTitle = "";
  String _amount = "0";
  String _amountDirection = "0";

  List<dynamic> _addressList = [];

  @override
  void initState() {
    super.initState();

    _addressList = widget?.message?.description?.addressList ?? [];
  }

  @override
  void onCreated() {
    super.onCreated();

    if (widget.message.description != null) {
      var desc = widget.message.description;

      _pageTitle = desc.title;
      _amount = desc.amount;
      _amountDirection = desc.amountDirection;

      var fromName = desc.fromName;
      var toName = desc.toName;
      _subList = [
        fromName,
        toName,
        S.of(context).gas_fee,
      ];

      var fromDetail = desc.fromDetail;
      var toDetail = desc.toDetail;
      var fee = desc.fee + " HYN";
      _detailList = [fromDetail, toDetail, fee];
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return !_isTransferring;
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: BaseAppBar(
          baseTitle: _pageTitle,
        ),
        body: _pageView(context),
      ),
    );
  }

  Widget _pageView(BuildContext context) {
    return Column(
      children: <Widget>[
        Expanded(
          child: CustomScrollView(
            slivers: <Widget>[
              SliverToBoxAdapter(
                child: Container(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    _headerWidget(),
                  ]),
                ),
              ),
              SliverToBoxAdapter(
                child: ListView.separated(
                  itemBuilder: (context, index) {
                    return _buildItem(index);
                  },
                  separatorBuilder: (context, index) {
                    return Divider(
                      height: 0.5,
                      color: HexColor("#F2F2F2"),
                    );
                  },
                  itemCount: _subList.length,
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                ),
              ),
            ],
          ),
        ),
        _confirmButtonWidget(),
      ],
    );
  }

  Widget _buildItem(int index) {
    var title = _titleList[index];
    var subTitle = _subList[index];
    var detail = _detailList[index];
    return Container(
      color: Colors.white,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 14, horizontal: 14),
        child: Row(
          children: <Widget>[
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                if (title.isNotEmpty)
                  Row(
                    children: <Widget>[
                      Text(
                        title,
                        style: TextStyle(color: HexColor("#999999"), fontSize: 14),
                      ),
                    ],
                  ),
                SizedBox(
                  height: 4,
                ),
                SizedBox(
                  height: 4,
                ),
                Row(
                  children: <Widget>[
                    Text(
                      subTitle,
                      style: TextStyle(color: HexColor("#333333"), fontSize: 14),
                    ),
                    SizedBox(
                      width: 8,
                    ),
                    Text(
                      detail,
                      style: TextStyle(color: HexColor("#999999"), fontSize: 14),
                    ),
                  ],
                ),
                if ((_addressList?.isNotEmpty ?? false) && index == 0)
                  Container(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      //mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: _addressList
                          .map((e) => Padding(
                                padding: const EdgeInsets.only(top: 8, bottom: 4),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: <Widget>[
                                    Text(WalletUtil.ethAddressToBech32Address(e),
                                        style: TextStyle(
                                          color: HexColor("#999999"),
                                          fontSize: 12,
                                        )),
                                  ],
                                ),
                              ))
                          .toList(),
                    ),
                  )
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _headerWidget() {
    var activatedQuoteSign = QuotesInheritedModel.of(context).activatedQuoteVoAndSign("HYN");
    var quotePrice = activatedQuoteSign?.quoteVo?.price ?? 1;
    var quoteSign = activatedQuoteSign?.sign?.sign ?? "￥";
    var amountValue = double.parse(_amount ?? '0');
    var price = amountValue * quotePrice;
    var priceFormat = FormatUtil.formatPrice(price);
    var priceValue = "≈ $quoteSign$priceFormat";

    //print("[confirm] amountValue:$amountValue, priceValue:$priceValue");

    return Row(
      children: <Widget>[
        Expanded(
          child: Container(
            //color: Color(0xFFF5F5F5),
            padding: const EdgeInsets.only(top: 24, bottom: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Icon(
                  ExtendsIconFont.send,
                  color: Theme.of(context).primaryColor,
                  size: 48,
                ),
                Visibility(
                  visible: _amount != "0",
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8),
                    child: Text(
                      "$_amountDirection${FormatUtil.formatPrice(double.parse(_amount ?? "0"))} HYN",
                      style: TextStyle(color: Color(0xFF252525), fontWeight: FontWeight.bold, fontSize: 20),
                    ),
                  ),
                ),
                Visibility(
                  visible: _amount != "0",
                  child: Text(
                    priceValue,
                    style: TextStyle(color: Color(0xFF9B9B9B), fontSize: 14),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _confirmButtonWidget() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 37, vertical: 18),
      child: ClickOvalButton(
        _isRunningTimer && _isTransferring? '提交中...(倒计时：$_timerActionCount秒)':S.of(context).submit,
        _isTransferring ? null : _action,
        height: 46,
        width: MediaQuery.of(context).size.width - 37 * 2,
        fontSize: 18,
        isLoading: _isTransferring,
      ),
    );
  }

  _showTimerAlert() {
    UiUtil.showAlertView(
      context,
      title: '操作提示',
      actions: [
        ClickOvalButton(
          "知道了",
          () {
            Navigator.pop(context);

            _confirmAction();
          },
          width: 160,
          height: 38,
          fontSize: 16,
          isLoading: _isRunningTimer,
        ),
      ],
      content: '首次设置需要较长时间，请稍后！',
    );
  }

  Timer _timer;
  var _timerActionCount = 10;
  var _isRunningTimer = false;
  _initTimer(VoidCallback callback) {
    _isRunningTimer = true;

    print("[confirm] _initTimer");
    ///refresh epoch
    ///
    _timer = Timer.periodic(Duration(seconds: 1), (t) {
      _timerActionCount--;
      if (_timerActionCount >= 0) {
        print("[timer] _timerActionCount-->:$_timerActionCount ");
        setState(() {

        });
      } else {
        _closeTimer();
        callback();
      }
    });
  }

  get needEditBLS {
    return (widget.editMessage != null &&
        (widget.editMessage is ConfirmEditMap3NodeMessage) &&
        (widget.message is ConfirmPreEditMap3NodeMessage));
  }

  _closeTimer() {
    print("[confirm] _closeTimer");

    _isRunningTimer = false;

    if (_timer != null && _timer.isActive) {
      _timer.cancel();
      _timer = null;
    }
  }


  _action() {
    if (needEditBLS) {
      _showTimerAlert();
    } else {
      _confirmAction();
    }
  }

  _confirmAction() async {
    setState(() {
      _isTransferring = true;
    });

    try {
      var activatedWallet = WalletInheritedModel.of(context).activatedWallet;
      var password = await UiUtil.showWalletPasswordDialogV2(context, activatedWallet.wallet);
      if (password == null) {
        setState(() {
          _isTransferring = false;
        });
        return;
      }

      if (needEditBLS) {
        var editResult = false;
        editResult = await widget.editMessage.action(password);
        print("Map3NodeConfirmPage -->type:${widget.editMessage.type}, editResult:$editResult");

        if (!editResult) {
          setState(() {
            _isTransferring = false;
          });
          return;
        } else {
          print("[Map3NodeConfirmPage]: 启动定时器， 1");

          _initTimer(() {
            _formalAction(password);
          });
        }
      } else {
        print("[Map3NodeConfirmPage]: 不用启动定时器， 2");

        _formalAction(password);
      }
    } catch (error) {
      setState(() {
        _isTransferring = false;
      });

      LogUtil.toastException(error);
    }
  }

  void _formalAction(String password) async {
    print("[Map3NodeConfirmPage]: 正式执行Message，Action。。。。");

    var result = await widget.message.action(password);
    print("Map3NodeConfirmPage -->type:${widget.message.type}, result:$result");

    if (result is String) {
      Map3InfoEntity map3infoEntity = Map3InfoEntity.onlyNodeId(result);
      map3infoEntity.status = 1;

      if (widget.message is ConfirmCreateMap3NodeMessage) {
        var activatedWallet = WalletInheritedModel.of(Keys.rootKey.currentContext).activatedWallet;
        var address = activatedWallet.wallet.getEthAccount().address;
        map3infoEntity.address = address;

        var messageEntity = widget.message as ConfirmCreateMap3NodeMessage;
        var payload = messageEntity.entity.payload;
        map3infoEntity.name = payload.name;
        map3infoEntity.nodeId = payload.nodeId;
        map3infoEntity.describe = payload.describe;
        map3infoEntity.region = payload.region;
        map3infoEntity.provider = payload.provider;
        map3infoEntity.staking = payload.staking;
        map3infoEntity.contact = payload.connect;
      }
      Application.router.navigateTo(
          context,
          Routes.map3node_broadcast_success_page +
              "?actionEvent=${widget.message.type}" +
              "&info=${FluroConvertUtils.object2string(map3infoEntity.toJson())}");
    } else if (result is List) {
      Map3InfoEntity map3infoEntity = Map3InfoEntity.onlyStaking(result[0], result[1]);

      Application.router.navigateTo(
          context,
          Routes.map3node_broadcast_success_page +
              "?actionEvent=${widget.message.type}" +
              "&info=${FluroConvertUtils.object2string(map3infoEntity.toJson())}");
    } else if (result is bool) {
      var isOK = result;
      if (isOK) {
        Application.router
            .navigateTo(context, Routes.map3node_broadcast_success_page + "?actionEvent=${widget.message.type}");
      } else {
        setState(() {
          _isTransferring = false;
        });
      }
    } else {
      setState(() {
        _isTransferring = false;
      });
    }
  }
}
