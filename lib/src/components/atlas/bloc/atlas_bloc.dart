import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:titan/src/components/wallet/wallet_component.dart';
import 'package:titan/src/pages/atlas_map/api/atlas_api.dart';
import 'package:titan/src/pages/atlas_map/entity/atlas_home_entity.dart';
import './bloc.dart';

class AtlasBloc extends Bloc<AtlasEvent, AtlasState> {
  @override
  AtlasState get initialState => InitialAtlasState();

  @override
  Stream<AtlasState> mapEventToState(
    AtlasEvent event,
  ) async* {}
}
