import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

import 'package:dio/dio.dart';
import 'package:file_utils/file_utils.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';


class AdditionalUtils {

  bool downloading = false;
  var progress = "";
  var platformVersion = "Unknown";

  Directory externalDir;

  Future<String> getFolderApp() async {

    Directory documentsDirectory;
    try {
      documentsDirectory = await getApplicationDocumentsDirectory();
      return documentsDirectory.path;
    } catch (e) {
      String error = e.toString();
      return "";
    }
  }

  Future<String> saveFile(BuildContext context, String imgUrl) async {
    Dio dio = Dio();
    // bool checkPermission1 =
    // await SimplePermissions.checkPermission(permission1);
    // // print(checkPermission1);
    // if (checkPermission1 == false) {
    //   await SimplePermissions.requestPermission(permission1);
    //   checkPermission1 = await SimplePermissions.checkPermission(permission1);
    // }
    var status = await Permission.storage.status;
    if (!status.isDenied) {
      String dirloc = "";
      if (Platform.isAndroid) {
        dirloc = await getFolderApp();
      } else {
        dirloc = (await getApplicationDocumentsDirectory()).path;
      }

      var fileName = DateTime.now().millisecondsSinceEpoch;


      final filePath = join(dirloc, fileName.toString() + '.jpg');
      final file = File(filePath);
      if (file.existsSync()) {
        file.deleteSync();
      }
      try {

        await dio.download(imgUrl, filePath,
            onReceiveProgress: (receivedBytes, totalBytes) {
              String s = "";
            });
        return filePath;
      } catch (e) {
        print(e);
      }


    } else {
      Map<Permission, PermissionStatus> statuses = await [
        Permission.storage,
      ].request();
      return "";
    }
  }

  Flushbar openFlushbar(BuildContext context, Icon icon, String title, String msg, String buttonText, Function fun) {

    Flushbar flushbar;

    return Flushbar<bool>(
      backgroundColor: Colors.lightBlue.shade900,
      title: title,
      message: msg,
      icon: icon,
      duration: Duration(seconds: 5),

      mainButton: FlatButton(
        onPressed: () {
          flushbar.dismiss(true); // result = true
        },
        child: Text(
          buttonText,
          style: TextStyle(color: Colors.amber),
        ),
      ),
    )
      ..show(context).then((result) {
        fun;
      });
  }

}