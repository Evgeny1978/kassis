import 'dart:io' as IO;


import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart' as fs;
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:kassis/databases/db_actions.dart';
import 'package:kassis/databases/db_news.dart';
import 'package:kassis/databases/db_notifications.dart';
import 'package:kassis/models/action.dart';
import 'package:kassis/models/news_company.dart';
import 'package:kassis/models/notifications.dart';
import 'package:kassis/utils/additional_utils.dart';
import 'package:path/path.dart' as Path;

class FirebaseApplicationTools {

  final String VALUE_FIREBASE_USER_PASSWORD   = 'Lksdfjs4rtg675he';
  FirebaseAuth auth = FirebaseAuth.instance;
  User appUser;

  Future<bool> login() async {

    bool logout = true;
    appUser = auth.currentUser;
    if(appUser == null) {
      auth
          .authStateChanges()
          .listen((User user) {
        if (user != null) {
          appUser = user;
          logout = false;
        }
      });
      if (logout) {
        try {
          Future<UserCredential> userCredential =  auth.signInWithEmailAndPassword(
              email: 'kassis@barnlab.ru',
              password: VALUE_FIREBASE_USER_PASSWORD
          );
        } on FirebaseAuthException catch (e) {
          if (e.code == 'user-not-found') {
            print('No user found for that email.');
            return false;
          } else if (e.code == 'wrong-password') {
            print('Wrong password provided for that user.');
            return false;
          }
        }
      }
      appUser = auth.currentUser;
    }
    return true;
  }

  Future<List<SpecialNews>> getNews() async {

    //Firebase.initializeApp();

    int d = await dbNews.db.getLastDate();
    d = 0;
    QuerySnapshot querySnapshotStreem;

    List listNews = <SpecialNews>[];

    final firestoreInstance = FirebaseFirestore.instance;
    try {
      CollectionReference ref = firestoreInstance.collection('news');
      QuerySnapshot snapshot = await ref.where("date_created", isGreaterThan: d).get();
      List<DocumentSnapshot> documentSnapshot = snapshot.docs;
      if(documentSnapshot.isNotEmpty) {
        await dbNews.db.clear();
      }
      for(DocumentSnapshot doc in documentSnapshot) {
        Map<String, dynamic> mappedData = doc.data();
        SpecialNews specialNews = SpecialNews.fromMap(mappedData);
        await dbNews.db.addNews(specialNews);
      }

      listNews = await dbNews.db.getNews();


    } catch (e) {
      String s = e.toString();
    }


    return listNews;

  }

  Future<bool> uploadToken(String token) async {

    final firestoreInstance = FirebaseFirestore.instance;
    try {
      CollectionReference ref = firestoreInstance.collection('tokens');
      QuerySnapshot snapshot = await ref.where("data", isEqualTo: token.toString()).get();
      List<DocumentSnapshot> documentSnapshot = snapshot.docs;
      if(documentSnapshot.isEmpty) {
        await ref.add({'data': token});
        //await tokens.setData({'data': token});
      }
    } catch (e) {
      String s = e.toString();
    }


  }

  Future<List<SpecialNotif>> getNotifications() async {

    //Firebase.initializeApp();

    int d = await dbNotifications.db.getLastDate();

    List listData = <SpecialNotif>[];

    final firestoreInstance = FirebaseFirestore.instance;
    try {
      CollectionReference ref = firestoreInstance.collection('notifications');
      QuerySnapshot snapshot = await ref.where("date_created", isGreaterThan: d).get();
      List<DocumentSnapshot> documentSnapshot = snapshot.docs;
      for(DocumentSnapshot doc in documentSnapshot) {
        Map<String, dynamic> mappedData = doc.data();
        SpecialNotif specialNotif = SpecialNotif.fromMap(mappedData);
        await dbNotifications.db.addNotification(specialNotif);
      }

      listData = await dbNotifications.db.getNotifications();


    } catch (e) {
      String s = e.toString();
    }


    return listData;

  }

  Future<List<SpecialAction>> getActions(BuildContext context) async {

    //Firebase.initializeApp();
    AdditionalUtils utils = AdditionalUtils();
    int d = await dbActions.db.getLastDate();
    d= 0;
    List listData = <SpecialAction>[];

    final firestoreInstance = FirebaseFirestore.instance;
    try {
      CollectionReference ref = firestoreInstance.collection('actions');
      QuerySnapshot snapshot = await ref.where("date_created", isGreaterThan: d).get();
      List<DocumentSnapshot> documentSnapshot = snapshot.docs;
      if(documentSnapshot.isNotEmpty) {
        await dbActions.db.clear();
      }
      for(DocumentSnapshot doc in documentSnapshot) {
        Map<String, dynamic> mappedData = doc.data();
        SpecialAction specialAction = SpecialAction.fromMap(mappedData);
        var saved_path = await utils.saveFile(context, mappedData['img_url']);
        if(!saved_path.isEmpty) {
          specialAction.img_url = saved_path;
          await dbActions.db.addAction(specialAction);
        }
      }

      listData = await dbActions.db.getActions();

    } catch (e) {
      String s = e.toString();
    }


    return listData;

  }


}

