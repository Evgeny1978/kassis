
import 'dart:io';

import 'package:intl/intl.dart';
import 'package:kassis/models/news_company.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class dbNews {

  dbNews._();
  static final dbNews db = dbNews._();
  String table_name = 'news_data_table';
  static Database _database;

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
    String path = join(documentsDirectory.path, "app_database_news.db");

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
                  "body TEXT NOT NULL)"
          );
        });
  }
  Future<bool> addNews(SpecialNews data) async {

    int result = 0;
    final db = await database;
    result = await db.insert('news_data_table', await data.toMap());
    return result>0;
  }

  Future<List<SpecialNews>> getNews() async {

    final DateFormat formatter = DateFormat('dd/MM/yyyy');
    List<SpecialNews> result = [];
    try {
      List<String> columns_list = ['title, date_created, body, date_str '];
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query(
          "news_data_table",
          columns: columns_list,
          orderBy: 'date_created DESC'
      );

      return List.generate(maps.length, (i) {
        return SpecialNews(
          title: maps[i]['title'],
          //date: formatter.format(DateTime.fromMillisecondsSinceEpoch(maps[i]['date_created'])),
          date: maps[i]['date_str'],
          date_time: maps[i]['date_created'],
          text: maps[i]['body'],
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
        "news_data_table",
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