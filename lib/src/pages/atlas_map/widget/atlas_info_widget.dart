import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:titan/generated/l10n.dart';
import 'package:titan/src/basic/utils/hex_color.dart';
import 'package:titan/src/components/atlas/atlas_component.dart';
import 'package:titan/src/config/application.dart';
import 'package:titan/src/pages/atlas_map/entity/enum_atlas_type.dart';
import 'package:titan/src/pages/atlas_map/entity/map3_info_entity.dart';
import 'package:titan/src/pages/atlas_map/map3/map3_node_public_widget.dart';
import 'package:titan/src/pages/node/model/map3_node_util.dart';
import 'package:titan/src/routes/fluro_convert_utils.dart';
import 'package:titan/src/routes/routes.dart';
import 'package:titan/src/style/titan_sytle.dart';
import 'package:titan/src/widget/wallet_widget.dart';

class AtlasInfoWidget extends StatefulWidget {

  AtlasInfoWidget();

  @override
  State<StatefulWidget> createState() {
    return _AtlasInfoWidgetState();
  }
}

class _AtlasInfoWidgetState extends State<AtlasInfoWidget> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        SizedBox(
          height: 32,
        ),
        Padding(
          padding:
          const EdgeInsets.symmetric(horizontal: 32.0, vertical: 16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Text(
                '${S.of(context).atlas_next_age}: ',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  shadows: [
                    BoxShadow(
                      offset: const Offset(1.0, 1.0),
                      blurRadius: 2.0,
                      spreadRadius: 2.0,
                    ),
                  ],
                ),
              ),
              Text(
                '${AtlasInheritedModel.of(context).remainBlockTillNextEpoch}',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  shadows: [
                    BoxShadow(
                      offset: const Offset(1.0, 1.0),
                      blurRadius: 2.0,
                      spreadRadius: 2.0,
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Expanded(
                child: Column(
                  children: <Widget>[
                    Text(
                      S.of(context).atlas_current_age,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(
                      height: 8.0,
                    ),
                    Text(
                      '${AtlasInheritedModel.of(context).committeeInfo?.epoch}',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                height: 20,
                width: 1,
                color: DefaultColors.color999,
              ),
              Expanded(
                child: Column(
                  children: <Widget>[
                    Text(
                      S.of(context).block_height,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(
                      height: 8.0,
                    ),
                    InkWell(
                      child: Text(
                        '${AtlasInheritedModel.of(context).committeeInfo?.blockNum}',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          //color: Colors.blue,
                          //decoration: TextDecoration.underline,
                        ),
                      ),
                      onTap: () {},
                    ),
                  ],
                ),
              ),
              Container(
                height: 20,
                width: 1,
                color: DefaultColors.color999,
              ),
              Expanded(
                child: Column(
                  children: <Widget>[
                    Text(
                      S.of(context).atlas_elected_nodes,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(
                      height: 8.0,
                    ),
                    Text(
                      '${AtlasInheritedModel.of(context).committeeInfo?.elected}',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                height: 20,
                width: 1,
                color: DefaultColors.color999,
              ),
              Expanded(
                child: Column(
                  children: <Widget>[
                    Text(
                      S.of(context).atlas_candidate_nodes,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(
                      height: 8.0,
                    ),
                    Text(
                      '${AtlasInheritedModel.of(context).committeeInfo?.candidate}',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
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


}
