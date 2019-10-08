import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:titan/src/business/discover/bloc/bloc.dart';

class NightLife extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return NightLifeState();
  }
}

class NightLifeState extends State<NightLife> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        //top bar
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
                  '夜生活指南',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                )),
                Align(
                  child: InkWell(
                    onTap: () {
                      BlocProvider.of<DiscoverBloc>(context).dispatch(InitDiscoverEvent());
                    },
                    child: Ink(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        '退出',
                        style: TextStyle(color: Colors.blueAccent),
                      ),
                    ),
                  ),
                  alignment: Alignment.centerRight,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
