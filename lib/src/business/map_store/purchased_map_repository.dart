import 'package:titan/src/data/db/db_provider.dart';
import 'model/purchased_map_item.dart';

class PurchasedMapRepository {
  Future<List<PurchasedMap>> getPurchasedMapItems() async {
    return (await DBProvider.getAppDb()).purchasedMapDao.findAll();
  }

  void savePurchasedMapItem(PurchasedMap purchasedMapItem) async {
    PurchasedMap purchasedMap = await (await DBProvider.getAppDb()).purchasedMapDao.findById(purchasedMapItem.id);

    if (purchasedMap != null) {
      (await DBProvider.getAppDb()).purchasedMapDao.updatePurchasedMap(purchasedMapItem);
    } else {
      (await DBProvider.getAppDb()).purchasedMapDao.insertPurchasedMap(purchasedMapItem);
    }
  }
}
