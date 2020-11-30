import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/material.dart';
import 'package:titan/src/pages/atlas_map/entity/reward_history_entity.dart';
import 'package:titan/src/plugins/wallet/convert.dart';

class SimpleLineChart extends StatelessWidget {
  final List<charts.Series> seriesList;
  final bool animate;
  final simpleCurrencyFormatter = charts.BasicNumericTickFormatterSpec((num value) => '${value.toInt()}%');

  SimpleLineChart(this.seriesList, {this.animate});

  /// Creates a [LineChart] with sample data and no transition.
  factory SimpleLineChart.withSampleData(List<RewardHistoryEntity> rewardHistoryList) {
    return new SimpleLineChart(
      _createSampleData(rewardHistoryList),
      animate: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return new charts.LineChart(
      seriesList,
      animate: animate,
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
        new charts.ChartTitle('年化奖励',
            titleStyleSpec: charts.TextStyleSpec(fontSize: 12),
            behaviorPosition: charts.BehaviorPosition.start,
            titleOutsideJustification:
            charts.OutsideJustification.middleDrawArea),
      ],
      primaryMeasureAxis: new charts.NumericAxisSpec(
        tickFormatterSpec: simpleCurrencyFormatter,
        tickProviderSpec: new charts.BasicNumericTickProviderSpec(desiredTickCount: 5),
        /*viewport: new charts.NumericExtents(0, 100)*/),
//      domainAxis: new charts.NumericAxisSpec(viewport: new charts.NumericExtents(5, 9)),
    );
  }

  /// Create one series with sample hard coded data.
  static List<charts.Series<LinearSales, int>> _createSampleData(List<RewardHistoryEntity> rewardHistoryList) {
    final data = List.generate(rewardHistoryList.length, (index) {
      var rewardItem = rewardHistoryList[index];
      var delegation = ConvertTokenUnit.weiToEther(weiBigInt: BigInt.parse(rewardItem.totalDelegation)).toInt();
//      if(index == (rewardHistoryList.length - 1)){
//        lastRewardOrdinal = OrdinalSales("${rewardItem.epoch}",delegation);
//      }
      return LinearSales(rewardItem.epoch,delegation);
    }).toList();

    /*final data = [
      new LinearSales(0, 50),
      new LinearSales(1, 25),
      new LinearSales(2, 100),
      new LinearSales(3, 75),
      new LinearSales(4, 46),
      new LinearSales(5, 22),
      new LinearSales(6, 17),
      new LinearSales(7, 74),
      new LinearSales(8, 33),
      new LinearSales(9, 97),
    ];*/

    return [
      new charts.Series<LinearSales, int>(
        id: 'Sales',
        colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
        domainFn: (LinearSales sales, _) => sales.year,
        measureFn: (LinearSales sales, _) => sales.sales,
        data: data,
      )
    ];
  }
}

/// Sample linear data type.
class LinearSales {
  final int year;
  final num sales;

  LinearSales(this.year, this.sales);
}