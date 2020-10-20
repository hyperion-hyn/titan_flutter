import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/material.dart';

class SlidingViewportOnSelection extends StatelessWidget {
  final List<charts.Series> seriesList;
  final bool animate;

  SlidingViewportOnSelection(this.seriesList, {this.animate});

  /// Creates a [BarChart] with sample data and no transition.
  factory SlidingViewportOnSelection.withSampleData() {
    return new SlidingViewportOnSelection(
      _createSampleData(),
      animate: false,
    );
  }

  @override
  Widget build(BuildContext context) {
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
        new charts.ChartTitle('Bottom title text',
            titleStyleSpec: charts.TextStyleSpec(fontSize: 12),
            behaviorPosition: charts.BehaviorPosition.bottom,
            titleOutsideJustification:
            charts.OutsideJustification.middleDrawArea),
        new charts.ChartTitle('Start title',
            titleStyleSpec: charts.TextStyleSpec(fontSize: 12),
            behaviorPosition: charts.BehaviorPosition.start,
            titleOutsideJustification:
            charts.OutsideJustification.middleDrawArea),
        charts.SeriesLegend(entryTextStyle: charts.TextStyleSpec(fontSize: 12)),
      ],
      primaryMeasureAxis: new charts.NumericAxisSpec(
        tickProviderSpec: new charts.BasicNumericTickProviderSpec(desiredTickCount: 5),
        /*viewport: new charts.NumericExtents(0, 100)*/),
      // Set an initial viewport to demonstrate the sliding viewport behavior on
      // initial chart load.
      domainAxis: new charts.OrdinalAxisSpec(viewport: new charts.OrdinalViewport('2020', 5)),
    );
  }

  /// Create series list with multiple series
  static List<charts.Series<OrdinalSales, String>> _createSampleData() {
    final desktopSalesData = [
      new OrdinalSales('2014', 5),
      new OrdinalSales('2015', 25),
      new OrdinalSales('2016', 100),
      new OrdinalSales('2017', 75),
      new OrdinalSales('2018', 36),
      new OrdinalSales('2019', 85),
      new OrdinalSales('2020', 22),
      new OrdinalSales('2021', 15),
      new OrdinalSales('2022', 74),
    ];

    final tableSalesData = [
      new OrdinalSales('2014', 25),
      new OrdinalSales('2015', 50),
      new OrdinalSales('2016', 10),
      new OrdinalSales('2017', 20),
      new OrdinalSales('2018', 28),
      new OrdinalSales('2019', 50),
      new OrdinalSales('2020', 10),
      new OrdinalSales('2021', 2),
      new OrdinalSales('2022', 27),
    ];

    return [
      new charts.Series<OrdinalSales, String>(
        id: 'Desktop',
        domainFn: (OrdinalSales sales, _) => sales.year,
        measureFn: (OrdinalSales sales, _) => sales.sales,
        data: desktopSalesData,
      ),
      new charts.Series<OrdinalSales, String>(
        id: 'Tablet',
        domainFn: (OrdinalSales sales, _) => sales.year,
        measureFn: (OrdinalSales sales, _) => sales.sales,
        data: tableSalesData,
      ),
    ];
  }
}

/// Sample ordinal data type.
class OrdinalSales {
  final String year;
  final int sales;

  OrdinalSales(this.year, this.sales);
}