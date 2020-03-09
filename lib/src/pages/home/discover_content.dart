import 'package:flutter/material.dart';
import 'package:titan/src/pages/discover/discover_page.dart';

class DiscoverContentWidget extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _DiscoverContentState();
  }
}

class _DiscoverContentState extends State<DiscoverContentWidget> {
  @override
  Widget build(BuildContext context) {
    return DiscoverPageWidget();
  }
}
