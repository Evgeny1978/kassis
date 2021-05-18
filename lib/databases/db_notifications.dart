
import 'dart:io';

import 'package:kassis/models/notifications.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class dbNotifications {

  dbNotifications._();
  static final dbNotifications db = dbNotifications._();

  static Database _database;
  String table_name = 'notif_data_table';

  Future<Database> get database async {
    if (_database != null)
      return _database;

    // if _database is null we instantiate it
    _database = await initDB();
    return _database;
  }

  initDB() async {
    Directory documentsDirectory;
    try {
      documentsDirectory = await getApplicationDocumentsDirectory();
    } catch (e) {
      String error = e.toString();
      return;
    }
    String path = join(documentsDirectory.path, "app_database_notif.db");

    return await openDatabase(
        path,
        version: 2,
        onOpen: (db) {},
        onCreate: (Database db, int version) async {
          await db.execute(
              "CREATE TABLE $table_name ("
                  "_id INTEGER PRIMARY KEY AUTOINCREMENT, "
                  "date_created INTEGER NOT NULL, "
                  "date_str TEXT NOT NULL, "
                  "title TEXT NOT NULL, "
                  "status INTEGER NOT NULL,"
                  "body TEXT NOT NULL)"
          );
        });
  }
  Future<bool> addNotification(SpecialNotif data) async {

    int result = 0;
    final db = await database;
    try {
      result = await db.insert('$table_name', await data.toMap());
    } catch (e) {
      e.toString();
    }

    return result>0;
  }

  Future<bool> updateNotification(SpecialNotif data) async {

    int result = 0;

    final db = await database;

    result = await db.rawUpdate('UPDATE $table_name SET status = 1 WHERE date_created = ?', [data.date_created]);

    return result>0;
  }


  Future<List<SpecialNotif>> getNotifications() async {

    List<SpecialNotif> result = [];
    try {
      List<String> columns_list = ['title, date_created, body, date_str, status'];
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query(
          '$table_name',
          columns: columns_list,
          orderBy: 'date_created DESC'
      );

      return List.generate(maps.length, (i) {
        return SpecialNotif(
          title: maps[i]['title'],
          date_created: maps[i]['date_created'],
          date_str: maps[i]['date_str'],
          text: maps[i]['body'],
          status: maps[i]['status']
        );
      });
    } catch (e) {
      String s = e.toString();
      return result;
    }
  }

  Future<int> getLastDate() async {

    final db = await database;
    List<String> columns_list = [];
    columns_list.add('date_created');
    var result = await db.query(
        '$table_name',
        columns: columns_list,
        limit: 1,
        orderBy: 'date_created DESC'
    );

    return result.isNotEmpty ? result.first['date_created'] : 0;

  }

  Future<int> getCountReads() async {

    final db = await database;
    List<String> columns_list = ['date_created'];
    columns_list.add('date_created');
    int count = 0;
    try {
      count = Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM $table_name WHERE status = 0'));
    } catch (e) {
      String s = e.toString();
    }


    return count;

  }



}