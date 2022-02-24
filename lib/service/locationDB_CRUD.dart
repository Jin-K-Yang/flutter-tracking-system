import 'dart:async';
import '../database/locationDB.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

Future<Database> openDB() async {
  final database = openDatabase(
    join(await getDatabasesPath(), 'tracking_system.db'),
    onCreate: (db, version) {
      return db.execute(
        "CREATE TABLE locations(id INTEGER, locDateTime TEXT, userLat DOUBLE, userLon DOUBLE, PRIMARY KEY (id, userLat, userLon))",
      );
    },
    version: 1,
  );
  return database;
}

Future<void> insertLocation(UserLocation location, final database) async {
  final Database db = await database;

  await db.insert(
    'locations',
    location.toMap(),
    conflictAlgorithm: ConflictAlgorithm.ignore,
  );
}

Future<List<UserLocation>> locations(final database) async {
  // Get a reference to the database.
  final Database db = await database;

  final List<Map<String, dynamic>> maps = await db.query('locations');
  //print(maps);
  return List.generate(maps.length, (i) {
    return UserLocation(
      id: maps[i]['id'],
      locDateTime: maps[i]['locDateTime'],
      userLat: maps[i]['userLat'],
      userLon: maps[i]['userLon'],
    );
  });
}

Future<List<UserLocation>> getList(final database) async {
  final Database db = await database;
  final List<Map<String, dynamic>> maps = await db.rawQuery(
      'SELECT "id", "locDateTime" FROM locations GROUP BY "id" HAVING MIN(ROWID) ORDER BY ROWID');
  print(maps);
  return List.generate(maps.length, (i) {
    return UserLocation(
      id: maps[i]['id'],
      locDateTime: maps[i]['locDateTime'],
      userLat: 0,
      userLon: 0,
    );
  });
}

Future<void> updateLocation(UserLocation location, final database) async {
  // Get a reference to the database.
  final db = await database;

  await db.update(
    'locations',
    location.toMap(),
    where: "id = ?",
    whereArgs: [location.id],
  );
}

Future<void> deleteLocation(int id, final database) async {
  // Get a reference to the database.
  final db = await database;

  await db.delete(
    'locations',
    where: "id = ?",
    whereArgs: [id],
  );
}

Future<int> getMaxId(final database) async {
  final Database db = await database;

  var maxId = 0;
  final List<Map<String, dynamic>> ids =
      await db.query('locations', columns: ['id']);
  ids.forEach((element) {
    if (element['id'] > maxId) {
      maxId = element['id'];
    }
  });

  return maxId;
}

Future<void> insertBatchLocation(
    List<UserLocation> locationList, final database) async {
  final Database db = await database;

  Batch batch = db.batch();
  for (int i = 0; i < locationList.length; i++) {
    try {
      batch.insert('locations', locationList[i].toMap());
    } catch (error) {
      print(error);
    }
  }
  final results = await batch.commit(continueOnError: true, noResult: true);
  print(results);
}

void manipulateDatabase(UserLocation locationObject, final database) async {
  await insertLocation(locationObject, database);
  print(await locations(database));
}
