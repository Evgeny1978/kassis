import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class SpecialNews {

  String title;
  String date;
  String text;
  int date_time;



  SpecialNews({this.title, this.date, this.text, this.date_time});

  factory SpecialNews.fromMap(Map<String, dynamic> responseData) {

    final DateFormat formatter = DateFormat('dd/MM/yyyy');
    return SpecialNews(
        title: responseData['title'].toString(),
        //date: formatter.format(DateTime.fromMillisecondsSinceEpoch(responseData['date_created'])),
        date: responseData['date_str'].toString(),
        date_time: responseData['date_created'],
        text: responseData['body'].toString()
    );
  }

  factory SpecialNews.fromJson(Map<String, dynamic> responseData) {

    return SpecialNews(
        title: responseData['title'],
        date: responseData['date_str'],
        date_time: responseData['date_created'],
        text: responseData['text'],
    );
  }

  Future<Map<String, dynamic>> toMap() async {
    return {'date_created':date_time, 'title': title, 'body': text, 'date_str':date};
  }

}