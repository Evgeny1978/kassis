
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';

class UserPreferences {

  final String KEY_USER_ID             = 'userID';
  final String KEY_SEND_CODE_STATUS    = 'code_sended';
  final String KEY_REG_APP             = 'reg_app';
  final String KEY_EMAIL               = 'user_email';
  final String KEY_PASS                = 'user_password';
  final String KEY_TOKEN               = 'user_token';


  Future<bool> setBoolValue(String prefName, bool value) async {

    Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
    final SharedPreferences prefs = await _prefs;

    return prefs.setBool(KEY_REG_APP, value);

  }

  Future<bool> resetSendCodeStatus(bool status) async {
    Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
    final SharedPreferences prefs = await _prefs;

    return prefs.setBool(KEY_SEND_CODE_STATUS, status);
  }

  Future<bool> getStatusSendCode() async {

    final SharedPreferences prefs = await SharedPreferences.getInstance();

    return prefs.getBool(KEY_SEND_CODE_STATUS) ?? true;
  }



  void removeUser() async {
    Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
    final SharedPreferences prefs = await _prefs;
    prefs.clear();
  }

  Future<String> getToken(args) async {
    Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
    final SharedPreferences prefs = await _prefs;
    String token = prefs.getString(KEY_TOKEN);
    return token;
  }

  Future<bool> regApp() async {
    Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
    final SharedPreferences prefs = await _prefs;

    return prefs.getBool(KEY_REG_APP);
  }

}