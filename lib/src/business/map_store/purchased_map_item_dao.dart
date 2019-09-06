import 'package:floor/floor.dart';
import 'package:titan/src/business/map_store/model/purchased_map_item.dart';

@dao
abstract class PurchasedMapDao {
  @Query('SELECT * FROM PurchasedMapItem')
  Future<List<PurchasedMap>> findAll();

  @insert
  Future<void> insertPurchasedMap(PurchasedMap PurchasedMap);

  @Query('SELECT * FROM PurchasedMap WHERE id = :id')
  Future<PurchasedMap> findById(String id);

  @update
  Future<int> updatePurchasedMap(PurchasedMap PurchasedMap);
}
