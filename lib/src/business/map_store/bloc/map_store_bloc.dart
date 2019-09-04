import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/generated/i18n.dart';
import 'package:titan/env.dart';
import 'package:titan/src/business/map_store/bloc/map_store_event.dart';
import 'package:titan/src/business/map_store/bloc/map_store_state.dart';
import 'package:titan/src/business/map_store/map_store_network_repository.dart';
import 'package:titan/src/global.dart';

class MapStoreBloc extends Bloc<MapStoreEvent, MapStoreState> {
  final MapStoreNetworkRepository mapStoreNetworkRepository;
  final BuildContext context;

  MapStoreBloc({@required this.context, @required this.mapStoreNetworkRepository});

  @override
  MapStoreState get initialState => MapStoreNotLoaded();

  @override
  Stream<MapStoreState> mapEventToState(MapStoreEvent event) async* {
    if (event is LoadMapStoreItemsEvent) {
      yield* _loadedMapStoreItemState(event.channel, event.language);
    }
  }

  Stream<MapStoreState> _loadedMapStoreItemState(String channel, String language) async* {
//    var channel = "";
    var language = Localizations.localeOf(context).languageCode;
    switch (env.buildType) {
      case BuildFlavor.androidOfficial:
        {
          channel = "official";
          break;
        }
      case BuildFlavor.androidGoogle:
        {
          channel = "google";
          break;
        }
      case BuildFlavor.iosEnterprise:
        {
          channel = "google";
          break;
        }
      case BuildFlavor.iosStore:
        {
          channel = "google";
          break;
        }
      default:
        {
          channel = "google";
          break;
        }
    }

    try {
      final mapStoreItems = await mapStoreNetworkRepository.getAllMapItem(channel, language);
      yield MapStoreLoaded(mapStoreItems);
    } catch (_) {
      logger.e(_);
      yield MapStoreNotLoaded();
    }
  }
}
