import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:titan/generated/i18n.dart';
import 'package:titan/src/components/inject/injector.dart';
import 'package:titan/src/components/scaffold_map/bloc/bloc.dart';
import 'package:titan/src/config/application.dart';
import 'burning_dialog.dart';

class BottomFabsWidget extends StatefulWidget {
  final bool showBurnBtn;

  BottomFabsWidget({Key key, this.showBurnBtn}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return BottomFasScenesState();
  }
}

class BottomFasScenesState extends State<BottomFabsWidget> {
  double _fabsBottom = 16;
  double opacity = 1;

  void updateBottomPadding(double bottom, double anchorHeight) {
    if (bottom >= 0 && bottom <= anchorHeight) {
      setState(() {
        _fabsBottom = bottom;
        opacity = 1;
      });
    }
    if (bottom > anchorHeight) {
      double dy = _fabsBottom + 50 - bottom;
      if (dy > 0) {
        setState(() {
          opacity = dy / 50;
        });
      } else if (opacity != 0) {
        setState(() {
          opacity = 0;
        });
      }
    }
  }

  void _clean() {
    var searchInteractor = Injector.of(context).searchInteractor;
    searchInteractor.deleteAllHistory();

    //TODO UI back to global
//    BlocProvider.of<home.HomeBloc>(context).add(home.ExistSearchEvent());
//    BlocProvider.of<map.MapBloc>(context).add(map.ResetMapEvent());
  }

  void _showFireModalBottomSheet(context) {
    showModalBottomSheet(
        context: context,
        builder: (ctx) {
          return Container(
            margin: EdgeInsets.all(8),
            child: new Wrap(
              children: <Widget>[
                new ListTile(
                    leading: new Icon(IconData(0xe66e, fontFamily: 'iconfont'), color: Color(0xffac2229)),
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
                      _clean();
                    }),
                new ListTile(
                  leading: new Icon(Icons.close),
                  title: new Text(S.of(context).cancel),
                  onTap: () => Navigator.pop(ctx),
                ),
              ],
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: _fabsBottom,
      left: 0,
      right: 0,
      child: IgnorePointer(
        ignoring: opacity == 0,
        child: Opacity(
          opacity: opacity,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
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
//                BlocProvider.of<MapBloc>(context).add(MyLocationEvent());
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
            ),
          ),
        ),
      ),
    );
  }
}
