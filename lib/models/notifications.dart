class SpecialNotif {


  String title;
  int date_created;
  String date_str;
  String text;
  int status;

  SpecialNotif({this.date_created, this.title, this.date_str, this.text, this.status});

  factory SpecialNotif.fromJson(Map<String, dynamic> responseData) {

    return SpecialNotif(
      date_created: responseData['date_created'],
      title: responseData['title'],
      date_str: responseData['date_str'],
      text: responseData['text'],
      status: 0
    );
  }

  factory SpecialNotif.fromMap(Map<String, dynamic> responseData) {

    return SpecialNotif(
        title: responseData['title'].toString(),
        date_created: responseData['date_created'],
        date_str: responseData['date_str'],
        text: responseData['body'].toString(),
        status: responseData['status']
    );
  }

  Future<Map<String, dynamic>> toMap() async {
    return {'date_created':date_created, 'date_str': date_str, 'title': title, 'body': text, 'status': status};
  }
}