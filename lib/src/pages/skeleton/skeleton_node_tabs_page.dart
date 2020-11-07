import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:titan/generated/l10n.dart';
import 'package:titan/src/config/application.dart';
import 'package:titan/src/routes/routes.dart';
import 'package:titan/src/style/titan_sytle.dart';
import 'package:titan/src/widget/loading_button/click_oval_button.dart';

class SkeletonNodeTabsPage extends StatefulWidget {
  SkeletonNodeTabsPage();

  @override
  State<StatefulWidget> createState() {
    return SkeletonNodeTabsPageState();
  }
}

class SkeletonNodeTabsPageState extends State<SkeletonNodeTabsPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Shimmer.fromColors(
          baseColor: Colors.grey[300],
          highlightColor: Colors.grey[100],
          enabled: true,
          child: CustomScrollView(
            physics: NeverScrollableScrollPhysics(),
            slivers: <Widget>[
              SliverToBoxAdapter(
                child: _roundContainer(150),
              ),
              SliverToBoxAdapter(
                child: _roundContainer(600),
              ),
            ],
          )),
    );
  }

  _roundContainer(double height) {
    return Padding(
      padding: const EdgeInsets.only(
        top: 16.0,
        left: 16.0,
        right: 16.0,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16.0),
        child: Container(
          width: double.infinity,
          height: height,
          color: Colors.white,
        ),
      ),
    );
  }
}
