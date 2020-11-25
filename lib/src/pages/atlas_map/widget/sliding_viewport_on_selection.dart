import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/material.dart';
import 'package:charts_common/common.dart';
import 'package:titan/src/pages/atlas_map/entity/reward_history_entity.dart';
import 'package:titan/src/plugins/wallet/convert.dart';

class SlidingViewportOnSelection extends StatelessWidget {
  final List<charts.Series> seriesList;
  final bool animate;
  static OrdinalSales lastRewardOrdinal;

  SlidingViewportOnSelection(this.seriesList, {this.animate});

  /// Creates a [BarChart] with sample data and no transition.
  factory SlidingViewportOnSelection.withSampleData(List<RewardHistoryEntity> rewardHistoryList) {
    return new SlidingViewportOnSelection(
      _createSampleData(rewardHistoryList),
      animate: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    print("!!!!333 ${lastRewardOrdinal.year}   ${lastRewardOrdinal.sales}");
    return new charts.BarChart(
      seriesList,
      animate: animate,
      barGroupingType: charts.BarGroupingType.stacked,
      defaultInteractions: false,
      behaviors: [
        new charts.SlidingViewport(),
        new charts.PanBehavior(),
        /*new charts.ChartTitle('Top title text',
            titleStyleSpec: charts.TextStyleSpec(fontSize: 12),
            behaviorPosition: charts.BehaviorPosition.top,
            titleOutsideJustification: charts.OutsideJustification.start,
            // Set a larger inner padding than the default (10) to avoid
            // rendering the text too close to the top measure axis tick label.
            // The top tick label may extend upwards into the top margin region
            // if it is located at the top of the draw area.
            innerPadding: 18),*/
        new charts.ChartTitle('纪元',
            titleStyleSpec: charts.TextStyleSpec(fontSize: 12),
            behaviorPosition: charts.BehaviorPosition.bottom,
            titleOutsideJustification:
            charts.OutsideJustification.middleDrawArea),
        new charts.ChartTitle('抵押量',
            titleStyleSpec: charts.TextStyleSpec(fontSize: 12),
            behaviorPosition: charts.BehaviorPosition.start,
            titleOutsideJustification:
            charts.OutsideJustification.middleDrawArea),
//        charts.SeriesLegend(entryTextStyle: charts.TextStyleSpec(fontSize: 12)),
      ],
      primaryMeasureAxis: new charts.NumericAxisSpec(
        tickProviderSpec: new charts.BasicNumericTickProviderSpec(desiredTickCount: 5),
        /*viewport: new charts.NumericExtents(0, 100)*/),
      // Set an initial viewport to demonstrate the sliding viewport behavior on
      // initial chart load.
        domainAxis: new charts.OrdinalAxisSpec(viewport: new charts.OrdinalViewport(lastRewardOrdinal.year, 6)),
//      domainAxis: new charts.OrdinalAxisSpec(viewport: new charts.OrdinalViewport('2020', 5)),
    );
  }

  /// Create series list with multiple series
  static List<charts.Series<OrdinalSales, String>> _createSampleData(List<RewardHistoryEntity> rewardHistoryList) {

    final desktopSalesData = List.generate(rewardHistoryList.length, (index) {
      var rewardItem = rewardHistoryList[index];
      var delegation = ConvertTokenUnit.weiToEther(weiBigInt: BigInt.parse(rewardItem.totalDelegation)).toInt();
      print("!!!!22 ${rewardItem.epoch}   $delegation");
      if(index == (rewardHistoryList.length - 1)){
        lastRewardOrdinal = OrdinalSales("${rewardItem.epoch}",delegation);
      }
      return OrdinalSales("${rewardItem.epoch}",delegation);
    }).toList();

    /*final desktopSalesData = [
      new OrdinalSales('18394', 58908907),
      new OrdinalSales('18393', 2567866),
      new OrdinalSales('18392', 106856785670),
      new OrdinalSales('18391', 7786785),
      new OrdinalSales('18390', 35585858586),
      new OrdinalSales('18389', 7886885),
      new OrdinalSales('18388', 258585858582),
      new OrdinalSales('18387', 17885),
      new OrdinalSales('18386', 75444444),
    ];*/

    /*final tableSalesData = [
      new OrdinalSales('2014', 25),
      new OrdinalSales('2015', 50),
      new OrdinalSales('2016', 10),
      new OrdinalSales('2017', 20),
      new OrdinalSales('2018', 28),
      new OrdinalSales('2019', 50),
      new OrdinalSales('2020', 10),
      new OrdinalSales('2021', 2),
      new OrdinalSales('2022', 27),
    ];*/

    return [
      new charts.Series<OrdinalSales, String>(
        id: '节点总抵押',
        domainFn: (OrdinalSales sales, _) => sales.year,
        measureFn: (OrdinalSales sales, _) => sales.sales,
        data: desktopSalesData,
      ),
      /*new charts.Series<OrdinalSales, String>(
        id: '发起者抵押量',
        domainFn: (OrdinalSales sales, _) => sales.year,
        measureFn: (OrdinalSales sales, _) => sales.sales,
        data: tableSalesData,
      ),*/
    ];
  }
}

/// Sample ordinal data type.
class OrdinalSales {
  final String year;
  final int sales;

  OrdinalSales(this.year, this.sales);
}