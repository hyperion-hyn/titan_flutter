import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:titan/generated/l10n.dart';
import 'package:titan/src/basic/utils/hex_color.dart';
import 'package:titan/src/basic/widget/base_app_bar.dart';
import 'package:titan/src/basic/widget/base_state.dart';
import 'package:titan/src/components/quotes/model.dart';
import 'package:titan/src/components/quotes/quotes_component.dart';
import 'package:titan/src/components/wallet/wallet_component.dart';
import 'package:titan/src/config/application.dart';
import 'package:titan/src/pages/atlas_map/entity/atlas_message.dart';
import 'package:titan/src/pages/atlas_map/entity/map3_info_entity.dart';
import 'package:titan/src/pages/node/model/contract_node_item.dart';
import 'package:titan/src/config/extends_icon_font.dart';
import 'package:titan/src/routes/fluro_convert_utils.dart';
import 'package:titan/src/routes/routes.dart';
import 'package:titan/src/utils/format_util.dart';
import 'package:titan/src/utils/utile_ui.dart';
import 'package:titan/src/widget/loading_button/click_oval_button.dart';

class Map3NodeConfirmPage extends StatefulWidget {
  final AtlasMessage message;

  Map3NodeConfirmPage({
    this.message,
  });

  @override
  State<StatefulWidget> createState() {
    return _Map3NodeConfirmState();
  }
}

class _Map3NodeConfirmState extends BaseState<Map3NodeConfirmPage> {
  var _isTransferring = false;

  List<String> _titleList = ["From", "To", ""];
  List<String> _subList = ["钱包", "Map3节点", "矿工费"];
  List<String> _detailList = ["*** (***…***)", "节点号: PB2020", "0.0000021 HYN"];
  String _pageTitle = "";
  String _amount = "0";
  String _amountDirection = "0";

  @override
  void initState() {
    super.initState();
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
      _subList = [fromName, toName, "矿工费"];

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
                if (widget.message.description.addressList.isNotEmpty)
                  Container(
                    child: ListView.builder(
                      itemBuilder: (BuildContext context, int index) => Text(
                        widget.message.description.addressList[index],
                        style: TextStyle(
                          color: HexColor("#999999"),
                          fontSize: 12,
                        ),
                      ),
                      itemCount: widget.message.description.addressList.length,
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
    var quotePrice = activatedQuoteSign?.quoteVo?.price ?? 0;
    var quoteSign = activatedQuoteSign?.sign?.sign;
    var amountValue = double.parse(_amount ?? '0');
    var price = amountValue * quotePrice;
    var priceFormat = FormatUtil.formatPrice(price);
    var priceValue = "≈ $quoteSign$priceFormat";

    print("[confirm] amountValue:$amountValue, priceValue:$priceValue");

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
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8),
                  child: Text(
                    "$_amountDirection$_amount HYN",
                    style: TextStyle(color: Color(0xFF252525), fontWeight: FontWeight.bold, fontSize: 20),
                  ),
                ),
                Text(
                  priceValue,
                  style: TextStyle(color: Color(0xFF9B9B9B), fontSize: 14),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _confirmButtonWidget() {
    var activatedWallet = WalletInheritedModel.of(context).activatedWallet;

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 37, vertical: 18),
      child: ClickOvalButton(
        S.of(context).submit,
        () async {
          setState(() {
            _isTransferring = true;
          });

          try {
            var password = await UiUtil.showWalletPasswordDialogV2(context, activatedWallet.wallet);
            if (password == null) {
              setState(() {
                _isTransferring = false;
              });
              return;
            }
            var result = await widget.message.action(password);
            print("object --> result:$result");

            if (result is String) {
              Map3InfoEntity map3infoEntity = Map3InfoEntity.onlyNodeId(result);
              if (widget.message is ConfirmCreateMap3NodeMessage) {
                var messageEntity = widget.message as ConfirmCreateMap3NodeMessage;
                map3infoEntity.staking = messageEntity.entity.payload.staking;
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
                Application.router.navigateTo(
                    context, Routes.map3node_broadcast_success_page + "?actionEvent=${widget.message.type}");
              } else {
                setState(() {
                  _isTransferring = false;
                });
                Fluttertoast.showToast(msg: '操作失败');
              }
            } else {
              setState(() {
                _isTransferring = false;
              });
              Fluttertoast.showToast(msg: '操作失败');
            }
          } catch (error) {
            setState(() {
              _isTransferring = false;
            });
          }
        },
        height: 46,
        width: MediaQuery.of(context).size.width - 37 * 2,
        fontSize: 18,
      ),
    );
  }
}
