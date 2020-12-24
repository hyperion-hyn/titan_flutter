import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:titan/src/basic/widget/load_data_container/bloc/bloc.dart';
import 'package:titan/src/basic/widget/load_data_container/load_data_container.dart';
import 'package:titan/src/pages/red_pocket/widget/fl_pie_chart.dart';
import 'package:titan/src/pages/red_pocket/widget/rp_airdrop_widget.dart';
import 'package:titan/src/pages/red_pocket/widget/rp_statistics_widget.dart';

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
  Widget child = Container();
  String content = '';
  bool isShow = false;

  LoadDataBloc _loadDataBloc = LoadDataBloc();

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
              ],
            ),
          )),
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
