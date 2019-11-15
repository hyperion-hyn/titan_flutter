import 'dart:async';
import 'package:sqflite/sqflite.dart' as sqflite;
import 'package:floor/floor.dart';
import 'package:path/path.dart';

part 'app_database.g.dart'; // the generated code will be there

@Database(version: 1, entities: [])
abstract class AppDatabase extends FloorDatabase {}
