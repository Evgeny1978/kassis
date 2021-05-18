
import 'dart:io';

import 'package:intl/intl.dart';
import 'package:kassis/models/action.dart';
import 'package:kassis/models/news_company.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class dbActions {

  dbActions._();
  static final dbActions db = dbActions._();

  static Database _database;
  final String table_name = 'actions_data_table';

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
    String path = join(documentsDirectory.path, "app_database_actions.db");

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
                  "img_url TEXT NOT NULL, "
                  "body TEXT NOT NULL)"
          );
        });
  }
  Future<bool> addAction(SpecialAction data) async {

    int result = 0;
    try {
      final db = await database;
      result = await db.insert(
          '$table_name',
          await data.toMap()
      );
    } catch (e) {
      return false;
    }
    return result>0;
  }

  Future<List<SpecialAction>> getActions() async {


    List<SpecialAction> result = [];
    try {
      List<String> columns_list = ['title, body, date_str, date_created, img_url'];
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query(
          '$table_name',
          columns: columns_list,
          orderBy: 'date_created DESC'
      );

      return List.generate(maps.length, (i) {
        return SpecialAction(
          title: maps[i]['title'],
          date_created: maps[i]['date_created'],
          date_str: maps[i]['date_str'],
          text: maps[i]['body'],
          img_url: maps[i]['img_url']
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

  Future<void> clear() async {

    final db = await database;
    try {
      await db.delete(
          '$table_name'
      );
    } catch (e) {
      print(e);
    }

  }


}