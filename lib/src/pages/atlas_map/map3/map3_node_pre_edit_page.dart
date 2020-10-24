import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:titan/generated/l10n.dart';
import 'package:titan/src/basic/utils/hex_color.dart';
import 'package:titan/src/basic/widget/base_app_bar.dart';
import 'package:titan/src/pages/atlas_map/api/atlas_api.dart';
import 'package:titan/src/pages/atlas_map/entity/atlas_message.dart';
import 'package:titan/src/pages/atlas_map/entity/map3_info_entity.dart';
import 'package:titan/src/pages/atlas_map/map3/map3_node_confirm_page.dart';
import 'package:titan/src/style/titan_sytle.dart';
import 'package:titan/src/utils/format_util.dart';
import 'package:titan/src/utils/utile_ui.dart';
import 'package:titan/src/widget/loading_button/click_oval_button.dart';
import 'map3_node_public_widget.dart';

class Map3NodePreEditPage extends StatefulWidget {
  final Map3InfoEntity map3infoEntity;
  Map3NodePreEditPage({this.map3infoEntity});

  @override
  _Map3NodePreEditState createState() => _Map3NodePreEditState();
}

class _Map3NodePreEditState extends State<Map3NodePreEditPage> with WidgetsBindingObserver {
  bool _isOpen = true;
  int _managerSpendCount = 20;
  TextEditingController _rateCoinController = TextEditingController();
  get _isJoiner => !widget.map3infoEntity.isCreator();

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
                      _isJoiner ? _rateWidgetJoiner() : _rateWidgetCreator(),
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

  Widget _rateWidgetJoiner() {
    var lastFeeRate = FormatUtil.formatPercent(double.parse(widget.map3infoEntity.getFeeRate()));

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 10,
      ),
      child: Row(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: RichText(
              text: TextSpan(
                  text: "下期管理费",
                  style: TextStyle(fontSize: 16, color: HexColor("#333333"), fontWeight: FontWeight.normal),
                  children: [
                    TextSpan(
                      text: "",
                      style: TextStyle(fontSize: 12, color: HexColor("#999999"), fontWeight: FontWeight.normal),
                    )
                  ]),
            ),
          ),
          Spacer(),
          RichText(
            text: TextSpan(
                text: lastFeeRate,
                style: TextStyle(fontSize: 16, color: HexColor("#333333"), fontWeight: FontWeight.normal),
                children: [
                  TextSpan(
                    text: "",
                    style: TextStyle(fontSize: 12, color: HexColor("#999999"), fontWeight: FontWeight.normal),
                  )
                ]),
          ),
        ],
      ),
    );
  }

  Widget _rateWidgetCreator() {
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
            _isJoiner ? "期满跟随续约" : "期满自动续约",
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
    var amount = " ${FormatUtil.formatTenThousandNoUnit(AtlasApi.map3introduceEntity?.startMin?.toString() ?? "0")}" +
        S.of(context).ten_thousand;
    var tip1 = "管理费的设置根据抵押量来决定，抵押量越高管理费的最大值越高，(计算公式为：个人抵押量 / $amount x 100%）管理费最高不高于20%";

    var tip2 = _isJoiner
        ? "期满跟随续约每个节点周期只能修改一次，修改完之后直到下个节点周期才能再次修改，请谨慎操作！"
        : "期满自动续约和管理费每个节点周期只能修改一次，修改完之后直到下个节点周期才能再次修改，请谨慎操作！";
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
          rowTipsItem(tip1),
          rowTipsItem(tip2),
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
        () {
          // todo: 管理费
          var text = _rateCoinController?.text ?? "0";
          var value = double.parse(text);
          if (value > 20 || value < 1) {
            _managerSpendCount = 20;
            _rateCoinController.text = "$_managerSpendCount";
          }

          showAlertView();
        },
        height: 46,
        width: MediaQuery.of(context).size.width - 37 * 2,
        fontSize: 18,
      ),
    );
  }

  showAlertView() {
    var feeRate = _rateCoinController?.text ?? "20";
    var contentPre = _isJoiner ? "开启期满跟随续约" : "开启期满自动续约";
    var content = contentPre + "，管理费设置为$feeRate%每个节点周期只能修改一次，确定修改吗？";
    UiUtil.showAlertView(
      context,
      title: "下期预设",
      actions: [
        ClickOvalButton(
          S.of(context).cancel,
          () {
            Navigator.pop(context);
          },
          width: 120,
          height: 32,
          fontSize: 14,
          fontColor: DefaultColors.color999,
          btnColor: Colors.transparent,
        ),
        SizedBox(
          width: 8,
        ),
        ClickOvalButton(
          "确定",
          () {
            var message = ConfirmPreEditMap3NodeMessage(
              autoRenew: _isOpen,
              feeRate: feeRate,
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
          width: 120,
          height: 38,
          fontSize: 16,
        ),
      ],
      content: content,
    );
  }
}
