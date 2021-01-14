import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:titan/generated/l10n.dart';
import 'package:titan/src/basic/utils/hex_color.dart';
import 'package:titan/src/basic/widget/load_data_container/bloc/bloc.dart';
import 'package:titan/src/basic/widget/load_data_container/load_data_container.dart';
import 'package:titan/src/pages/red_pocket/rp_receiver_success_page.dart';
import 'package:titan/src/pages/red_pocket/rp_share_open_page.dart';
import 'package:titan/src/pages/red_pocket/widget/fl_pie_chart.dart';
import 'package:titan/src/pages/red_pocket/widget/rp_airdrop_widget.dart';
import 'package:titan/src/pages/red_pocket/widget/rp_statistics_widget.dart';
import 'package:titan/src/style/titan_sytle.dart';
import 'package:titan/src/utils/utile_ui.dart';
import 'package:titan/src/widget/round_border_textfield.dart';

import 'atlas_map_widget.dart';
import 'clip_tab_bar.dart';
import 'loading_button/click_oval_button.dart';

class WidgetDemoPage extends StatefulWidget {
  WidgetDemoPage();

  @override
  State<StatefulWidget> createState() {
    return _WidgetDemoPageState();
  }
}

class _WidgetDemoPageState extends State<WidgetDemoPage>
    with SingleTickerProviderStateMixin {
  ///
  Widget child = Container();
  String content = '';
  bool isShow = false;

  LoadDataBloc _loadDataBloc = LoadDataBloc();
  final TextEditingController _textEditController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.black),
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Widget Demo',
          style: TextStyle(
            color: Colors.black,
          ),
        ),
      ),
      body: Container(
          width: double.infinity,
          height: double.infinity,
          child: LoadDataContainer(
            bloc: _loadDataBloc,
            enablePullUp: false,
            onLoadData: () async {
              _loadDataBloc.add(RefreshSuccessEvent());
              setState(() {});
            },
            onRefresh: () async {
              _loadDataBloc.add(RefreshSuccessEvent());
              setState(() {});
            },
            child: CustomScrollView(
              physics: BouncingScrollPhysics(),
              slivers: <Widget>[
                _statisticsWidget(),
                SliverToBoxAdapter(
                  child: FlatButton(onPressed: (){
                    showShareRpOpenDialog(context,id: "6RYWNG");
                  }, child: Text("分享红包"),color: DefaultColors.color999,),
                ),
                SliverToBoxAdapter(
                  child: FlatButton(onPressed: (){
                    _showStakingAlertView();
                  }, child: Text("口令弹窗"),color: DefaultColors.color999,),
                ),
                SliverToBoxAdapter(
                  child: FlatButton(onPressed: (){
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (BuildContext context) => RpReceiverSuccessPage(
                          null
                      ),
                    ));
                  }, child: Text("红包详情"),color: DefaultColors.color999,),
                ),
              ],
            ),
          )),
    );
  }

  Future<String> _showStakingAlertView() async {
    _textEditController.text = "";

    String rpSecret = await UiUtil.showAlertViewNew<String>(
      context,
      actions: [
        ClickOvalButton(
          S.of(context).confirm,
          (){
            Navigator.pop(context,_textEditController.text);
          },
          width: 200,
          height: 38,
          fontSize: 16,
          fontWeight: FontWeight.normal,
        ),
      ],
      contentWidget: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top:19,bottom:32.0),
            child: Text("输入红包口令",style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: HexColor("#333333"),
                decoration: TextDecoration.none)),
          ),
          Padding(
            padding: const EdgeInsets.only(left:24,right:24.0,bottom: 20),
            child: Material(
              child: Form(
                key: _formKey,
                child: RoundBorderTextField(
                  controller: _textEditController,
                  keyboardType: TextInputType.text,
                  inputFormatters: [
                    LengthLimitingTextInputFormatter(
                        20),
                  ],
                  hint: "请输入口令",
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  _statisticsWidget() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: _cardPadding(),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.all(Radius.circular(16.0)),
          ),
          child: Padding(
            padding: _cardPadding(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      '统计',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Spacer(),
                  ],
                ),
                RPStatisticsWidget(),
                SizedBox(
                  height: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  _cardPadding() {
    return const EdgeInsets.only(left: 16.0, right: 16.0, top: 16.0);
  }
}
