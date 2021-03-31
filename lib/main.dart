import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/widgets.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart' as intl;
import 'package:intl/date_symbol_data_local.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

const kAndroidUserAgent =
    'Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/62.0.3202.94 Mobile Safari/537.36';

String selectedUrl = 'https://kassis.ru/magazin';



class News{
  String titleNews;
  String date;
  String text;
  News(this.titleNews, this.date, this.text);
}

class Action{

  String title;
  String date;
  String text;
  Action(this.title, this.date, this.text);

}

class appNotification {
  String titleNotif;
  String date;
  String text;
  bool status;
  appNotification(this.titleNotif, this.date, this.text, this.status);
}

final List<Action> listActions = <Action>[
  Action('Антикризисный набор за 2021 рубль', 'с 01/04/2021 по 30/04/2021', 'В акционный набор входят:\n\n\ - Брекеты (.018", .022") - 20 шт. (пр-во Китай)\n - Замки на 1-е моляры с одним отверстием, конвертируемые (.018", .022") - 4 шт. \n- Замки на 2-е моляры с одним отверствием, неконвертируемые (.018", .022") - 4 шт. \n\n\n Пропись Roth Type'),
  Action('Вторая акция Антикризисный набор за 2021 рубль', 'с 01/04/2021 по 30/04/2021', 'В акционный набор входят:\n\n\ - Брекеты (.018", .022") - 20 шт. (пр-во Китай)\n - Замки на 1-е моляры с одним отверстием, конвертируемые (.018", .022") - 4 шт. \n- Замки на 2-е моляры с одним отверствием, неконвертируемые (.018", .022") - 4 шт. \n\n\n Пропись Roth Type'),
  Action('Третья акция Антикризисный набор за 2021 рубль', 'с 01/04/2021 по 30/04/2021', 'В акционный набор входят:\n\n\ - Брекеты (.018", .022") - 20 шт. (пр-во Китай)\n - Замки на 1-е моляры с одним отверстием, конвертируемые (.018", .022") - 4 шт. \n- Замки на 2-е моляры с одним отверствием, неконвертируемые (.018", .022") - 4 шт. \n\n\n Пропись Roth Type'),
];

final List<News> listNews = <News>[
  News('Заголовок новости №1', '21/03/2021', 'Текст новости ыва ыва фыва фва фва фыва фыва фвыа фва афвыа фыва фыва фывафыва. Текст новости ыва ыва фыва фва фва фыва фыва фвыа фва афвыа фыва фыва фывафыва. Текст новости ыва ыва фыва фва фва фыва фыва фвыа фва афвыа фыва фыва фывафыва'),
  News('Заголовок новости №2', '20/03/2021', 'Текст новости ыва ыва фыва фва фва фыва фыва фвыа фва афвыа фыва фыва фывафыва'),
  News('Заголовок новости №3', '24/03/2021', 'Текст новости ыва ыва фыва фва фва фыва фыва фвыа фва афвыа фыва фыва фывафыва'),
  News('Заголовок новости №4', '24/03/2021', 'Текст новости ыва ыва фыва фва фва фыва фыва фвыа фва афвыа фыва фыва фывафыва'),
  News('Заголовок новости №5', '24/03/2021', 'Текст новости ыва ыва фыва фва фва фыва фыва фвыа фва афвыа фыва фыва фывафыва'),
  News('Заголовок новости №6', '24/03/2021', 'Текст новости ыва ыва фыва фва фва фыва фыва фвыа фва афвыа фыва фыва фывафыва'),
  News('Заголовок новости №7', '24/03/2021', 'Текст новости ыва ыва фыва фва фва фыва фыва фвыа фва афвыа фыва фыва фывафыва'),

];

