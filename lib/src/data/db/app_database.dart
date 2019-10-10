

import 'dart:async';
import 'package:sqflite/sqflite.dart' as sqflite;
import 'package:floor/floor.dart';
import 'package:path/path.dart';
import 'package:titan/src/business/map_store/model/purchased_map_item.dart';
import 'package:titan/src/business/map_store/purchased_map_item_dao.dart';

part 'app_database.g.dart'; // the generated code will be there

@Database(version: 1, entities: [PurchasedMap])
abstract class AppDatabase extends FloorDatabase {
  PurchasedMapDao get purchasedMapDao;
}