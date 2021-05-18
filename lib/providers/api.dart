import 'package:flutter/cupertino.dart';
import 'package:http/http.dart';
import 'dart:async';
import 'dart:convert';

import 'package:kassis/models/action.dart';
import 'package:kassis/models/news_company.dart';
import 'package:kassis/models/notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum Status {
  read,
  error,
  successful
}

class ServerAuth with ChangeNotifier {

  final String KEY_IDS = 'notification_ids';

  Status _read = Status.read;
  Status _error = Status.error;
  Status _successful = Status.successful;

  Status get readInStatus => _read;
  Status get errorStatus => _error;
  Status get succesStatus => _successful;

  Future<Map<String, dynamic>> getActions() async {

    var result;


    notifyListeners();

    Response response = await post(
      'https://kassis.ru/api/actions/index.php',
      body: json.encode(''),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      _read = Status.read;
      notifyListeners();

      try {

        //var list = jsonString['actions'];
        var list = json.decode(response.body)['actions']
            .map((data) => SpecialAction.fromJson(data))
            .toList();

        List<SpecialAction> listActions = new List<SpecialAction>.from(list) ;

        result = {
          'status': true,
          'message': 'Данные по акциям обновлены',
          'data': listActions
        };

      } catch (e) {
        result = {
          'status': false,
          'message': json.decode(response.body)['description']

        };
      }

    } else {
      notifyListeners();
      result = {
        'status': false,
        'message': json.decode(response.body)['description']
      };
    }
    return result;
  }

  Future<Map<String, dynamic>> getNews() async {

    var result;

    notifyListeners();

    Response response = await post(
      'https://kassis.ru/api/news/index.php',
      body: json.encode(''),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {

      _read = Status.read;
      notifyListeners();

      try {

        //var list = jsonString['actions'];
        var list = json.decode(response.body)['news']
            .map((data) => SpecialNews.fromJson(data))
            .toList();

        List<SpecialNews> listNews = new List<SpecialNews>.from(list) ;

        result = {
          'status': true,
          'message': 'Новости обновлены',
          'data': listNews
        };

      } catch (e) {
        result = {
          'status': false,
          'message': json.decode(response.body)['description']

        };
      }

    } else {
      notifyListeners();
      result = {
        'status': false,
        'message': json.decode(response.body)['description']
      };
    }
    return result;
  }

  Future<Map<String, dynamic>> getNotifications() async {

    var result;

    notifyListeners();

    Response response = await post(
      'https://kassis.ru/api/notifications/index.php',
      body: json.encode(''),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {

      _read = Status.read;
      notifyListeners();

      try {

        //var list = jsonString['actions'];
        var list = json.decode(response.body)['notif']
            .map((data) => SpecialNotif.fromJson(data))
            .toList();

        List<SpecialNotif> listNotifications = new List<SpecialNotif>.from(list);
        final SharedPreferences prefs = await SharedPreferences.getInstance();
        //prefs.setString(KEY_IDS, '');
        String str_listIDs = "";
        if(prefs.containsKey(KEY_IDS)) {
          str_listIDs = prefs.getString(KEY_IDS);
          str_listIDs = str_listIDs.replaceAll(' ', '');
          str_listIDs = str_listIDs.replaceAll('[', '');
          str_listIDs = str_listIDs.replaceAll(']', '');
        }
        // List<String> listIDs = new List<String>.from(str_listIDs.split(','));
        // for (SpecialNotif notif in listNotifications) {
        //   if(!listIDs.contains(notif.id)) {
        //     listIDs.add(notif.id);
        //   } else {
        //     notif.status = true;
        //   }
        // }
        // prefs.setString(KEY_IDS, listIDs.toString());

        result = {
          'status': true,
          'message': 'Уведомления обновлены',
          'data': listNotifications
        };

      } catch (e) {
        result = {
          'status': false,
          'message': json.decode(response.body)['description']

        };
      }

    } else {
      notifyListeners();
      result = {
        'status': false,
        'message': json.decode(response.body)['description']
      };
    }
    return result;
  }

}