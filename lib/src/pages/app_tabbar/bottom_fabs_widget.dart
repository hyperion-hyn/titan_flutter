import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:titan/generated/l10n.dart';
import 'package:titan/src/basic/utils/hex_color.dart';
import 'package:titan/src/components/inject/injector.dart';
import 'package:titan/src/components/scaffold_map/bloc/bloc.dart';
import 'package:titan/src/config/application.dart';
import 'burning_dialog.dart';

class BottomFabsWidget extends StatefulWidget {
  final bool showBurnBtn;

  BottomFabsWidget({this.showBurnBtn, Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return BottomFabsWidgetState();
  }
}

class BottomFabsWidgetState extends State<BottomFabsWidget> {
  bool _isShow = true;

  void _clean(context) async {
    var searchInteractor = Injector.of(context).searchInteractor;
    searchInteractor.deleteAllHistory();

    BlocProvider.of<ScaffoldMapBloc>(context).add(DefaultMapEvent());

    await Future.delayed(Duration(milliseconds: 1500));
    Application.eventBus.fire(ToMyLocationEvent(zoom: 14));
  }

  void setVisible(bool isVisible) {
    if (_isShow != isVisible) {
      setState(() {
        _isShow = isVisible;
      });
    }
  }

  void _showFireModalBottomSheet(context) {
    showModalBottomSheet(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(15), topRight: Radius.circular(15))),
        context: context,
        builder: (ctx) {
          return Container(
//            decoration: BoxDecoration(
//            borderRadius: BorderRadius.only(topLeft: Radius.circular(15), topRight: Radius.circular(15)),),
            margin: EdgeInsets.only(top: 12, bottom: 31),
            child: new Wrap(
              children: <Widget>[
                InkWell(
                  onTap: () {
                    Navigator.pop(ctx);
                    showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return BurningDialog();
                        });
                    _clean(context);
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Row(children: <Widget>[
                      SizedBox(
                        width: 20,
                      ),
                      Image.asset(
                        'res/drawable/ic_home_clear.png',
                        width: 15,
                      ),
                      SizedBox(
                        width: 12,
                      ),
                      Text(
                        S.of(context).Clean,
                        style:
                            TextStyle(fontSize: 15, color: HexColor("#333333")),
                      ),
                    ]),
                  ),
                ),
                InkWell(
                  onTap: () {
                    Navigator.pop(ctx);
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
//                    padding: const EdgeInsets.only(top:5,bottom: 10,left: 10,right: 10),
                    child: Row(
                      children: <Widget>[
                        SizedBox(
                          width: 21,
                        ),
                        Image.asset(
                          'res/drawable/ic_close.png',
                          width: 12,
                        ),
                        SizedBox(
                          width: 15,
                        ),
                        Text(
                          S.of(context).cancel,
                          style: TextStyle(
                              fontSize: 15, color: HexColor("#333333")),
                        ),
                      ],
                    ),
                  ),
                )
                /*new ListTile(
                    leading: new Icon(Icons.vertical_align_bottom),
                    title: new Text(S.of(context).Clean,
                        style: TextStyle(color: Color(0xffac2229), fontWeight: FontWeight.w500)),
                    onTap: () {
                      Navigator.pop(ctx);
//                      Navigator.push(context, MaterialPageRoute(builder: (context) => BurningDialog()));
                      showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return BurningDialog();
                          });
                      _clean(context);
                    }),
                new ListTile(
                  leading: new Icon(Icons.close),
                  title: new Text(S.of(context).cancel),
                  onTap: () => Navigator.pop(ctx),
                ),*/
              ],
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    if (_isShow == true) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Column(
          children: [
            Row(
              children: [
                Spacer(),
                Container(
                  height: 40,
                  padding: EdgeInsets.symmetric(horizontal: 4),
                  child: Image.asset('res/drawable/ic_hyn_coin.png'),
                ),
              ],
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                if (widget.showBurnBtn == true)
                  FloatingActionButton(
                    onPressed: () => _showFireModalBottomSheet(context),
                    mini: true,
                    heroTag: 'cleanData',
                    backgroundColor: Colors.white,
                    child: Image.asset(
                      'res/drawable/ic_logo.png',
                      width: 24,
                      color: Colors.black87,
                    ),
                  ),
                Spacer(),
                FloatingActionButton(
                  onPressed: () {
                    Application.eventBus.fire(ToMyLocationEvent());
                    //BlocProvider.of<MapBloc>(context).add(MyLocationEvent());
                  },
                  mini: true,
                  heroTag: 'myLocation',
                  backgroundColor: Colors.white,
                  child: Icon(
                    Icons.my_location,
                    color: Colors.black87,
                    size: 24,
                  ),
                )
              ],
            )
          ],
        ),
      );
    } else {
      return Container();
    }
  }
}
