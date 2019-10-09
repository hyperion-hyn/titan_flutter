import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:titan/src/business/scaffold_map/bloc/bloc.dart' as map;
import '../dmap_define.dart';
import './bloc.dart';

class DiscoverBloc extends Bloc<DiscoverEvent, DiscoverState> {
  final BuildContext context;

  DiscoverBloc(this.context);

  @override
  DiscoverState get initialState => InitialDiscoverState();

  @override
  Stream<DiscoverState> mapEventToState(DiscoverEvent event) async* {
    if (event is InitDiscoverEvent) {
      yield InitialDiscoverState();

      BlocProvider.of<map.ScaffoldMapBloc>(context).dispatch(map.InitMapEvent());
    } else if (event is ActiveDMapEvent) {
      DMapCreationModel model = DMapDefine.kMapList[event.name];
      if (model != null) {
        yield ActiveDMapState(name: event.name);

        DMapCreationModel model = DMapDefine.kMapList[event.name];
        BlocProvider.of<map.ScaffoldMapBloc>(context).dispatch(map.InitDMapEvent(
          dMapConfigModel: model.dMapConfigModel,
        ));
      }
    }
  }
}
