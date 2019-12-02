import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:titan/generated/i18n.dart';
import 'package:titan/src/business/discover/bloc/bloc.dart';
import 'package:titan/src/business/scaffold_map/bloc/bloc.dart';

class PoliceService extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return PoliceServiceState();
  }
}

class PoliceServiceState extends State<PoliceService> {
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
                elevation: 2,
                child: Container(
                  color: Colors.white,
                  padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).padding.top + 56,
                  child: Stack(
                    children: <Widget>[
                      Center(
                          child: Text(
                        S.of(context).police_security_station,
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                      )),
                      Align(
                        child: InkWell(
                          onTap: () {
                            BlocProvider.of<DiscoverBloc>(context).add(InitDiscoverEvent());
                          },
                          child: Ink(
                            padding: const EdgeInsets.all(16.0),
                            child: Text(
                              S.of(context).close,
                              style: TextStyle(color: Colors.blueAccent),
                            ),
                          ),
                        ),
                        alignment: Alignment.centerLeft,
                      ),
                    ],
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
