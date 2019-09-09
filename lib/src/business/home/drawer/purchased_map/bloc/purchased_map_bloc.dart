import 'package:bloc/bloc.dart';
import 'package:titan/src/business/home/drawer/purchased_map/bloc/purchased_map_event.dart';
import 'package:titan/src/business/home/drawer/purchased_map/bloc/purchased_map_state.dart';
import 'package:titan/src/business/map_store/model/purchased_map_item.dart';
import 'package:titan/src/business/map_store/purchased_map_repository.dart';
import 'package:titan/src/global.dart';

class PurchasedMapBloc extends Bloc<PurchasedMapEvent, PurchasedMapState> {
  final PurchasedMapRepository _purchasedMapRepository = PurchasedMapRepository();

  PurchasedMapBloc();

  @override
  PurchasedMapState get initialState => PurchasedMapNotLoaded();

  @override
  Stream<PurchasedMapState> mapEventToState(PurchasedMapEvent event) async* {
    if (event is LoadPurchasedMapsEvent) {
      yield* _loadedPurchasedMapsState();
    }
    if (event is ShowPurchasedMapEvent) {
      yield* _showPurchasedMap(event.purchasedMap);
    }
  }

  Stream<PurchasedMapState> _loadedPurchasedMapsState() async* {
    try {
      final purchasedMapItems = await _purchasedMapRepository.getPurchasedMapItems();
      yield PurchasedMapLoaded(purchasedMapItems);
    } catch (_) {
      logger.e(_);
      yield PurchasedMapNotLoaded();
    }
  }

  Stream<PurchasedMapState> _showPurchasedMap(PurchasedMap purchasedMap) async* {
    try {
      purchasedMap.selected = !purchasedMap.selected;
      await _purchasedMapRepository.savePurchasedMapItem(purchasedMap);
      yield* _loadedPurchasedMapsState();
    } catch (err) {
      logger.e(err);
      yield PurchasedMapNotLoaded();
    }
  }
}
