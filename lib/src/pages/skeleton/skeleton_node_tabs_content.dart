import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:titan/generated/l10n.dart';
import 'package:titan/src/config/application.dart';
import 'package:titan/src/config/consts.dart';
import 'package:titan/src/routes/routes.dart';
import 'package:titan/src/style/titan_sytle.dart';
import 'package:titan/src/widget/loading_button/click_oval_button.dart';

class SkeletonNodeTabsContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
        baseColor: Colors.grey[300],
        highlightColor: Colors.grey[100],
        enabled: true,
        child: Column(
          children: [
            _createNode(),
            _myNodes(),
            _myNodes(),
            Row(
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Container(
                    color: Colors.white,
                    child: Text(
                      S.of(context).node_list,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            _nodeDetailItem(),
            _nodeDetailItem(),
            _nodeDetailItem()
          ],
        ));
  }

  _createNode() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              ClipRRect(
                child: Container(
                  width: 80,
                  height: 80,
                  color: Colors.white,
                ),
                borderRadius: BorderRadius.circular(4.0),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  children: [
                    Container(
                      color: Colors.white,
                      width: double.infinity,
                      child: Text(
                        '---',
                        style: TextStyle(
                            fontSize: 12,
                            height: 1.7,
                            color: DefaultColors.color99000000),
                      ),
                    ),
                    SizedBox(
                      height: 8,
                    ),
                    Container(
                      color: Colors.white,
                      width: double.infinity,
                      child: Text(
                        '---',
                        style: TextStyle(
                            fontSize: 12,
                            height: 1.7,
                            color: DefaultColors.color99000000),
                      ),
                    ),
                    SizedBox(
                      height: 8,
                    ),
                    Container(
                      color: Colors.white,
                      width: double.infinity,
                      child: Text(
                        '---',
                        style: TextStyle(
                            fontSize: 12,
                            height: 1.7,
                            color: DefaultColors.color99000000),
                      ),
                    )
                  ],
                ),
              )
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 24.0, bottom: 0),
          child: Container(
            width: double.infinity,
            child: Row(
              children: <Widget>[
                Expanded(
                  flex: 1,
                  child: Container(),
                ),
                Expanded(
                  flex: 2,
                  child: ClickOvalButton(
                    S.of(Keys.rootKey.currentContext).atlas_create_node,
                    () {
                      Application.router.navigateTo(
                        Keys.rootKey.currentContext,
                        Routes.atlas_create_node_page,
                      );
                    },
                    fontSize: 16,
                    isDisable: true,
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Container(),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  _myNodes() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        SizedBox(
          height: 16,
        ),
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: 16.0,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Container(
                color: Colors.white,
                child: Text(
                  S.of(Keys.rootKey.currentContext).my_nodes,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              Spacer(),
              Container(
                color: Colors.white,
                child: Text(
                  '--------',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
        Container(
          height: 150,
          child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: 3,
              itemBuilder: (context, index) {
                return _nodeInfoItem(index);
              }),
        )
      ],
    );
  }

  _atlasNodeListView() {
    return SliverList(
        delegate: SliverChildBuilderDelegate(
      (context, index) {
        return _nodeDetailItem();
      },
      childCount: 3,
    ));
  }

  _nodeInfoItem(int index) {
    return Padding(
      padding: const EdgeInsets.only(
        top: 16.0,
        bottom: 8.0,
        left: 16.0,
      ),
      child: Stack(
        children: <Widget>[
          Container(
            width: 105,
            height: 120,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Container(),
          ),
        ],
      ),
    );
  }

  _nodeDetailItem() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 16.0,
        vertical: 8.0,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Container(
          height: 200,
          width: 500,
        ),
      ),
    );
  }
}