final List<appNotification> listAppNotification = <appNotification>[
  appNotification('Уведомление №1', '21/03/2021', 'Текст новости ыва ыва фыва фва фва фыва фыва фвыа фва афвыа фыва фыва фывафыва. Текст новости ыва ыва фыва фва фва фыва фыва фвыа фва афвыа фыва фыва фывафыва. Текст новости ыва ыва фыва фва фва фыва фыва фвыа фва афвыа фыва фыва фывафыва', false),
  appNotification('Уведомление №2', '20/03/2021', 'Текст новости ыва ыва фыва фва фва фыва фыва фвыа фва афвыа фыва фыва фывафыва', true),
  appNotification('Уведомление №3', '24/03/2021', 'Текст новости ыва ыва фыва фва фва фыва фыва фвыа фва афвыа фыва фыва фывафыва', true),
  appNotification('Уведомление №4', '24/03/2021', 'Текст новости ыва ыва фыва фва фва фыва фыва фвыа фва афвыа фыва фыва фывафыва', false),
  appNotification('Уведомление №5', '24/03/2021', 'Текст новости ыва ыва фыва фва фва фыва фыва фвыа фва афвыа фыва фыва фывафыва', true),
  appNotification('Уведомление №6', '24/03/2021', 'Текст новости ыва ыва фыва фва фва фыва фыва фвыа фва афвыа фыва фыва фывафыва', true),
  appNotification('Уведомление №7', '24/03/2021', 'Текст новости ыва ыва фыва фва фва фыва фыва фвыа фва афвыа фыва фыва фывафыва', true),

];

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {

  final flutterWebViewPlugin = new FlutterWebviewPlugin();
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Kassis',
      theme: ThemeData(
        primaryColor: Color(0xFFFC0305),
        accentColor: Color(0xFFFC0305),
        primarySwatch: Colors.blue,
        fontFamily: 'CenturyGothic',
      ),
      home: MyHomePage(title: ''),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);


  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;


  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  News _current_news = null;
  int _index_current_notif = -1;

  final String number = "88002012742";

  int _currentIndex = 0;

  List cardList = [];



  final int indexMoscow       = 0;
  final int indexPitherburg   = 1;
  final int indexSimpheropol  = 2;

  int _indexContact = 0;

  final int itemStart           = 0;
  final int itemAbout           = 1;
  final int itemNews            = 2;
  final int itemActions         = 3;
  final int itemNotifications   = 4;
  final int itemMarket          = 5;
  final int itemFeedback        = 6;
  final int itemTraining        = 7;
  final int itemContacts        = 8;

  final String textAbout = 'Фирма "КАССИС" существует на рынке ортодонтической продукции с 1992 года. Всё это время мы предлагаем ортодонтическую аппаратуру ведущих мировых лидеров, проверенную на собственной клинической базе. Нашими поставщиками являются только проверенные компании, хорошо зарекомендовавшие себя на мировом рынке ортодонтии. Наш накопленный с годами опыт позволяет Вам быть уверенными в качестве предоставляемой продукции, а, следовательно, и в результате лечения.\n\n'
      ' Перечень ортодонтической аппаратуры, предлагаемой нашей фирмой необычайно велик. У нас Вы сможете найти всё необходимое для проведения ортодонтического лечения, начиная от брекет-систем и ортодонтического инструмента и заканчивая необходимыми в процессе лечении средствами гигиены и расходными материалами. Мы предлагаем всё самое и лучшее и востребованное в области ортодонтии в настоящий момент, оправдывая тем самым своё название \n\n КАССИС-ВСЁ ДЛЯ ОРТОДОНТИИ.';

  Widget containerWidget = Text("Test");
  Map<int, String> listTitle = {0:'', 1:'О компании', 2:'Новости', 3:'Акции', 4:'Уведомления', 5:'Интернет-магазин', 6:'Отзыв', 7:'Учебный центр', 8:'Контакты'};

  int currentItemID = 0;
  final Color default_color_red = Color(0xFFFC0305);
  final Color default_color_black = Colors.black;
  final Color colorAppBarDefault = Colors.white;
  final Color colorAppBarItems = Colors.grey.shade400;



  intl.DateFormat dateFormat;


  @override
  void initState() {
    super.initState();
    initializeDateFormatting('ru_RU');
    dateFormat = new intl.DateFormat.MEd('ru');

  }


  _selectItemMenu(int itemID) async {
    setState(() {
      currentItemID = itemID;
      _current_news =  null;
    });
  }

  List<T> map<T>(List list, Function handler) {
    List<T> result = [];
    for (var i = 0; i < list.length; i++) {
      result.add(handler(i, list[i]));
    }
    return result;
  }

  getCountNotification() {
    int n = 0;
    for (appNotification notif in listAppNotification){
      if(!notif.status) {
        n++;
      }
    }

    return n;

  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.

    double height_header = MediaQuery.of(context).size.width * 0.40;
    cardList.clear();
    for (var action in listActions){
      cardList.add(_action(action));
    }

    double fontSizeButton = 18.0;
    double heightElevation = 16.0;
    double elevationButton = 16.0;

    Widget buttonCall = Container(
      width: MediaQuery.of(context).size.width*0.7,
      height: 60,
      padding: EdgeInsets.all(8),
      margin: EdgeInsets.only(bottom: 2),
      color: Colors.transparent,
      child: new RaisedButton(
        child: Text(
            "Позвонить",
            style: TextStyle(
                color: Colors.white,
                fontSize: fontSizeButton
            )
        ),
        onPressed: () {
          launch("tel://88002012742");

        },
        highlightColor: default_color_red,
        color: default_color_red,
        textColor: Colors.white,
        padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
        highlightElevation: heightElevation,
        elevation: elevationButton,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(0)
        ),
        colorBrightness: Brightness.light,
      ),

    );

    Widget buttonAddresses = Container(
      width: MediaQuery.of(context).size.width*0.7,
      height: 60,
      padding: EdgeInsets.all(8),
      margin: EdgeInsets.only(bottom: 2),
      color: Colors.transparent,
      child: new RaisedButton(
        child: Text(
            "Адреса магазинов",
            style: TextStyle(
                color: Colors.white,
                fontSize: fontSizeButton
            )
        ),
        onPressed: () {
          _selectItemMenu(itemContacts);
        },
        highlightColor: default_color_red,
        color: default_color_red,
        textColor: Colors.white,
        padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
        highlightElevation: heightElevation,
        elevation: elevationButton,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(0)
        ),
        colorBrightness: Brightness.light,
      ),

    );

    Widget buttonMarketOnline = Container(
      width: MediaQuery.of(context).size.width*0.7,
      height: 60,
      padding: EdgeInsets.all(8),
      margin: EdgeInsets.only(bottom: 56),
      color: Colors.transparent,
      child: new RaisedButton(
        child: Text(
            "Интернет-магазин",
            style: TextStyle(
                color: Colors.white,
                fontSize: fontSizeButton
            )
        ),
        onPressed: () {
          _launchURL();
        },
        highlightColor: default_color_red,
        color: default_color_red,
        textColor: Colors.white,
        padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
        highlightElevation: heightElevation,
        elevation: elevationButton,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(0)
        ),
        colorBrightness: Brightness.light,
      ),

    );

    Widget widgetStart =
    Stack(
      alignment: AlignmentDirectional.center,
      textDirection: TextDirection.ltr,
      fit: StackFit.expand,
      children: <Widget>[

        Container(
          color: Colors.white.withOpacity(0.0),
          child: Image.asset(
                  'assets/icons/img_home_page.png',
                    fit: BoxFit.cover,
                    height: MediaQuery.of(context).size.height,
                    width: MediaQuery.of(context).size.width,
                    alignment: Alignment.center,
                ),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: Container(

            child: Column(
              textDirection: TextDirection.ltr,
              crossAxisAlignment: CrossAxisAlignment.start,
              verticalDirection: VerticalDirection.up,
              children: [
                buttonMarketOnline,
                buttonAddresses,
                buttonCall,
              ],
            ),
            ),
          ),
      ],
    );


    Widget widgetAbout = new ListView(
        children: [
          Container(
            height: height_header,
            child: new OverflowBox(
                minWidth: 0.0,
                minHeight: 0.0,
                child: Image.asset(
                'assets/icons/img_about_page.jpeg',
                fit: BoxFit.cover,
                height: MediaQuery.of(context).size.height,
                width: MediaQuery.of(context).size.width,
                alignment: Alignment.center,
              ),
            )
          ),
          Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              children: [
                Text(
                  textAbout,
                  style: TextStyle(
                    fontSize: 12.0,
                  ),
                )
              ],
            ),
          )
        ],
    );



    double c_width = MediaQuery.of(context).size.width*0.8;



    Widget widgetNewsNotification = Padding(
      padding: EdgeInsets.all(16.0),
      child: Column(
        children: [
          Row(
            mainAxisSize: MainAxisSize.max,
            children: [
              Image.asset(
                'assets/icons/ic_notifications_bell.png',
                height: 24.0,
                width: 24.0,
              ),
              Padding(
                padding: EdgeInsets.only(left: 16.0),
                child: Text(
                    'Тексттексттексттекст',
                    style: TextStyle(
                        color: default_color_red,
                        fontSize: 18,
                        fontWeight: FontWeight.bold
                    )
                ),
              ),
            ],
          ),
          Row(
            children: [
              Padding(
                padding: EdgeInsets.only(left: 42.0),
                child: Text(
                    '01/02/2021',
                    style: TextStyle(
                      color: Colors.grey.shade400,
                      fontSize: 10,
                    )
                ),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Container(
                padding: const EdgeInsets.only(right: 16, left: 24),
                width: c_width,
                child: new Column(
                  children: [
                    Text(
                        'Тексттексттексттексттексттексттексттексттексттексттексттексттексттексттексттексттексттексттексттексттексттек',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 11,
                        )
                    )
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );

    Widget detailNews = Container(
          padding: EdgeInsets.only(top: 160),
          color: Colors.white.withOpacity(0.0),
          child: Stack(
            children: [
              Row(
                children: [
                  Padding(
                    padding: EdgeInsets.all(32),
                    child: Column(
                      textDirection: TextDirection.ltr,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          _current_news==null?'':_getNameDay(_current_news.date),
                          textDirection: TextDirection.ltr,
                          style: TextStyle(
                              color: default_color_black,
                              fontSize: 12,
                              letterSpacing: 2
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(top: 8, bottom: 8),
                          child: Text(
                              _current_news==null?'':intl.DateFormat.MMMMd('ru_RU').format(intl.DateFormat('dd/MM/yyyy').parse(_current_news.date)).toUpperCase(),
                              textDirection: TextDirection.ltr,
                              style: TextStyle(
                                  color: default_color_black,
                                  fontSize: 18,
                              )
                          ),
                        ),
                        Container(
                          width: c_width,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                  _current_news==null?'':_current_news.titleNews,
                                  textDirection: TextDirection.ltr,
                                  style: TextStyle(
                                      color: default_color_red,
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold
                                  )
                              ),
                            ],
                          ),
                        ),
                        Container(
                          width: c_width,
                          padding: EdgeInsets.only(top: 8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text(
                                  _current_news==null?'':_current_news.text,
                                  textDirection: TextDirection.ltr,
                                  style: TextStyle(
                                      color: default_color_black,
                                      fontSize: 10,

                                  )
                              ),
                            ],
                          ),
                        ),

                      ],
                    ),
                  )
                ],
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: new GestureDetector(
                  onTap: () {
                    setState(() {
                      _current_news = null;
                    });
                  },
                  child: Container(
                    color: Colors.transparent,
                    alignment: Alignment.centerLeft,
                    padding: EdgeInsets.only(left: 32),
                    height: 56,
                    child: Image.asset(
                      'assets/icons/ic_icon_arrow_back.png',
                      height: 24.0,
                      width: 48.0,
                    ),
                  ),
                ),
              )
            ],
          )
      );

    Widget widgetListView = ListView.builder(
        padding: EdgeInsets.only(top: 160),
        scrollDirection: Axis.vertical,
        shrinkWrap: true,
        itemCount: listNews.length,
        physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
        itemBuilder: (BuildContext context, int index) {
          return Padding(
            padding: EdgeInsets.all(16.0),
            child: new GestureDetector(
              onTap: () {

                setState(() {
                  _current_news = listNews[index];
                });
              },
              child: Column(
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Image.asset(
                        'assets/icons/ic_promotion.png',
                        height: 24.0,
                        width: 24.0,
                      ),

                      Padding(
                        padding: EdgeInsets.only(left: 16.0),
                        child: Container(
                          width: c_width,
                          child: new Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                  listNews[index].titleNews,
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                  style: TextStyle(
                                    color: default_color_red,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  )
                              )
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Padding(
                        padding: EdgeInsets.only(left: 42.0),
                        child: Text(
                            listNews[index].date,
                            style: TextStyle(
                              color: Colors.grey.shade400,
                              fontSize: 10,
                            )
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Container(
                        padding: const EdgeInsets.only(right: 16, left: 24),
                        width: c_width,
                        child: new Column(
                          children: [
                            Text(
                                listNews[index].text,
                                overflow: TextOverflow.ellipsis,
                                maxLines: 3,
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: 11,
                                )
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        }
    );



    Widget widgetNews = Stack(
      children: [
        _current_news==null?widgetListView:detailNews,
        Container(
            height: height_header,
            child: new OverflowBox(
              minWidth: 0.0,
              minHeight: 0.0,
              child: Image.asset(
                'assets/icons/img_news_page.png',
                fit: BoxFit.cover,
                height: MediaQuery.of(context).size.height,
                width: MediaQuery.of(context).size.width,
                alignment: Alignment.center,
              ),
            )
        ),
      ],
    );

    Widget widgetListViewNotifications = ListView.builder(
        padding: EdgeInsets.only(top: 160),
        scrollDirection: Axis.vertical,
        shrinkWrap: true,
        itemCount: listAppNotification.length,
        physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
        itemBuilder: (BuildContext context, int index) {
          return Padding(
            padding: EdgeInsets.all(16.0),
            child: new GestureDetector(
              onTap: () {

                setState(() {
                  _index_current_notif = index;
                });
              },
              child: Column(
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Image.asset(
                        'assets/icons/ic_notifications_bell.png',
                        height: 24.0,
                        width: 24.0,
                        color: listAppNotification[index].status==false?default_color_red:default_color_black,
                      ),

                      Padding(
                        padding: EdgeInsets.only(left: 16.0),
                        child: Container(
                          width: c_width,
                          child: new Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                  listAppNotification[index].titleNotif,
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                  style: TextStyle(
                                    color: listAppNotification[index].status==false?default_color_red:default_color_black,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  )
                              )
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Padding(
                        padding: EdgeInsets.only(left: 42.0),
                        child: Text(
                            listNews[index].date,
                            style: TextStyle(
                              color: Colors.grey.shade400,
                              fontSize: 10,
                            )
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Container(
                        padding: const EdgeInsets.only(right: 16, left: 24),
                        width: c_width,
                        child: new Column(
                          children: [
                            Text(
                                listNews[index].text,
                                overflow: TextOverflow.ellipsis,
                                maxLines: 3,
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: 11,
                                )
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        }
    );

    Widget detailNotification = Container(
        padding: EdgeInsets.only(top: 160),
        color: Colors.white.withOpacity(0.0),
        child: Stack(
          children: [
            Row(
              children: [
                Padding(
                  padding: EdgeInsets.all(32),
                  child: Column(
                    textDirection: TextDirection.ltr,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        _index_current_notif==-1?'':_getNameDay(listAppNotification[_index_current_notif].date),
                        textDirection: TextDirection.ltr,
                        style: TextStyle(
                            color: default_color_black,
                            fontSize: 12,
                            letterSpacing: 2
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: 8, bottom: 8),
                        child: Text(
                            _index_current_notif==-1?'':intl.DateFormat.MMMMd('ru_RU').format(intl.DateFormat('dd/MM/yyyy').parse(listAppNotification[_index_current_notif].date)).toUpperCase(),
                            textDirection: TextDirection.ltr,
                            style: TextStyle(
                              color: default_color_black,
                              fontSize: 18,
                            )
                        ),
                      ),
                      Container(
                        width: c_width,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                                _index_current_notif==-1?'':listAppNotification[_index_current_notif].titleNotif,
                                textDirection: TextDirection.ltr,
                                style: TextStyle(
                                    color: _index_current_notif==-1?default_color_black:listAppNotification[_index_current_notif].status==false?default_color_red:default_color_black,
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold
                                )
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: c_width,
                        padding: EdgeInsets.only(top: 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                                _index_current_notif==-1?'':listAppNotification[_index_current_notif].text,
                                textDirection: TextDirection.ltr,
                                style: TextStyle(
                                  color: default_color_black,
                                  fontSize: 10,
                                )
                            ),
                          ],
                        ),
                      ),

                    ],
                  ),
                )
              ],
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: new GestureDetector(
                onTap: () {
                  setState(() {
                    listAppNotification[_index_current_notif].status = true;
                    _index_current_notif = -1;
                  });
                },
                child: Container(
                  color: Colors.transparent,
                  alignment: Alignment.centerLeft,
                  padding: EdgeInsets.only(left: 32),
                  height: 56,
                  child: Image.asset(
                    'assets/icons/ic_icon_arrow_back.png',
                    height: 24.0,
                    width: 48.0,
                  ),
                ),
              ),
            )
          ],
        )
    );

    Widget widgetNotifications = Stack(
      children: [
        _index_current_notif==-1?widgetListViewNotifications:detailNotification,
        Container(
            height: height_header,
            child: new OverflowBox(
              minWidth: 0.0,
              minHeight: 0.0,
              child: Image.asset(
                'assets/icons/img_notifications_page.png',
                fit: BoxFit.cover,
                height: MediaQuery.of(context).size.height,
                width: MediaQuery.of(context).size.width,
                alignment: Alignment.center,
              ),
            )
        ),
      ],
    );


    Widget widgetAddressMoscow1 = Padding(
      padding: EdgeInsets.only(top: 16.0),
      child: Column(
        children: [
          Row(
            mainAxisSize: MainAxisSize.max,
            children: [
              Image.asset(
                'assets/icons/ic_placeholder.png',
                height: 24.0,
                width: 24.0,
              ),
              Padding(
                padding: EdgeInsets.only(left: 12.0),
                child: Text(
                    'Метро «Тимирязевская»',
                    style: TextStyle(
                        color: default_color_red,
                        fontSize: 13,
                        fontWeight: FontWeight.bold
                    )
                ),
              ),

            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Container(
                padding: const EdgeInsets.only(right: 16, left: 16),
                width: c_width,
                child: new Column(
                  children: [
                    Text(
                        '127322, Россия, г. Москва, ул.Яблочкова, д. 21, к. 3',
                        style: TextStyle(
                          color: default_color_black,
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                        )
                    )
                  ],
                ),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,

            children: [
              Container(
                padding: const EdgeInsets.only(right: 16, left: 40),
                width: c_width,
                child: new Column(
                  children: [
                    Text(
                        '',
                        style: TextStyle(
                          color: default_color_black,
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                        )
                    )
                  ],
                ),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Container(
                padding: const EdgeInsets.only(right: 16, left: 16),

                child: new Column(
                  children: [
                    Text(
                        ' 8 800 201-27-42 (звонок по России бесплатный) \n +7(499) 995-07-42 \n Мобильный: +7(916) 097-95-28 \n\n '
                            'Часы работы: \n Пн.-пт.: 9:00-19:00 (без обеда). \n Сб.: 9:00-17:00; \n вс. - выходной ',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 11,
                        )
                    )
                  ],
                ),
              ),
            ],
          ),
          Padding(
            padding: EdgeInsets.only(top: 64),
            child: Text(
                ' 8 (800) 201-27-42 ',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: default_color_red,
                  fontSize: 14,
                )
            ),
          ),
          Padding(
            padding: EdgeInsets.only(top: 2),
            child: Text(
                ' Единый номер телефона ',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: default_color_black,
                  fontSize: 9,
                )
            ),
          ),
        ],
      ),
    );

    Widget widgetSelectedAddress = Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Row(
            mainAxisSize: MainAxisSize.max,
            children: [
              Padding(
                padding: EdgeInsets.only(left: 0),
                child: Text(
                    'АДРЕСА ОФИСОВ В МОСКВЕ',
                    style: TextStyle(
                        color: default_color_red,
                        fontSize: 14,
                        fontWeight: FontWeight.bold
                    )
                ),
              ),
            ],
          ),
          Padding(
            padding: EdgeInsets.only(top: 0),
            child: Column /*or Column*/(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                widgetAddressMoscow1,

              ],
            ),
          ),
        ],
      ),
    );

    Widget widgetAddressesMoscow = ListView(
      scrollDirection: Axis.vertical,
      shrinkWrap: true,
      padding: const EdgeInsets.only(top: 8, bottom: 8, left: 8, right: 8),
      physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
      children:[
        Column(
          children: [
            Container(
              margin: EdgeInsets.only(top: 212),
              color: Colors.white.withOpacity(0.0),
              child: Column(
                children: [
                  Row(
                    children: [
                      _indexContact==indexMoscow?
                      Padding(
                        padding: EdgeInsets.all(16),
                        child: Text(
                          'АДРЕСА ОФИСОВ В МОСКВЕ'.toUpperCase(),
                          style: TextStyle(
                              fontSize: 16,
                              color: default_color_red,
                              fontWeight: FontWeight.bold
                          ),
                        ),

                      )
                          :_indexContact==indexPitherburg?
                      Padding(
                        padding: EdgeInsets.all(16),
                        child: Text(
                          'АДРЕСА ОФИСОВ В САНКТ-ПЕТЕРБУРГЕ'.toUpperCase(),
                          style: TextStyle(
                              fontSize: 16,
                              color: default_color_red,
                              fontWeight: FontWeight.bold
                          ),
                        ),

                      )
                          :
                      Padding(
                        padding: EdgeInsets.all(16),
                        child: Text(
                          'АДРЕСА ОФИСОВ В СИМФЕРОПОЛЕ'.toUpperCase(),
                          style: TextStyle(
                              fontSize: 16,
                              color: default_color_red,
                              fontWeight: FontWeight.bold
                          ),
                        ),

                      ),
                    ],
                  ),

                ],
              ),
            )
          ],
        ),
        Column(
          textDirection: TextDirection.ltr,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              color: Colors.white.withOpacity(0.0),
              padding: EdgeInsets.only(left:8, right: 8),
              height: 40,
              child: Row(
                children: [
                  Image.asset(
                    'assets/icons/ic_placeholder.png',
                    height: 24.0,
                    width: 24.0,
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: 6.0),
                    child: Text(
                        'Метро «Тимирязевская»',
                        style: TextStyle(
                            color: default_color_red,
                            fontSize: 14,
                            fontWeight: FontWeight.bold
                        )
                    ),
                  )
                ],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Container(
                  padding: const EdgeInsets.only(left: 8),
                  width: c_width,
                  child: new Column(
                    children: [
                      Text(
                          '127322, Россия, г. Москва, ул.Яблочкова, д. 21, к. 3 \n Многоканальный',
                          style: TextStyle(
                            color: default_color_black,
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                          )
                      )
                    ],
                  ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.only(right: 8, left: 36),

                  child: new Column(
                    children: [
                      Text(
                          ' 8 800 201-27-42 (звонок по России бесплатный) \n +7(499) 995-07-42 \n Мобильный: +7(916) 097-95-28 \n\n '
                              'Часы работы: \n Пн.-пт.: 9:00-19:00 (без обеда). \n Сб.: 9:00-17:00; \n вс. - выходной ',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 11,
                          )
                      )
                    ],
                  ),
                ),
              ],
            )
          ],
        ),
        Column(
          textDirection: TextDirection.ltr,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              color: Colors.white.withOpacity(0.0),
              padding: EdgeInsets.only(left:8, right: 8),
              height: 40,
              child: Row(
                children: [
                  Image.asset(
                    'assets/icons/ic_placeholder.png',
                    height: 24.0,
                    width: 24.0,
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: 6.0),
                    child: Text(
                        'Метро «Парк Культуры»',
                        style: TextStyle(
                            color: default_color_red,
                            fontSize: 14,
                            fontWeight: FontWeight.bold
                        )
                    ),
                  )
                ],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Container(
                  padding: const EdgeInsets.only(left: 8),
                  width: c_width,
                  child: new Column(
                    children: [
                      Text(
                          '119021, Россия, г. Москва, Зубовский б-р, д. 13, стр. 1 (под. 1, эт. 6, пом. 5)',
                          style: TextStyle(
                            color: default_color_black,
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                          )
                      )
                    ],
                  ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.only(right: 8, left: 36),

                  child: new Column(
                    children: [
                      Text(
                          ' Тел./ факс: +7(499) 246-54-71 \n  Мобильный: +7(916) 388-68-25 \n\n '
                              'Часы работы: \n Пн.-пт.: 9:00-18:00 (без обеда); \n б., Вс. - выходной ',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 11,
                          )
                      )
                    ],
                  ),
                ),
              ],
            )
          ],
        )
      ],
    );

    Widget widgetAddressesPiter = ListView(
      scrollDirection: Axis.vertical,
      shrinkWrap: true,
      padding: const EdgeInsets.only(top: 8, bottom: 8, left: 8, right: 8),
      physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
      children:[
        Column(
          children: [
            Container(
              margin: EdgeInsets.only(top: 212),
              color: Colors.white.withOpacity(0.0),
              child: Column(
                children: [
                  Row(
                    children: [
                      _indexContact==indexMoscow?
                      Padding(
                        padding: EdgeInsets.all(16),
                        child: Text(
                          'АДРЕСА ОФИСОВ В МОСКВЕ'.toUpperCase(),
                          style: TextStyle(
                              fontSize: 16,
                              color: default_color_red,
                              fontWeight: FontWeight.bold
                          ),
                        ),

                      )
                          :_indexContact==indexPitherburg?
                      Padding(
                        padding: EdgeInsets.all(16),
                        child: Text(
                          'АДРЕСА ОФИСОВ В САНКТ-ПЕТЕРБУРГЕ'.toUpperCase(),
                          style: TextStyle(
                              fontSize: 16,
                              color: default_color_red,
                              fontWeight: FontWeight.bold
                          ),
                        ),

                      )
                          :
                      Padding(
                        padding: EdgeInsets.all(16),
                        child: Text(
                          'АДРЕСА ОФИСОВ В СИМФЕРОПОЛЕ'.toUpperCase(),
                          style: TextStyle(
                              fontSize: 16,
                              color: default_color_red,
                              fontWeight: FontWeight.bold
                          ),
                        ),

                      ),
                    ],
                  ),

                ],
              ),
            )
          ],
        ),
        Column(
          textDirection: TextDirection.ltr,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              color: Colors.white.withOpacity(0.0),
              padding: EdgeInsets.only(left:8, right: 8),
              height: 40,
              child: Row(
                children: [
                  Image.asset(
                    'assets/icons/ic_placeholder.png',
                    height: 24.0,
                    width: 24.0,
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: 6.0),
                    child: Text(
                        'ул.Чудновского',
                        style: TextStyle(
                            color: default_color_red,
                            fontSize: 14,
                            fontWeight: FontWeight.bold
                        )
                    ),
                  )
                ],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Container(
                  padding: const EdgeInsets.only(left: 8),
                  width: c_width,
                  child: new Column(
                    children: [
                      Text(
                          '193231, Россия, г. Санкт-Петербург, ул.Чудновского, д.19, литер А, пом.5Н \n Многоканальный',
                          style: TextStyle(
                            color: default_color_black,
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                          )
                      )
                    ],
                  ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.only(right: 8, left: 36),

                  child: new Column(
                    children: [
                      Text(
                          ' 8 800 201-27-42 (звонок по России бесплатный) \n +7(812) 442-70-22 \n Мобильный: +7(960) 267-07-30, +7(981) 171-17-18 \n\n '
                              'Часы работы: \n Пн.-пт.: 9:00-18:00 (без обеда). \n Сб.: 9:30-17:00; \n вс. - выходной \n\n'
                              'skype: 398-568-186 (Консультации по продукции) \n E-mail: spb@kassis.ru'
                          ,
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 11,
                          )
                      )
                    ],
                  ),
                ),
              ],
            )
          ],
        ),

      ],
    );

    Widget widgetAddressesSimpheropol = ListView(
      scrollDirection: Axis.vertical,
      shrinkWrap: true,
      padding: const EdgeInsets.only(top: 8, bottom: 8, left: 8, right: 8),
      physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
      children:[
        Column(
          children: [
            Container(
              margin: EdgeInsets.only(top: 212),
              color: Colors.white.withOpacity(0.0),
              child: Column(
                children: [
                  Row(
                    children: [
                      _indexContact==indexMoscow?
                      Padding(
                        padding: EdgeInsets.all(16),
                        child: Text(
                          'АДРЕСА ОФИСОВ В МОСКВЕ'.toUpperCase(),
                          style: TextStyle(
                              fontSize: 16,
                              color: default_color_red,
                              fontWeight: FontWeight.bold
                          ),
                        ),

                      )
                          :_indexContact==indexPitherburg?
                      Padding(
                        padding: EdgeInsets.all(16),
                        child: Text(
                          'АДРЕСА ОФИСОВ В САНКТ-ПЕТЕРБУРГЕ'.toUpperCase(),
                          style: TextStyle(
                              fontSize: 16,
                              color: default_color_red,
                              fontWeight: FontWeight.bold
                          ),
                        ),

                      )
                          :
                      Padding(
                        padding: EdgeInsets.all(16),
                        child: Text(
                          'АДРЕСА ОФИСОВ В СИМФЕРОПОЛЕ'.toUpperCase(),
                          style: TextStyle(
                              fontSize: 16,
                              color: default_color_red,
                              fontWeight: FontWeight.bold
                          ),
                        ),

                      ),
                    ],
                  ),

                ],
              ),
            )
          ],
        ),
        Column(
          textDirection: TextDirection.ltr,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              color: Colors.white.withOpacity(0.0),
              padding: EdgeInsets.only(left:8, right: 8),
              height: 40,
              child: Row(
                children: [
                  Image.asset(
                    'assets/icons/ic_placeholder.png',
                    height: 24.0,
                    width: 24.0,
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: 6.0),
                    child: Text(
                        'ул. Кечкеметская',
                        style: TextStyle(
                            color: default_color_red,
                            fontSize: 14,
                            fontWeight: FontWeight.bold
                        )
                    ),
                  )
                ],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Container(
                  padding: const EdgeInsets.only(left: 8),
                  width: c_width,
                  child: new Column(
                    children: [
                      Text(
                          '295022, Россия, г. Симферополь, ул. Кечкеметская, д. 120.',
                          style: TextStyle(
                            color: default_color_black,
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                          )
                      )
                    ],
                  ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.only(right: 8, left: 36),

                  child: new Column(
                    children: [
                      Text(
                          ' 8 800 201-27-42 (звонок по России бесплатный) \n Тел.: +7(989) 277-85-85 \n\n '
                              'Часы работы: \n Пн.-пт.: 9:00-18:00 (без обеда). \n Сб., вс. - выходной ',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 11,
                          )
                      )
                    ],
                  ),
                ),
              ],
            )
          ],
        ),
      ],
    );

    Widget Contacts = Stack(
      children: [
        Container(
          margin: EdgeInsets.only(bottom: height_header),
          child: _indexContact==indexMoscow?widgetAddressesMoscow:_indexContact==indexPitherburg?widgetAddressesPiter:widgetAddressesSimpheropol,
        ),

        Container(
            height: height_header,
            child: new OverflowBox(
              minWidth: 0.0,
              minHeight: 0.0,
              child: Image.asset(
                'assets/icons/img_contacts_page.png',
                fit: BoxFit.cover,
                height: MediaQuery.of(context).size.height,
                width: MediaQuery.of(context).size.width,
                alignment: Alignment.center,
              ),
            )
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            height: 56,
            color: Colors.white.withOpacity(0.0),
            child: new GestureDetector(
              onTap: () {
                launch("tel://88002012742");
              },
              child: Column(
                children: [
                  Text(
                    '8 (800) 201-27-42',
                    style: TextStyle(
                      fontSize: 18,
                      color: default_color_red
                    ),
                  ),
                  Text(
                    'Единый номер телефона',
                    style: TextStyle(
                        fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        Container(
          height: 56,
          margin: EdgeInsets.only(top:height_header),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            textDirection: TextDirection.ltr,
            children: [
              Expanded(
                  flex: 1,
                  child: new InkWell(
                    onTap: () {
                      setState(() {
                        _indexContact = indexMoscow;
                      });
                    },
                    child: Padding(
                      padding: EdgeInsets.only(left: 16, right: 8),
                      child: Container(
                          height: 48,
                          decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey.shade400),
                              color: _indexContact==indexMoscow?default_color_red:Colors.grey.shade500,
                              borderRadius: BorderRadius.only(
                                  bottomLeft: Radius.circular(8),
                                  bottomRight: Radius.circular(8)
                              )
                          ),

                          child: Align(
                            alignment: Alignment.center,
                            child: Text(
                              'Москва',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          )

                      ),
                    ),
                  )

              ),
              Expanded(
                  flex: 1,
                  child: new InkWell(
                    onTap: () {
                      setState(() {
                        _indexContact = indexPitherburg;
                      });
                    },
                    child: Padding(
                      padding: EdgeInsets.only(left: 8, right: 8),
                      child: Container(
                          height: 48,
                          decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey.shade400),
                              color: _indexContact==indexPitherburg?default_color_red:Colors.grey.shade500,
                              borderRadius: BorderRadius.only(
                                  bottomLeft: Radius.circular(8),
                                  bottomRight: Radius.circular(8)
                              )
                          ),

                          child: Align(
                            alignment: Alignment.center,
                            child: Text(
                              'Санкт-Петербург',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          )

                      ),
                    ),
                  )

              ),
              Expanded(
                  flex: 1,
                  child: new InkWell(
                    onTap: () {
                      setState(() {
                        _indexContact = indexSimpheropol;
                      });
                    },
                    child: Padding(
                      padding: EdgeInsets.only(left: 8, right: 16),
                      child: Container(
                          height: 48,
                          padding: EdgeInsets.all(2),
                          decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey.shade400),
                              color: _indexContact==indexSimpheropol?default_color_red:Colors.grey.shade500,
                              borderRadius: BorderRadius.only(
                                  bottomLeft: Radius.circular(8),
                                  bottomRight: Radius.circular(8)
                              )
                          ),

                          child: Align(
                            alignment: Alignment.center,
                            child: Text(
                              'Симферополь',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                              textAlign: TextAlign.center,
                              overflow: TextOverflow.ellipsis,
                            ),
                          )

                      ),
                    ),
                  )

              )

            ],
          ),
        ),
      ],
    );



    Widget widgetFeedback = Stack(
      children: [
        SingleChildScrollView(
          child: ListView(
            scrollDirection: Axis.vertical,
            shrinkWrap: true,
            padding: const EdgeInsets.only(top: 8, bottom: 8, left: 8, right: 8),
            physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
            children: <Widget> [
              Container(
                height: height_header,
              ),
              Padding(
                padding: EdgeInsets.all(16),
                child: Container(
                  child: Text(
                      'Оставьте отзыв',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: default_color_red,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      )
                  ),
                ),
              ),
              Padding(
                  padding: EdgeInsets.all(16),
                  child: Align(
                    alignment: Alignment.center,
                    child: Container(
                      child: Text(
                          'о работе наших магазинов, интернет-магазина и службы доставки',
                          softWrap: true,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: default_color_black,
                            fontSize: 12,
                          )
                      ),
                    ),
                  )
              ),
              Padding(
                  padding: EdgeInsets.only(
                      top: 16,
                      left: 16,
                      right: 16,
                      bottom: MediaQuery.of(context).viewInsets.bottom),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      width: MediaQuery.of(context).size.width*0.7,
                      child: TextField(
                          decoration: InputDecoration(
                              hintText: 'Имя и фамилия:'
                          ),
                          style: TextStyle(
                              color: default_color_black,
                              fontSize: 12,
                              letterSpacing: 2
                          ),
                          keyboardType: TextInputType.name,
                          autofocus: false,
                          maxLines: 1,
                          controller: null),
                    ),
                  )
              ),
              Padding(
                  padding: EdgeInsets.only(
                      top: 16,
                      left: 16,
                      right: 16,
                      bottom: MediaQuery.of(context).viewInsets.bottom),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      width: MediaQuery.of(context).size.width*0.7,
                      child: TextField(
                          decoration: InputDecoration(
                              hintText: 'Телефон:'
                          ),
                          style: TextStyle(
                              color: default_color_black,
                              fontSize: 12,
                              letterSpacing: 2
                          ),
                          autofocus: false,
                          keyboardType: TextInputType.phone,
                          maxLines: 1,
                          controller: null),
                    ),
                  )
              ),
              Padding(
                  padding: EdgeInsets.only(
                      top: 16,
                      left: 16,
                      right: 16,
                      bottom: MediaQuery.of(context).viewInsets.bottom),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      width: MediaQuery.of(context).size.width*0.7,
                      child: TextField(
                          decoration: InputDecoration(
                              hintText: 'Почта:'
                          ),
                          style: TextStyle(
                              color: default_color_black,
                              fontSize: 12,
                              letterSpacing: 2
                          ),
                          autofocus: false,
                          keyboardType: TextInputType.emailAddress,
                          maxLines: 1,
                          controller: null),
                    ),
                  )
              ),
              Padding(
                  padding: EdgeInsets.only(
                      top: 16,
                      left: 16,
                      right: 16,
                      bottom: MediaQuery.of(context).viewInsets.bottom),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      width: MediaQuery.of(context).size.width*0.9,
                      height: 100,
                      decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade400),
                          borderRadius: BorderRadius.circular(8)
                      ),
                      margin: EdgeInsets.only(top: 8),
                      padding: EdgeInsets.only(
                          top: 2,
                          left: 8,
                          right: 8,
                          bottom: 2
                      ),
                      child: TextField(
                          decoration: InputDecoration(
                              hintText: 'Введите ваше сообщение:',
                              focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.white),
                              )
                          ),
                          style: TextStyle(
                            color: default_color_black,
                            fontSize: 12,
                            letterSpacing: 2,
                          ),
                          autofocus: false,
                          maxLength: 50,
                          keyboardType: TextInputType.emailAddress,
                          maxLines: 5,
                          controller: null),
                    ),
                  )
              ),
              Padding(
                  padding: EdgeInsets.only(
                      top: 16,
                      left: 16,
                      right: 16,
                      bottom: MediaQuery.of(context).viewInsets.bottom),
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Container(
                      width: MediaQuery.of(context).size.width*0.5,
                      margin: EdgeInsets.only(top: 8),
                      padding: EdgeInsets.only(
                          top: 2,
                          left: 8,
                          right: 8,
                          bottom: 2
                      ),
                      child: new RaisedButton(
                        child: Text(
                            "Отправить",
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 12
                            )
                        ),
                        onPressed: () {},
                        highlightColor: default_color_red,
                        color: default_color_red,
                        textColor: Colors.white,
                        padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                        highlightElevation: heightElevation,
                        elevation: elevationButton,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(0)
                        ),
                        colorBrightness: Brightness.light,
                      ),
                    ),
                  )
              )
            ],
          ),
        ),
        Container(
            height: height_header,
            child: new OverflowBox(
              minWidth: 0.0,
              minHeight: 0.0,
              child: Image.asset(
                'assets/icons/img_feedback_page.png',
                fit: BoxFit.cover,
                height: MediaQuery.of(context).size.height,
                width: MediaQuery.of(context).size.width,
                alignment: Alignment.center,
              ),
            )
        ),
      ],
    );


    Widget widgetActions = Column /*or Column*/(
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        Container(
            height: height_header,
            child: new OverflowBox(
              minWidth: 0.0,
              minHeight: 0.0,
              child: Image.asset(
                'assets/icons/img_actions_page.png',
                fit: BoxFit.cover,
                height: MediaQuery.of(context).size.height,
                width: MediaQuery.of(context).size.width,
                alignment: Alignment.center,
              ),
            )
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            CarouselSlider(
              options: CarouselOptions(
                height: 400,
                viewportFraction: 1.0,
                autoPlay: true,
                autoPlayInterval: Duration(seconds: 4),
                autoPlayAnimationDuration: Duration(milliseconds: 800),
                autoPlayCurve: Curves.fastOutSlowIn,
                pauseAutoPlayOnTouch: true,
                aspectRatio: 2.0,
                onPageChanged: (index, reason) {
                  setState(() {
                    _currentIndex = index;
                  });
                },
              ),
              items: cardList.map((card){
                return Builder(
                    builder:(BuildContext context){
                      return Container(
                        height: MediaQuery.of(context).size.height*0.30,
                        width: MediaQuery.of(context).size.width,
                        child: Card(
                          elevation: 0,
                          color: Colors.white,
                          child: card,
                        ),
                      );
                    }
                );
              }).toList(),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: cardList.map((url) {
                int i = cardList.indexOf(url);
                return Container(
                  width: 12.0,
                  height: 12.0,
                  margin: EdgeInsets.symmetric(vertical: 10.0, horizontal: 6.0),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _currentIndex == i
                        ? default_color_red
                        : Colors.red.shade200,
                  ),
                );
              }).toList(),
            ),
          ],
        )
      ],
    );



    InAppWebViewController _webViewController;

    Widget marketOnline = InAppWebView(
      initialUrl: "https://kassis.ru/magazin/",
      initialOptions: InAppWebViewGroupOptions(
          crossPlatform: InAppWebViewOptions(
            debuggingEnabled: true,
          )
      ),
      onWebViewCreated: (InAppWebViewController controller) {
        _webViewController = controller;
      },
      onLoadStart: (InAppWebViewController controller, String url) {
        setState(() {
          //this.url = url;
        });
      },
      onLoadStop: (InAppWebViewController controller, String url) async {
        setState(() {
          //this.url = url;
        });
      },
      onProgressChanged: (InAppWebViewController controller, int progress) {
        setState(() {
          //this.progress = progress / 100;
        });
      },
    );

    Widget schoolOnline = InAppWebView(
      initialUrl: "https://kassis.ru/seminaryi",
      initialOptions: InAppWebViewGroupOptions(
          crossPlatform: InAppWebViewOptions(
            debuggingEnabled: true,
          )
      ),
      onWebViewCreated: (InAppWebViewController controller) {
        _webViewController = controller;
      },
      onLoadStart: (InAppWebViewController controller, String url) {
        setState(() {
          //this.url = url;
        });
      },
      onLoadStop: (InAppWebViewController controller, String url) async {
        setState(() {
          //this.url = url;
        });
      },
      onProgressChanged: (InAppWebViewController controller, int progress) {
        setState(() {
          //this.progress = progress / 100;
        });
      },
    );

    Color _alpha = Colors.white.withOpacity(0.2);

    return Scaffold(
      drawerScrimColor: Colors.transparent,
      endDrawer: Theme(
        data: Theme.of(context).copyWith(
          // Set the transparency here
          canvasColor: Colors.white.withOpacity(0.9), //or any other color you want. e.g Colors.blue.withOpacity(0.5)
        ),
        child: Drawer(
          elevation: 0.0,
          child: Container(
            decoration: new BoxDecoration(
            ),
            child: Column(
              children: <Widget>[
                Opacity(
                  opacity: 1.0,
                  child: Container(
                    height: 56.0,
                    decoration: new BoxDecoration(
                      color: _alpha,
                    ),
                  ),
                )              ,
                Container(
                  color: _alpha,
                  child: ListTile(
                    title: new Text(
                      "О компании",
                      style: TextStyle(
                          color: currentItemID==itemAbout?default_color_red:default_color_black,
                          fontSize: 18.0
                      ),
                    ),
                    onTap: (){
                      Navigator.of(context).pop();
                      _selectItemMenu(itemAbout);
                    },
                  ),
                ),
                Container(
                  color: _alpha,
                  child: ListTile(
                    title: new Text(
                      "Новости",
                      style: TextStyle(
                          color: currentItemID==itemNews?default_color_red:default_color_black,
                          fontSize: 18.0
                      ),
                    ),
                    onTap: (){
                      Navigator.of(context).pop();
                      _selectItemMenu(itemNews);
                    },
                  ),
                ),
                Container(
                  color: _alpha,
                  child: ListTile(
                    title: new Text(
                      "Акции",
                      style: TextStyle(
                          color: currentItemID==itemActions?default_color_red:default_color_black,
                          fontSize: 18.0
                      ),
                    ),
                    onTap: (){
                      Navigator.of(context).pop();
                      _selectItemMenu(itemActions);
                    },
                  ),
                ),
                Container(
                  color: _alpha,
                  width: double.infinity,
                  child: Column(
                    children: <Widget> [
                      ListTile(
                        title: new Text(
                          "Уведомления",
                          style: TextStyle(
                              color: currentItemID==itemNotifications?default_color_red:default_color_black,
                              fontSize: 18.0
                          ),
                        ),
                        trailing: Container(
                            height:30,
                            width:30,
                            color:Colors.transparent,
                            child: Icon(Icons.circle, color: getCountNotification()>0?default_color_red:Colors.transparent, size: 12,)),
                        onTap: (){
                          Navigator.of(context).pop();
                          _selectItemMenu(itemNotifications);
                        },
                      ),
                    ],
                  ),
                ),
                Container(
                  color: _alpha,
                  child: ListTile(
                    title: new Text(
                      "Интернет-магазин",
                      style: TextStyle(
                          color: currentItemID==itemMarket?default_color_red:default_color_black,
                          fontSize: 18.0
                      ),
                    ),
                    onTap: (){
                      Navigator.of(context).pop();
                      _selectItemMenu(itemMarket);
                    },
                  ),
                ),
                Container(
                  color: _alpha,
                  child: ListTile(
                    title: new Text(
                      "Оставить отзыв",
                      style: TextStyle(
                          color: currentItemID==itemFeedback?default_color_red:default_color_black,
                          fontSize: 18.0
                      ),
                    ),
                    onTap: (){
                      Navigator.of(context).pop();
                      _selectItemMenu(itemFeedback);
                    },
                  ),
                ),
                Container(
                  color: _alpha,
                  child: ListTile(
                    title: new Text(
                      "Учебный центр",
                      style: TextStyle(
                          color: currentItemID==itemTraining?default_color_red:default_color_black,
                          fontSize: 18.0
                      ),
                    ),
                    onTap: (){
                      Navigator.of(context).pop();
                      _selectItemMenu(itemTraining);
                    },
                  ),
                ),
                Container(
                  decoration: new BoxDecoration(
                    color: _alpha,
                  ),
                  child: ListTile(
                    title: new Text(
                      "Контакты",
                      style: TextStyle(
                          color: currentItemID==itemContacts?default_color_red:default_color_black,
                          fontSize: 18.0
                      ),
                    ),
                    onTap: (){
                      Navigator.of(context).pop();
                      _selectItemMenu(itemContacts);
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          listTitle[currentItemID],
            style: TextStyle(
                color: default_color_black,
                fontWeight: FontWeight.bold,
                fontSize: 20.0

            )
        ),
        backgroundColor: currentItemID==0?colorAppBarDefault:colorAppBarItems,
        elevation: 0.0,
        leading: new GestureDetector(
          onTap: () {
            setState(() {
              currentItemID = itemStart;
              print('Start');
            });
          },
          child: Image.asset(
            'assets/icons/ic_header_logo_x1.png',
            height: 16.0,
            width: 16.0,
          ),
        ),
        actions: [
          Builder(
            builder: (context) => IconButton(
              icon: Image.asset(
                  'assets/icons/ic_menu_x1.png',
                  height: 24.0,
                  width: 24.0,
                color: default_color_red,
              ),
              onPressed: () => Scaffold.of(context).openEndDrawer(),
              tooltip: MaterialLocalizations.of(context).openAppDrawerTooltip,
            ),
          ),
        ],
      ),
      body: currentItemID==itemStart
          ? widgetStart
          : (currentItemID==itemAbout
              ? widgetAbout
              :(currentItemID==itemNews
                ? widgetNews
                :(currentItemID==itemNotifications
                  ? widgetNotifications
                  : (currentItemID==itemActions
                    ? widgetActions
                    : (currentItemID==itemFeedback
                        ? widgetFeedback
                        : (currentItemID==itemContacts
                          ? Contacts
                          : (currentItemID==itemMarket
                            ?marketOnline
                            :(currentItemID==itemTraining
                              ?schoolOnline
                              :Text('')
              )))))))),       // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}


_launchURL() async {
  const url = 'https://kassis.ru/magazin';
  if (await canLaunch(url)) {
    await launch(url);
  } else {
    throw 'Could not launch $url';
  }
}

_action(Action action) {
  return Container(
    padding: EdgeInsets.all(16),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(top: 24),
          child: Container(
            alignment: Alignment.centerLeft,
            child: Text(
                action.title,
                softWrap: true,
                style: TextStyle(
                    color: Colors.red,
                    fontSize: 24.0,
                    fontWeight: FontWeight.bold
                )
            ),
          ),
        ),

        Padding(
          padding: EdgeInsets.only(top: 16),
          child: Container(
            alignment: Alignment.centerLeft,
            child: Text(
                "Срок акции: "+action.date,
                softWrap: true,
                style: TextStyle(
                  color: Colors.grey.shade900,
                  fontSize: 14.0,
                )
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.only(top: 8),
          child: Container(
            alignment: Alignment.centerLeft,
            child: Text(
                action.text,
                softWrap: true,
                style: TextStyle(
                  color: Colors.grey.shade900,
                  fontSize: 11.0,
                )
            ),
          ),
        ),
      ],
    ),
  );
}

_getNameDay(String d) {
  var sd = intl.DateFormat('dd/MM/yyyy').parse(d);

  switch(sd.weekday){
    case 1:
      return 'Понедельник';
      break;
    case 2:
      return 'Вторник';
      break;
    case 3:
      return 'Среда';
      break;
    case 4:
      return 'Четверг';
      break;
    case 5:
      return 'Пятница';
      break;
    case 6:
      return 'Суббота';
      break;
    case 7:
      return 'Воскресение';
      break;
  }

  return sd.weekday;
}




