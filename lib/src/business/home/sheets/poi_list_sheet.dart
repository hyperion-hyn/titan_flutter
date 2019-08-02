import 'package:flutter/widgets.dart';
import 'package:titan/src/model/poi_interface.dart';

class PoiListSheet extends StatelessWidget {
  final List<IPoi> pois;

  PoiListSheet({this.pois});

  @override
  Widget build(BuildContext context) {
    return Text('this is list ${pois.length}');
  }
}