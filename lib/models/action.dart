class SpecialAction {


  String title;
  int date_created;
  String date_str;
  String text;
  String img_url;

  SpecialAction({this.date_created, this.title, this.date_str, this.text, this.img_url});

  factory SpecialAction.fromJson(Map<String, dynamic> responseData) {

    return SpecialAction(
      date_created: responseData['date_created'],
      title: responseData['title'],
      date_str: responseData['date_str'],
      text: responseData['text'],
      img_url: responseData['img_url']
    );
  }

  factory SpecialAction.fromMap(Map<String, dynamic> responseData) {

    return SpecialAction(
        title: responseData['title'].toString(),
        date_created: responseData['date_created'],
        date_str: responseData['date_str'],
        text: responseData['body'].toString(),
        img_url: responseData['img_ulr']
    );
  }


  Future<Map<String, dynamic>> toMap() async {
    return {'date_created':date_created, 'date_str': date_str, 'title': title, 'body': text, 'img_url':img_url};
  }
}