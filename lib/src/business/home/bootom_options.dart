import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:titan/generated/i18n.dart';
import 'package:titan/src/model/poi.dart';
import 'package:titan/src/widget/draggable_bottom_sheet_controller.dart';

import '../../global.dart';
import 'bloc/bloc.dart';

class BottomOptions extends StatelessWidget {

  final GlobalKey optKey = GlobalKey(debugLabel: 'optKey');

  BottomOptions(){
    SchedulerBinding.instance.addPostFrameCallback((_) {
      print('BottomOptions height ${getHeaderHeight()}');
    });
  }

  double getHeaderHeight() {
    RenderBox renderBox = optKey.currentContext?.findRenderObject();
    return renderBox?.size?.height ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder(
      bloc: BlocProvider.of<HomeBloc>(context),
      builder: (context, state) {
        return Visibility(
          key: optKey,
          visible: (state is BottomSheetState) &&
              state.state != null &&
              state.state != DraggableBottomSheetState.HIDDEN &&
              (state.selectedPoi is PoiEntity),
          child: Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Material(
              elevation: 2,
              child: Column(
                children: <Widget>[
                  Divider(
                    height: 0,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 8, bottom: 8, left: 16, right: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: <Widget>[
                        Container(
                          color: Colors.red,
                          height: 28,
                          child: MaterialButton(
                            elevation: 0,
                            highlightElevation: 0,
                            minWidth: 60,
                            color: Colors.black,
                            textColor: Color(0xddffffff),
                            padding: EdgeInsets.symmetric(horizontal: 8),
                            child: Row(
                              children: <Widget>[
                                Icon(
                                  Icons.directions,
                                  color: Color(0xddffffff),
                                  size: 15,
                                ),
                                SizedBox(
                                  width: 4,
                                ),
                                Text(
                                  S.of(context).route,
                                  style: TextStyle(fontSize: 14),
                                )
                              ],
                            ),
                            onPressed: () async {
                              eventBus.fire(RouteClickEvent());
                            },
                          ),
                        ),
                        SizedBox(
                          width: 16,
                        ),
                        Container(
                          color: Colors.red,
                          height: 28,
                          child: MaterialButton(
                            elevation: 0,
                            highlightElevation: 0,
                            minWidth: 60,
                            onPressed: () {},
                            color: Colors.black,
                            padding: EdgeInsets.symmetric(horizontal: 8),
                            textColor: Color(0xddffffff),
                            child: Row(
                              children: <Widget>[
                                Icon(
                                  Icons.share,
                                  color: Color(0xddffffff),
                                  size: 15,
                                ),
                                SizedBox(
                                  width: 4,
                                ),
                                Text(
                                  '分享',
                                  style: TextStyle(fontSize: 14),
                                )
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).padding.bottom > 0 ? safeAreaBottomPadding : 0,
                  )
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
