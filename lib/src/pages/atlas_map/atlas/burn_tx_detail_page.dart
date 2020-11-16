import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:titan/src/basic/utils/hex_color.dart';
import 'package:titan/src/basic/widget/base_app_bar.dart';
import 'package:titan/src/pages/atlas_map/entity/burn_history.dart';
import 'package:titan/src/style/titan_sytle.dart';

class BurnTxDetailPage extends StatefulWidget {
  final BurnHistory _burnHistory;

  BurnTxDetailPage(this._burnHistory);

  @override
  State<StatefulWidget> createState() {
    return _BurnTxDetailPageState();
  }
}

class _BurnTxDetailPageState extends State<BurnTxDetailPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: BaseAppBar(
        baseTitle: '详情',
      ),
      body: Container(
        color: Colors.white,
        height: double.infinity,
        child: SingleChildScrollView(
          child: Container(),
        ),
      ),
    );
  }

}
