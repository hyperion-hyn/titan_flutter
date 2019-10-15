import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:titan/src/business/discover/bloc/bloc.dart';
import 'package:titan/src/business/discover/dapp/encrypt_share/share_dialog.dart';
import 'package:titan/src/business/scaffold_map/bloc/bloc.dart';
import 'package:titan/src/global.dart';
import 'package:titan/src/model/poi.dart';
import 'package:titan/src/model/poi_interface.dart';

import 'event.dart';

class EncryptShare extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return EncryptShareState();
  }
}

class EncryptShareState extends State<EncryptShare> {
  IPoi selectedPoi;

  StreamSubscription streamSubscription;

  @override
  void initState() {
    super.initState();

//    //动态设置收缩高度
//    SchedulerBinding.instance.addPostFrameCallback((_) {
//      HeaderHeightNotification(height: 400).dispatch(context);
//    });

    streamSubscription = eventBus.on().listen(eventBusListener);
  }

  @override
  void dispose() {
    streamSubscription.cancel();
    super.dispose();
  }

  void eventBusListener(event) async {
    if (event is SelectedSharePoiEvent) {
      selectedPoi = event.poi;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ScaffoldMapBloc, ScaffoldMapState>(
      bloc: BlocProvider.of<ScaffoldMapBloc>(context),
      builder: (context, state) {
        return Stack(
          fit: StackFit.loose,
          children: <Widget>[
            Container(), //need a container to expand.
            //top bar
            if (state is! MapRouteState)
              Material(
                color: Colors.transparent,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: new LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [
                      Colors.black38,
                      Colors.transparent,
                    ]),
                  ),
                  padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).padding.top + 100,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Stack(
                      children: <Widget>[
                        Align(
                          child: InkWell(
                            onTap: () {
                              BlocProvider.of<DiscoverBloc>(context).dispatch(InitDiscoverEvent());
                            },
                            child: Ink(
                              padding: const EdgeInsets.only(left: 24.0, top: 8),
                              child: Text(
                                '关闭',
                                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
                              ),
                            ),
                          ),
                          alignment: Alignment.topLeft,
                        ),
                        Align(
                          alignment: Alignment.topRight,
                          child: Padding(
                            padding: const EdgeInsets.only(right: 16.0),
                            child: InkWell(
                              onTap: () async {
                                print('你将要加密 $selectedPoi');
                                if (selectedPoi != null) {
                                  var suc = await showDialog(
                                      context: context,
                                      builder: (context) {
                                        return ShareDialog(poi: selectedPoi);
                                      });
                                  //成功打开分享
                                  if (suc) {
                                    //关闭分享位置
//                                    BlocProvider.of<DiscoverBloc>(context).dispatch(InitDiscoverEvent());
                                    print('成功打开分享');
                                  }
                                }
                              },
                              child: Ink(
                                decoration: BoxDecoration(
                                    color: Theme.of(context).primaryColor,
                                    borderRadius: BorderRadius.all(Radius.circular(4))),
                                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                                child: Text(
                                  '开始加密',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
