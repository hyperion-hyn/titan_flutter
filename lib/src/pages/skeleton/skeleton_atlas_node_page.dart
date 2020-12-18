import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:titan/generated/l10n.dart';
import 'package:titan/src/basic/utils/hex_color.dart';
import 'package:titan/src/components/atlas/atlas_component.dart';
import 'package:titan/src/config/application.dart';
import 'package:titan/src/pages/atlas_map/atlas/atlas_node_detail_item.dart';
import 'package:titan/src/pages/atlas_map/map3/map3_node_public_widget.dart';
import 'package:titan/src/routes/routes.dart';
import 'package:titan/src/style/titan_sytle.dart';
import 'package:titan/src/widget/loading_button/click_oval_button.dart';

class SkeletonAtlasNodePage extends StatefulWidget {
  SkeletonAtlasNodePage();

  @override
  State<StatefulWidget> createState() {
    return SkeletonAtlasNodePageState();
  }
}

class SkeletonAtlasNodePageState extends State<SkeletonAtlasNodePage> {
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
                child: _atlasInfo(),
              ),
              SliverToBoxAdapter(
                child: _createNode(),
              ),
              SliverToBoxAdapter(
                child: _myNodes(),
              ),
              SliverToBoxAdapter(
                child: Row(
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: Container(
                        color: Colors.white,
                        child: Text(
                          '节点列表',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              _atlasNodeListView()
            ],
          )),
    );
  }

  _atlasInfo() {
    return Column(
      children: <Widget>[
        Padding(
          padding: EdgeInsets.all(16.0),
          child: _atlasMap(),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(
                child: Column(
                  children: <Widget>[
                    Container(
                      color: Colors.white,
                      child: Text(
                        '---------',
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                    SizedBox(
                      height: 8.0,
                    ),
                    Container(
                      color: Colors.white,
                      child: Text(
                        '-----',
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  children: <Widget>[
                    Container(
                      color: Colors.white,
                      child: Text(
                        '---------',
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                    SizedBox(
                      height: 8.0,
                    ),
                    Container(
                      color: Colors.white,
                      child: Text(
                        '-----',
                        style: TextStyle(fontSize: 12),
                      ),
                    )
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  children: <Widget>[
                    Container(
                      color: Colors.white,
                      child: Text(
                        '---------',
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                    SizedBox(
                      height: 8.0,
                    ),
                    Container(
                      color: Colors.white,
                      child: Text(
                        '-----',
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  children: <Widget>[
                    Container(
                      color: Colors.white,
                      child: Text(
                        '---------',
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                    SizedBox(
                      height: 8.0,
                    ),
                    Container(
                      color: Colors.white,
                      child: Text(
                        '------',
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        )
      ],
    );
  }

  _atlasMap() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16.0),
      child: Container(
        width: double.infinity,
        height: 162,
        color: Colors.white,
      ),
    );
  }

  _createNode() {
    return Column(
      children: [
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
                    S.of(context).atlas_create_node,
                    () {
                      Application.router.navigateTo(
                        context,
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
        Center(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              color: Colors.white,
              child: Text(
                S.of(context).not_open_please_wait,
                style: TextStyle(
                  fontSize: 12,
                  color: DefaultColors.color999,
                ),
              ),
            ),
          ),
        )
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
                  S.of(context).my_nodes,
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
      childCount: 10,
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
