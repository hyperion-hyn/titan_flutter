import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:titan/src/basic/utils/hex_color.dart';
import 'package:titan/src/basic/widget/base_app_bar.dart';
import 'package:titan/src/components/wallet/wallet_component.dart';
import 'package:titan/src/pages/atlas_map/entity/atlas_message.dart';
import 'package:titan/src/pages/atlas_map/entity/map3_info_entity.dart';
import 'package:titan/src/pages/atlas_map/map3/map3_node_confirm_page.dart';
import 'package:titan/src/widget/all_page_state/all_page_state.dart';
import 'package:titan/src/widget/loading_button/click_oval_button.dart';
import 'map3_node_public_widget.dart';

class Map3NodePreEditPage extends StatefulWidget {
  final Map3InfoEntity map3infoEntity;
  Map3NodePreEditPage({this.map3infoEntity});

  @override
  _Map3NodePreEditState createState() => new _Map3NodePreEditState();
}

class _Map3NodePreEditState extends State<Map3NodePreEditPage> with WidgetsBindingObserver {
  AllPageState currentState = LoadingState();

  bool _isOpen = true;

  double minTotal = 0;
  double remainTotal = 0;
  int _managerSpendCount = 20;
  TextEditingController _rateCoinController = new TextEditingController();

  @override
  void initState() {
    _rateCoinController.text = "$_managerSpendCount";

    super.initState();
  }

  @override
  void didChangeMetrics() {
    super.didChangeMetrics();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: BaseAppBar(
        baseTitle: '下期预设',
      ),
      backgroundColor: Colors.white,
      body: _pageView(context),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }

  Widget _pageView(BuildContext context) {
    var activatedWallet = WalletInheritedModel.of(context).activatedWallet;
    var walletName = activatedWallet.wallet.keystore.name;

    var divider = Container(
      color: HexColor("#F4F4F4"),
      height: 8,
    );
    return Column(
      children: <Widget>[
        Expanded(
          child: BaseGestureDetector(
            context: context,
            child: CustomScrollView(
              slivers: <Widget>[
                SliverToBoxAdapter(
                  child: Container(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      _switchWidget(),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                        ),
                        child: Divider(
                          color: HexColor("#F2F2F2"),
                          height: 0.5,
                        ),
                      ),
                      _rateWidget(),
                      divider,
                      _tipsWidget(),
                    ]),
                  ),
                ),
              ],
            ),
          ),
        ),
        _confirmButtonWidget(),
      ],
    );
  }

  Widget _rateWidget() {
    return managerSpendWidget(context, _rateCoinController, reduceFunc: () {
      setState(() {
        _managerSpendCount--;
        if (_managerSpendCount < 1) {
          _managerSpendCount = 1;
        }

        _rateCoinController.text = "$_managerSpendCount";
      });
    }, addFunc: () {
      setState(() {
        _managerSpendCount++;
        if (_managerSpendCount > 20) {
          _managerSpendCount = 20;
        }
        _rateCoinController.text = "$_managerSpendCount";
      });
    });
  }

  Widget _switchWidget() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 10,
      ),
      child: Row(
        children: <Widget>[
          Text(
            "期满自动续约",
            style: TextStyle(
              color: HexColor("#333333"),
              fontSize: 16,
            ),
          ),
          Spacer(),
          Switch(
            value: _isOpen,
            activeColor: Theme.of(context).primaryColor,
            activeTrackColor: Theme.of(context).primaryColor,
            onChanged: (bool newValue) {
              setState(() {
                _isOpen = newValue;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _tipsWidget() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.only(left: 20.0, right: 20, bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(top: 16.0, bottom: 8),
            child: Text("注意事项", style: TextStyle(color: HexColor("#333333"), fontSize: 16)),
          ),
          rowTipsItem("管理费的设置根据抵押量来决定，抵押量越高管理费的最大值越高，(计算公式为：个人抵押量 / 55w x 100%）管理费最高不高于20%"),
        ],
      ),
    );
  }

  Widget _confirmButtonWidget() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 37, vertical: 18),
      child: ClickOvalButton(
        "确认修改",
        () async {
          var message = ConfirmPreEditMap3NodeMessage(
            autoRenew: _isOpen,
            feeRate: _rateCoinController?.text ?? "20",
            map3NodeAddress: widget.map3infoEntity.address,
          );
          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => Map3NodeConfirmPage(
                  message: message,
                ),
              ));
        },
        height: 46,
        width: MediaQuery.of(context).size.width - 37 * 2,
        fontSize: 18,
      ),
    );
  }
}