import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:titan/src/basic/widget/base_state.dart';
import 'package:titan/src/components/scaffold_map/bloc/bloc.dart';
import 'package:titan/src/components/updater/bloc/bloc.dart';
import 'package:titan/src/config/application.dart';
import 'package:titan/src/config/consts.dart';
import 'package:titan/src/pages/home/home_panel.dart';
import 'package:titan/src/pages/news/info_detail_page.dart';
import 'package:titan/src/pages/node/model/contract_node_item.dart';
import 'package:titan/src/pages/node/model/node_item.dart';
import 'package:titan/src/plugins/titan_plugin.dart';
import 'package:titan/src/routes/fluro_convert_utils.dart';
import 'package:titan/src/routes/routes.dart';
import '../../widget/draggable_scrollable_sheet.dart' as myWidget;

class HomePage extends StatefulWidget {

  Function function;
  bool homePageFirst;

  HomePage(this.homePageFirst, this.function, {Key key}) : super(key: key);

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends BaseState<HomePage> {

  @override
  void onCreated() async {
    await Future.delayed(Duration(milliseconds: 3000));
    BlocProvider.of<UpdateBloc>(context).add(CheckUpdate(lang: Localizations.localeOf(context).languageCode));
    super.onCreated();
  }

  @override
  Widget build(BuildContext context) {
    widget.function();
    return myWidget.DraggableScrollableActuator(
        child: BlocListener<ScaffoldMapBloc, ScaffoldMapState>(
          listener: (context, state) {
            if (state is DefaultScaffoldMapState) {
              myWidget.DraggableScrollableActuator.setMin(context);
            } else {
              myWidget.DraggableScrollableActuator.setHide(context);
            }
          },
          child: BlocBuilder<ScaffoldMapBloc, ScaffoldMapState>(builder: (context, state) {
            return LayoutBuilder(builder: (context, constraints) {
              return Stack(
                children: <Widget>[
                  buildMainSheetPanel(context, constraints),
                ],
              );
            });
          }),
        ),
      );
  }

  Widget buildMainSheetPanel(context, boxConstraints) {
    double maxHeight = boxConstraints.biggest.height;
    double anchorSize = 0.5;
    double minChildSize = 88.0 / maxHeight;
    double initSize = widget.homePageFirst ? 0.5 : minChildSize;
    EdgeInsets mediaPadding = MediaQuery.of(context).padding;
    double maxChildSize = (maxHeight - mediaPadding.top) / maxHeight;
    //hack, why maxHeight == 0 for the first time of release???
    if (maxHeight == 0.0) {
      return Container();
    }
    return myWidget.DraggableScrollableSheet(
      key: Keys.homePanelKey,
      maxHeight: maxHeight,
      maxChildSize: maxChildSize,
      expand: true,
      minChildSize: minChildSize,
      anchorSize: anchorSize,
      initialChildSize: initSize,
      draggable: true,
      builder: (BuildContext ctx, ScrollController scrollController) {
        return HomePanel(scrollController: scrollController);
      },
    );
  }
}
