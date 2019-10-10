// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// **************************************************************************
// FloorGenerator
// **************************************************************************

class $FloorAppDatabase {
  /// Creates a database builder for a persistent database.
  /// Once a database is built, you should keep a reference to it and re-use it.
  static _$AppDatabaseBuilder databaseBuilder(String name) =>
      _$AppDatabaseBuilder(name);

  /// Creates a database builder for an in memory database.
  /// Information stored in an in memory database disappears when the process is killed.
  /// Once a database is built, you should keep a reference to it and re-use it.
  static _$AppDatabaseBuilder inMemoryDatabaseBuilder() =>
      _$AppDatabaseBuilder(null);
}

class _$AppDatabaseBuilder {
  _$AppDatabaseBuilder(this.name);

  final String name;

  final List<Migration> _migrations = [];

  /// Adds migrations to the builder.
  _$AppDatabaseBuilder addMigrations(List<Migration> migrations) {
    _migrations.addAll(migrations);
    return this;
  }

  /// Creates the database and initializes it.
  Future<AppDatabase> build() async {
    final database = _$AppDatabase();
    database.database = await database.open(name ?? ':memory:', _migrations);
    return database;
  }
}

class _$AppDatabase extends AppDatabase {
  _$AppDatabase([StreamController<String> listener]) {
    changeListener = listener ?? StreamController<String>.broadcast();
  }

  PurchasedMapDao _purchasedMapDaoInstance;

  Future<sqflite.Database> open(String name, List<Migration> migrations) async {
    final path = join(await sqflite.getDatabasesPath(), name);

    return sqflite.openDatabase(
      path,
      version: 1,
      onConfigure: (database) async {
        await database.execute('PRAGMA foreign_keys = ON');
      },
      onUpgrade: (database, startVersion, endVersion) async {
        MigrationAdapter.runMigrations(
            database, startVersion, endVersion, migrations);
      },
      onCreate: (database, _) async {
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `PurchasedMap` (`id` TEXT, `name` TEXT, `description` TEXT, `sourceUrl` TEXT, `sourceLayer` TEXT, `icon` TEXT, `color` TEXT, `minZoom` REAL, `maxZoom` REAL, `selected` INTEGER, PRIMARY KEY (`id`))');
      },
    );
  }

  @override
  PurchasedMapDao get purchasedMapDao {
    return _purchasedMapDaoInstance ??=
        _$PurchasedMapDao(database, changeListener);
  }
}

class _$PurchasedMapDao extends PurchasedMapDao {
  _$PurchasedMapDao(this.database, this.changeListener)
      : _queryAdapter = QueryAdapter(database),
        _purchasedMapInsertionAdapter = InsertionAdapter(
            database,
            'PurchasedMap',
            (PurchasedMap item) => <String, dynamic>{
                  'id': item.id,
                  'name': item.name,
                  'description': item.description,
                  'sourceUrl': item.sourceUrl,
                  'sourceLayer': item.sourceLayer,
                  'icon': item.icon,
                  'color': item.color,
                  'minZoom': item.minZoom,
                  'maxZoom': item.maxZoom,
                  'selected': item.selected ? 1 : 0
                }),
        _purchasedMapUpdateAdapter = UpdateAdapter(
            database,
            'PurchasedMap',
            ['id'],
            (PurchasedMap item) => <String, dynamic>{
                  'id': item.id,
                  'name': item.name,
                  'description': item.description,
                  'sourceUrl': item.sourceUrl,
                  'sourceLayer': item.sourceLayer,
                  'icon': item.icon,
                  'color': item.color,
                  'minZoom': item.minZoom,
                  'maxZoom': item.maxZoom,
                  'selected': item.selected ? 1 : 0
                });

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final _purchasedMapMapper = (Map<String, dynamic> row) => PurchasedMap(
      row['id'] as String,
      row['name'] as String,
      row['description'] as String,
      row['sourceUrl'] as String,
      row['sourceLayer'] as String,
      row['icon'] as String,
      row['color'] as String,
      row['minZoom'] as double,
      row['maxZoom'] as double,
      (row['selected'] as int) != 0);

  final InsertionAdapter<PurchasedMap> _purchasedMapInsertionAdapter;

  final UpdateAdapter<PurchasedMap> _purchasedMapUpdateAdapter;

  @override
  Future<List<PurchasedMap>> findAll() async {
    return _queryAdapter.queryList('SELECT * FROM PurchasedMap',
        mapper: _purchasedMapMapper);
  }

  @override
  Future<PurchasedMap> findById(String id) async {
    return _queryAdapter.query('SELECT * FROM PurchasedMap WHERE id = ?',
        arguments: <dynamic>[id], mapper: _purchasedMapMapper);
  }

  @override
  Future<void> insertPurchasedMap(PurchasedMap PurchasedMap) async {
    await _purchasedMapInsertionAdapter.insert(
        PurchasedMap, sqflite.ConflictAlgorithm.abort);
  }

  @override
  Future<int> updatePurchasedMap(PurchasedMap PurchasedMap) {
    return _purchasedMapUpdateAdapter.updateAndReturnChangedRows(
        PurchasedMap, sqflite.ConflictAlgorithm.abort);
  }
}
