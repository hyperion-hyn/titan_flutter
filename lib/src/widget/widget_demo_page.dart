import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:pinput/pin_put/pin_put.dart';
import 'package:titan/src/basic/widget/load_data_container/bloc/bloc.dart';
import 'package:titan/src/basic/widget/load_data_container/load_data_container.dart';
import 'package:titan/src/pages/red_pocket/widget/fl_pie_chart.dart';
import 'package:titan/src/pages/red_pocket/widget/rp_airdrop_widget.dart';
import 'package:titan/src/pages/red_pocket/widget/rp_statistics_widget.dart';
import 'package:titan/src/pages/wallet/wallet_new_page/wallet_safe_lock.dart';

import 'atlas_map_widget.dart';
import 'clip_tab_bar.dart';

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

  final TextEditingController _pinPutController = TextEditingController();
  final FocusNode _pinPutFocusNode = FocusNode();

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
          child: Container(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                WalletSafeLock(),
              ],
            ),
          )),
    );
  }
}
