import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity/connectivity.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:kassis/models/notifications.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:kassis/utils/dialogs.dart';
import 'package:kassis/utils/firebase_tools.dart';
import 'package:kassis/utils/local_notifications.dart';
import 'package:kassis/utils/user_preferences.dart';
import 'package:provider/provider.dart';
import 'package:kassis/databases/db_notifications.dart';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart' as intl;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:firebase_core/firebase_core.dart';

import 'models/action.dart';
import 'models/news_company.dart';
import 'utils/push_notification.dart';

const kAndroidUserAgent =
    'Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/62.0.3202.94 Mobile Safari/537.36';

String selectedUrl = 'https://kassis.ru/magazin';
List<SpecialAction> listActions = <SpecialAction>[];
List<SpecialNews> listNews = <SpecialNews>[];
List<SpecialNotif> listAppNotification = <SpecialNotif>[];
int count_notif = 0;

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.dumpErrorToConsole(details);
    if (kReleaseMode)
      exit(1);
  };

  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown])
      .then((_) => runApp(new MyApp()));
}



class MyApp extends StatelessWidget {

  static final FirebaseMessaging firebaseMessaging = FirebaseMessaging();
  final flutterWebViewPlugin = new FlutterWebviewPlugin();
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {



    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Color(0xFFFC0305),
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Platform.isAndroid ? Brightness.dark : Brightness.light,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarDividerColor: Colors.lightBlue.shade900,
      systemNavigationBarIconBrightness: Brightness.dark,
    ));

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
      builder: (BuildContext context, Widget widget) {
        Widget error = Text('...rendering error...');
        if (widget is Scaffold || widget is Navigator)
          error = Scaffold(body: Center(child: error));
        ErrorWidget.builder = (FlutterErrorDetails errorDetails) => error;
        return widget;
      },
    );
  }
}

var subscription;

class LifecycleEventHandler extends WidgetsBindingObserver {
  final AsyncCallback resumeCallBack;
  final AsyncCallback suspendingCallBack;

  LifecycleEventHandler({
    this.resumeCallBack,
    this.suspendingCallBack,
  });

  @override
  Future<void> didChangeAppLifecycleState(AppLifecycleState state) async {
    switch (state) {
      case AppLifecycleState.resumed:
        if (resumeCallBack != null) {
          await resumeCallBack();
        }
        break;
      case AppLifecycleState.inactive:
      case AppLifecycleState.paused:
        if (suspendingCallBack != null) {
          await suspendingCallBack();
        }
        break;
      case AppLifecycleState.detached:
        if (suspendingCallBack != null) {
          await suspendingCallBack();
        }
        break;
    }
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

class _MyHomePageState extends State<MyHomePage> with SingleTickerProviderStateMixin {

  SpecialNews _current_news = null;
  int _index_current_notif = -1;
  final feedbackKey = GlobalKey<FormState>();
  final String number = "88002012742";

  int _currentIndex = 0;

  List cardList = [];
  List<int> listBackspace = [];



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
  final int itemDoctors         = 8;
  final int itemContacts        = 9;

  final String textAbout = 'Фирма "КАССИС" существует на рынке ортодонтической продукции с 1992 года. Всё это время мы предлагаем ортодонтическую аппаратуру ведущих мировых лидеров, проверенную на собственной клинической базе. Нашими поставщиками являются только проверенные компании, хорошо зарекомендовавшие себя на мировом рынке ортодонтии. Наш накопленный с годами опыт позволяет Вам быть уверенными в качестве предоставляемой продукции, а, следовательно, и в результате лечения.\n\n'
      ' Перечень ортодонтической аппаратуры, предлагаемой нашей фирмой необычайно велик. У нас Вы сможете найти всё необходимое для проведения ортодонтического лечения, начиная от брекет-систем и ортодонтического инструмента и заканчивая необходимыми в процессе лечении средствами гигиены и расходными материалами. Мы предлагаем всё самое и лучшее и востребованное в области ортодонтии в настоящий момент, оправдывая тем самым своё название \n\n КАССИС-ВСЁ ДЛЯ ОРТОДОНТИИ.';

  Widget containerWidget = Text("Test");
  Map<int, String> listTitle = {0:'', 1:'О компании', 2:'Новости', 3:'Акции', 4:'Уведомления', 5:'Интернет-магазин', 6:'Отзыв', 7:'Учебный центр', 8:'Врачам', 9:'Контакты'};

  int currentItemID = 0;
  final Color default_color_red = Color(0xFFFC0305);
  final Color default_color_black = Colors.black;
  final Color colorAppBarDefault = Colors.white;
  final Color colorAppBarItems = Colors.grey;

  AnimationController _controller;
  Animation _animation;
  FocusNode _focusNode = FocusNode();
  intl.DateFormat dateFormat;
  FirebaseApplicationTools  firebaseApplicationTools = new FirebaseApplicationTools();
  Stream<LocalNotification> _notificationsStream;
  TextEditingController _controller_fio = new TextEditingController();
  TextEditingController _controller_phone = new TextEditingController();
  TextEditingController _controller_body = new TextEditingController();
  TextEditingController _controller_email = new TextEditingController();


  @override
  void initState() {
    super.initState();

    final pushNotificationService = PushNotificationService(FirebaseMessaging());
    pushNotificationService.initialise();

    initializeDateFormatting('ru_RU');
    dateFormat = new intl.DateFormat.MEd('ru');

    WidgetsBinding.instance.addObserver(
        LifecycleEventHandler(
            resumeCallBack: () async =>
            setState((

            ) {
          // do something
              UserPreferences userPreferences = UserPreferences();
              userPreferences.setBoolValue('app_open', false);
              _getNotifications();
        })
        )
    );

    _notificationsStream = NotificationsBloc.instance.notificationsStream;
    _notificationsStream.listen((notification) {
      // TODO: Implement your logic here
      print('Notification: $notification');
      _getNotifications();
    });

    subscription = Connectivity().onConnectivityChanged.listen((ConnectivityResult result) {
      // Got a new connectivity status!
      if(result == ConnectivityResult.mobile || result == ConnectivityResult.wifi) {
        print(result);
      }
    });
    _controller = AnimationController(vsync: this, duration: Duration(milliseconds: 300));
    _animation = Tween(begin: 300.0, end: 50.0).animate(_controller)
      ..addListener(() {
        setState(() {});
      });

    _focusNode.addListener(() {
      if (_focusNode.hasFocus) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
    currentItemID = 0;
    _getActions();
    _getNews();
    _getNotifications();
    getCountNotification();
    listBackspace.add(0);

  }


  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    LifecycleEventHandler(
        suspendingCallBack: () {
          UserPreferences userPreferences = UserPreferences();
          userPreferences.setBoolValue('app_open', false);
        }
    );
    super.dispose();
  }

  _getActions() async {
    listActions = await firebaseApplicationTools.getActions(context);
    setState(() {

    });
  }

  _getNews() async {


    listNews = await firebaseApplicationTools.getNews();
    setState(() {

    });

  }

  _getNotifications() async {

    try {
      listAppNotification = await firebaseApplicationTools.getNotifications();
      count_notif = await dbNotifications.db.getCountReads();
    } catch (e) {
      String s = e.toString();
    }


    setState(() {

    });

  }

  _selectItemMenu(int itemID) async {
    listBackspace.add(itemID);
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

  getCountNotification() async {

    count_notif = await dbNotifications.db.getCountReads();

    return count_notif;

  }

  sendFeedbackMessage() async {
    Firebase.initializeApp();
    try {
      var documentReference = FirebaseFirestore.instance
          .collection('feedback')
          .doc();

      FirebaseFirestore.instance.runTransaction((transaction) async {
        transaction.set(
          documentReference,
          {
            'date_created': DateTime.now().millisecondsSinceEpoch,
            'fio': _controller_fio.text.toString(),
            'phone': _controller_phone.text.toString(),
            'email': _controller_email.text.toString(),
            'body': _controller_body.text.toString(),
            'status': 0
          },
        );
      });
      //listScrollController.animateTo(0.0, duration: Duration(milliseconds: 300), curve: Curves.easeOut);
      Fluttertoast.showToast(
          msg: 'Отзыв отправлен',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 12.0
      );
      feedbackKey.currentState.save();
      setState(() {
        // _controller_body.text = '';
        // _controller_email.text = '';
        // _controller_phone.text = '';
        // _controller_fio.text = '';
      });
    } catch (e) {
      String s = e.toString();
      Fluttertoast.showToast(
          msg: e.toString(),
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 12.0
      );
    }

  }

  updateStatusNotification(SpecialNotif notif) async {
    await dbNotifications.db.updateNotification(notif);
  }

  Future<bool> _onBackPressed() {

    if(listBackspace.length < 2) {
      return showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(

              content: Text(
                'Вы хотите закрыть приложение?',

              ),
              actions: <Widget>[
                FlatButton(
                  child: Text(
                    'НЕТ',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade900
                    ),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop(false);
                  },
                ),
                FlatButton(
                  child: Text(
                    'ДА',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.grey
                    ),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop(true);
                    //SystemNavigator.pop();
                    //exit(0);
                  },
                ),
              ],
            );
          });
    } else {
      int l = listBackspace.length-1;
      //listBackspace.remove(listBackspace[l]);
      int backID = listBackspace[listBackspace.length-2];
      listBackspace.remove(listBackspace[l]);
      setState(() {
        currentItemID = backID;
        _current_news =  null;
      });
    }

  }

  Widget roundedButton(String buttonLabel, Color bgColor, Color textColor) {
    var loginBtn = new Container(
      padding: EdgeInsets.all(5.0),
      alignment: FractionalOffset.center,
      decoration: new BoxDecoration(
        color: bgColor,
        borderRadius: new BorderRadius.all(const Radius.circular(10.0)),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: const Color(0xFF696969),
            offset: Offset(1.0, 6.0),
            blurRadius: 0.001,
          ),
        ],
      ),
      child: Text(
        buttonLabel,
        style: new TextStyle(
            color: textColor, fontSize: 20.0, fontWeight: FontWeight.bold),
      ),
    );
    return loginBtn;
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.

    double height_header = MediaQuery.of(context).size.height * 0.30;

     cardList.clear();
     for (var action in listActions){
       cardList.add(_action(context, action));
     }


    getCountNotification() async {

      count_notif = await dbNotifications.db.getCountReads();

      return count_notif;

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
            borderRadius: BorderRadius.circular(4)
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
            borderRadius: BorderRadius.circular(4)
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
          _selectItemMenu(itemMarket);
        },
        highlightColor: default_color_red,
        color: default_color_red,
        textColor: Colors.white,
        padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
        highlightElevation: heightElevation,
        elevation: elevationButton,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4)
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


    Widget widgetAbout = Stack(
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
        Container(
          padding: EdgeInsets.only(top: height_header),
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    textAbout,
                    style: TextStyle(
                      fontSize: 12.0,
                    ),
                  ),
                )
              ],
            ),
          ),
        )
      ],
    );



    double c_width = MediaQuery.of(context).size.width*0.8;


    Widget detailNews = Container(
          padding: EdgeInsets.only(top: height_header),
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
                                  _current_news==null?'':_current_news.title,
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
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _current_news==null?Text(''):Html(data: _current_news.text),
                              // Text(
                              //     _current_news==null?'':_current_news.text,
                              //     textDirection: TextDirection.ltr,
                              //     style: TextStyle(
                              //         color: default_color_black,
                              //         fontSize: 10,
                              //
                              //     )
                              // ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
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
        padding: EdgeInsets.only(top: height_header),
        scrollDirection: Axis.vertical,
        shrinkWrap: true,
        itemCount: listNews.length,
        physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
        itemBuilder: (BuildContext context, int index) {
          String ss = listNews[index].text.toString();
          String s = '''${ss}''';
          return Padding(
            padding: EdgeInsets.all(16.0),
            child: new GestureDetector(
              onTap: () {
                _current_news = listNews[index];
                setState(() {

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
                                  listNews[index].title,
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
                    //mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Container(
                        padding: const EdgeInsets.only(right: 0, left: 42),
                        width: c_width,
                        child: new Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Html(
                              data: "$s",
                            ),
                            // Text(
                            //     '''$s''',
                            //     overflow: TextOverflow.ellipsis,
                            //     maxLines: 3,
                            //     textAlign: TextAlign.start,
                            //     style: TextStyle(
                            //       color: Colors.grey.shade600,
                            //       fontSize: 11,
                            //     )
                            // )
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
        Container(
          margin: EdgeInsets.only(top: 12),
          child: _current_news==null?widgetListView:detailNews,
        ),

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
        padding: EdgeInsets.only(top: height_header),
        scrollDirection: Axis.vertical,
        shrinkWrap: true,
        itemCount: listAppNotification.length,
        physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
        itemBuilder: (BuildContext context, int index) {
          return Padding(
            padding: EdgeInsets.all(16.0),
            child: new GestureDetector(
              onTap: () {
                _index_current_notif = index;
                setState(() {

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
                        color: listAppNotification[index].status==0?default_color_red:default_color_black,
                      ),

                      Padding(
                        padding: EdgeInsets.only(left: 16.0),
                        child: Container(
                          width: c_width,
                          child: new Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                  listAppNotification[index].title,
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                  style: TextStyle(
                                    color: listAppNotification[index].status==0?default_color_red:default_color_black,
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
                            listAppNotification[index].date_str,
                            style: TextStyle(
                              color: Colors.grey.shade400,
                              fontSize: 10,
                            )
                        ),
                      ),
                    ],
                  ),
                  Row(
                    //mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Container(
                        padding: const EdgeInsets.only(right: 16, left: 42),
                        width: c_width,
                        child: new Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                                listAppNotification[index].text,
                                overflow: TextOverflow.ellipsis,
                                maxLines: 3,
                                textAlign: TextAlign.start,
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
        padding: EdgeInsets.only(top: height_header),
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
                        _index_current_notif==-1?'':_getNameDay(listAppNotification[_index_current_notif].date_str),
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
                            _index_current_notif==-1?'':intl.DateFormat.MMMMd('ru_RU').format(intl.DateFormat('dd/MM/yyyy').parse(listAppNotification[_index_current_notif].date_str)).toUpperCase(),
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
                                _index_current_notif==-1?'':listAppNotification[_index_current_notif].title,
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
                    listAppNotification[_index_current_notif].status = 1;
                    updateStatusNotification(listAppNotification[_index_current_notif]);
                    getCountNotification();
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
        Container(
          margin: EdgeInsets.only(top: 0),
          child: _index_current_notif==-1?widgetListViewNotifications:detailNotification,
        ),
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

    Widget _widgetAddressesMoscow = ListView(
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
        Container(
          width: MediaQuery.of(context).size.width*0.9,
          child:
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(left: 8, right: 8),
                child: Align(
                  alignment: Alignment.topLeft,
                  child: Image.asset(
                    'assets/icons/ic_placeholder.png',
                    height: 24.0,
                    width: 24.0,
                  ),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    textDirection: TextDirection.ltr,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    verticalDirection: VerticalDirection.down,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(left: 0.0, bottom: 16),
                        child: Text(
                            'ул.Яблочкова, д.21, к.3',
                            style: TextStyle(
                            color: default_color_red,
                            fontSize: 14,
                            fontWeight: FontWeight.bold
                        )
                        ),
                      )
                    ],
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width*0.8,
                    child: Column(
                      children: [
                        Row(
                          textDirection: TextDirection.ltr,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          verticalDirection: VerticalDirection.down,
                          children: <Widget> [
                            Expanded(
                                child: Padding(
                                  padding: EdgeInsets.only(left: 0.0, bottom: 8),
                                  child: Text(
                                      '127322, Россия, г. Москва, ст.м. «Тимирязевская», ул.Яблочкова, д. 21, к. 3',
                                      textDirection: TextDirection.ltr,
                                      style: TextStyle(
                                        color: default_color_black,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 11,
                                      )
                                  ),
                                )
                            ),

                          ],
                        )
                      ],
                    ),
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width*0.8,
                    child: Column(
                      children: [
                        Row(
                          textDirection: TextDirection.ltr,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          verticalDirection: VerticalDirection.down,
                          children: <Widget> [
                            Expanded(
                                child: Padding(
                                  padding: EdgeInsets.only(left: 0.0, bottom: 8),
                                  child: Text(
                                      'Многоканальный \n8 800 201-27-42 (звонок по России бесплатный) \n+7(499) 995-07-42 \nМобильный: +7(916) 097-95-28 \n\n'
                                          'Часы работы: \nПн.-пт.: 9:00-19:00 (без обеда). \nСб.: 9:00-17:00; \nВс. - выходной ',
                                      style: TextStyle(
                                        color: Colors.grey.shade600,
                                        fontSize: 11,
                                      )
                                  ),
                                )
                            ),

                          ],
                        )
                      ],
                    ),
                  )

                ],
              )
            ],
          ),
        ),
        Container(
          width: MediaQuery.of(context).size.width*0.9,
          child:
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(left: 8, right: 8),
                child: Align(
                  alignment: Alignment.topLeft,
                  child: Image.asset(
                    'assets/icons/ic_placeholder.png',
                    height: 24.0,
                    width: 24.0,
                  ),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    textDirection: TextDirection.ltr,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    verticalDirection: VerticalDirection.down,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(left: 0.0, bottom: 16),
                        child: Text(
                            'Зубовский б-р, д.13, стр.1',
                            style: TextStyle(
                                color: default_color_red,
                                fontSize: 14,
                                fontWeight: FontWeight.bold
                            )
                        ),
                      )
                    ],
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width*0.8,
                    child: Column(
                      children: [
                        Row(
                          textDirection: TextDirection.ltr,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          verticalDirection: VerticalDirection.down,
                          children: <Widget> [
                            Expanded(
                                child: Padding(
                                  padding: EdgeInsets.only(left: 0.0, bottom: 8),
                                  child: Text(
                                      '119021, Россия, г. Москва, ст.м. Метро «Парк Культуры», Зубовский б-р, д.13, стр.1 (под.1, эт.6, пом.5)',
                                      textDirection: TextDirection.ltr,
                                      style: TextStyle(
                                        color: default_color_black,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 11,
                                      )
                                  ),
                                )
                            ),

                          ],
                        )
                      ],
                    ),
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width*0.8,
                    child: Column(
                      children: [
                        Row(
                          textDirection: TextDirection.ltr,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          verticalDirection: VerticalDirection.down,
                          children: <Widget> [
                            Expanded(
                                child: Padding(
                                  padding: EdgeInsets.only(left: 0.0, bottom: 8),
                                  child: Text(
                                      'Тел./ факс: +7(499) 246-54-71 \nМобильный: +7(916) 388-68-25 \n\n'
                                          'Часы работы: \nПн.-пт.: 9:00-18:00 (без обеда); \nСб., вс. - выходной',
                                      style: TextStyle(
                                        color: Colors.grey.shade600,
                                        fontSize: 11,
                                      )
                                  ),
                                )
                            ),

                          ],
                        )
                      ],
                    ),
                  )

                ],
              )
            ],
          ),
        ),

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
        Container(
          width: MediaQuery.of(context).size.width*0.9,
          child:
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(left: 8, right: 8),
                child: Align(
                  alignment: Alignment.topLeft,
                  child: Image.asset(
                    'assets/icons/ic_placeholder.png',
                    height: 24.0,
                    width: 24.0,
                  ),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    textDirection: TextDirection.ltr,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    verticalDirection: VerticalDirection.down,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(left: 0.0, bottom: 16),
                        child: Text(
                            'ул.Чудновского,  д.19, литер А, пом.5Н',
                            style: TextStyle(
                                color: default_color_red,
                                fontSize: 14,
                                fontWeight: FontWeight.bold
                            )
                        ),
                      )
                    ],
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width*0.8,
                    child: Column(
                      children: [
                        Row(
                          textDirection: TextDirection.ltr,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          verticalDirection: VerticalDirection.down,
                          children: <Widget> [
                            Expanded(
                                child: Padding(
                                  padding: EdgeInsets.only(left: 0.0, bottom: 8),
                                  child: Text(
                                      '193231, Россия, г. Санкт-Петербург, ул.Чудновского, д.19, литер А, пом.5Н',
                                      textDirection: TextDirection.ltr,
                                      style: TextStyle(
                                        color: default_color_black,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 11,
                                      )
                                  ),
                                )
                            ),

                          ],
                        )
                      ],
                    ),
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width*0.8,
                    child: Column(
                      children: [
                        Row(
                          textDirection: TextDirection.ltr,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          verticalDirection: VerticalDirection.down,
                          children: <Widget> [
                            Expanded(
                                child: Padding(
                                  padding: EdgeInsets.only(left: 0.0, bottom: 8),
                                  child: Text(
                                      '\nМногоканальный \n8 800 201-27-42 (звонок по России бесплатный) \n+7(812) 442-70-22 \nМобильный: +7(960) 267-07-30, +7(981) 171-17-18 \n\n'
                                          'Часы работы: \nПн.-пт.: 9:00-18:00 (без обеда). \nСб.: 9:30-17:00; \nВс. - выходной \n\n'
                                          'skype: 398-568-186 (Консультации по продукции) \nE-mail: spb@kassis.ru',
                                      style: TextStyle(
                                        color: Colors.grey.shade600,
                                        fontSize: 11,
                                      )
                                  ),
                                )
                            ),

                          ],
                        )
                      ],
                    ),
                  )

                ],
              )
            ],
          ),
        )


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
        Container(
          width: MediaQuery.of(context).size.width*0.9,
          child:
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(left: 8, right: 8),
                child: Align(
                  alignment: Alignment.topLeft,
                  child: Image.asset(
                    'assets/icons/ic_placeholder.png',
                    height: 24.0,
                    width: 24.0,
                  ),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    textDirection: TextDirection.ltr,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    verticalDirection: VerticalDirection.down,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(left: 0.0, bottom: 16),
                        child: Text(
                            'ул. Кечкеметская, д.120',
                            style: TextStyle(
                                color: default_color_red,
                                fontSize: 14,
                                fontWeight: FontWeight.bold
                            )
                        ),
                      )
                    ],
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width*0.8,
                    child: Column(
                      children: [
                        Row(
                          textDirection: TextDirection.ltr,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          verticalDirection: VerticalDirection.down,
                          children: <Widget> [
                            Expanded(
                                child: Padding(
                                  padding: EdgeInsets.only(left: 0.0, bottom: 8),
                                  child: Text(
                                      '295022, Россия, г. Симферополь, ул. Кечкеметская, д. 120',
                                      textDirection: TextDirection.ltr,
                                      style: TextStyle(
                                        color: default_color_black,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 11,
                                      )
                                  ),
                                )
                            ),

                          ],
                        )
                      ],
                    ),
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width*0.8,
                    child: Column(
                      children: [
                        Row(
                          textDirection: TextDirection.ltr,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          verticalDirection: VerticalDirection.down,
                          children: <Widget> [
                            Expanded(
                                child: Padding(
                                  padding: EdgeInsets.only(left: 0.0, bottom: 8),
                                  child: Text(
                                      '8 800 201-27-42 (звонок по России бесплатный) \nТел.: +7(989) 277-85-85 \n\n'
                                          'Часы работы: \nПн.-пт.: 9:00-18:00 (без обеда). \nСб., вс. - выходной',
                                      style: TextStyle(
                                        color: Colors.grey.shade600,
                                        fontSize: 11,
                                      )
                                  ),
                                )
                            ),

                          ],
                        )
                      ],
                    ),
                  )

                ],
              )
            ],
          ),
        )
      ],
    );

    Widget Contacts = Stack(
      children: [
        Container(
          margin: EdgeInsets.only(bottom: 56, top: 24),
          child: _indexContact==indexMoscow?_widgetAddressesMoscow:_indexContact==indexPitherburg?widgetAddressesPiter:widgetAddressesSimpheropol,
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
                textDirection: TextDirection.ltr,
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
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

    Widget widgetFeedback = Form(
      key: feedbackKey,
      child: Stack(
        children: [
          SingleChildScrollView(
            child: Column(children: [
              Container(
                width: double.infinity,
                height: height_header,
                color: Colors.white,
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
                          'о работе наших офисов, интернет-магазина и службы доставки',
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
                      top: 4,
                      left: 16,
                      right: 16,
                      bottom: 4
                  ),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                        width: MediaQuery.of(context).size.width*0.7,
                        child: Column(
                          children: [
                            TextFormField(
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
                              focusNode: _focusNode,
                              controller: _controller_fio,
                              onSaved: (value) {
                                //_controller_fio.text = '';
                              },
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'введите имя';
                                }
                                return null;
                              },
                            ),
                          ],
                        )
                    ),
                  )
              ),
              Padding(
                  padding: EdgeInsets.only(
                      top: 4,
                      left: 16,
                      right: 16,
                      bottom: 4
                    //bottom: MediaQuery.of(context).viewInsets.bottom
                  ),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      width: MediaQuery.of(context).size.width*0.7,
                      child: TextFormField(
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
                          onSaved: (value) {
                            //_controller_phone.text = '';
                          },
                          validator: (value) {
                            final RegExp phoneRegex = new RegExp(r'^[1-9]\d{11}$');
                            if (value == null || value.isEmpty) {
                              return 'введите номер телефона';
                            } else if (value.length < 11) {
                              return 'номер телефона некорректный';
                            }
                            return null;
                          },
                          controller: _controller_phone),
                    ),
                  )
              ),
              Padding(
                  padding: EdgeInsets.only(
                      top: 4,
                      left: 16,
                      right: 16,
                      bottom: 4
                  ),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      width: MediaQuery.of(context).size.width*0.7,
                      child: TextFormField(
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
                          onSaved: (value) {
                            //_controller_phone.text = '';
                          },
                          validator: (value) {
                            final RegExp emailRegex = new RegExp(
                                r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?)*$");
                            if (value == null || value.isEmpty) {
                              return 'введите адрес';
                            } else if (!emailRegex.hasMatch(value)) {
                              return 'адрес некорректный';
                            }
                            return null;
                          },
                          controller: _controller_email),
                    ),
                  )
              ),
              Padding(
                  padding: EdgeInsets.only(
                      top: 4,
                      left: 16,
                      right: 16,
                      bottom: 4
                  ),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      width: MediaQuery.of(context).size.width*0.9,
                      child: TextFormField(
                          decoration: InputDecoration(
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: Colors.grey.shade400,
                                    width: 0.5
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: default_color_red, width: 0.5),
                              ),
                              hintText: 'Введите ваше сообщение'
                          ),
                          style: TextStyle(
                              color: default_color_black,
                              fontSize: 12,
                              letterSpacing: 2
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'введите текст сообщения';
                            }
                            return null;
                          },
                          autofocus: false,
                          maxLength: 100,
                          keyboardType: TextInputType.text,
                          maxLines: 5,
                          controller: _controller_body),
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
                        onPressed: () {
                          if(feedbackKey.currentState.validate()) {
                            sendFeedbackMessage();
                          }

                        },
                        highlightColor: default_color_red,
                        color: default_color_red,
                        textColor: Colors.white,
                        padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                        highlightElevation: heightElevation,
                        elevation: elevationButton,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4)
                        ),
                        colorBrightness: Brightness.light,
                      ),
                    ),
                  )
              )
            ]),
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
      ),
    );


    Widget widgetActions = Column(
      children: [
        Expanded(
            flex: 19,
            child: Container(
              color: Colors.white.withOpacity(0.0),
              child: cardList.length==0
                  ?
              Align(
                alignment: Alignment.topCenter,
                child: Container(
                    height: height_header,
                    child: new OverflowBox(
                      minWidth: 0.0,
                      minHeight: 0.0,
                      child: Image.asset(
                        'assets/icons/img_actions_2.jpg',
                        fit: BoxFit.cover,
                        height: MediaQuery.of(context).size.height*0.3,
                        width: MediaQuery.of(context).size.width,
                        alignment: Alignment.center,
                      ),
                    )
                ),
              )

                :
              CarouselSlider(
                options: CarouselOptions(
                  height: MediaQuery.of(context).size.height,
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
                      print(listActions[_currentIndex].img_url);
                    });
                  },
                ),
                items: cardList.map((card){
                  return Builder(
                      builder:(BuildContext context){
                        return Column(
                          children: [
                            // Container(
                            //     height: height_header,
                            //     child: new OverflowBox(
                            //       minWidth: 0.0,
                            //       minHeight: 0.0,
                            //       child: Image.asset(
                            //         'assets/icons/img_actions_page.png',
                            //         fit: BoxFit.cover,
                            //         height: MediaQuery.of(context).size.height,
                            //         width: MediaQuery.of(context).size.width,
                            //         alignment: Alignment.center,
                            //       ),
                            //     )
                            // ),
                            Container(
                              height: MediaQuery.of(context).size.height*0.9,
                              width: MediaQuery.of(context).size.width,
                              child: Card(
                                margin: EdgeInsets.all(0),
                                elevation: 0,
                                color: Colors.white,
                                child: card,
                              ),
                            )
                          ],
                        );
                      }
                  );
                }).toList(),
              ),

            )
        ),
        Expanded(
            flex: 1,
            child: Container(
              height: MediaQuery.of(context).size.height*0.10,
              color: Colors.white,
              child: Row(
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
            )
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

    Widget doctorOnline = InAppWebView(
      initialUrl: "https://kassis.ru/vracham/",
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

    return new WillPopScope(
      onWillPop: _onBackPressed,
      child: Scaffold(
          backgroundColor: Colors.white,
          extendBodyBehindAppBar: true,
          drawerScrimColor: Colors.transparent,
          endDrawer: Theme(
            data: Theme.of(context).copyWith(
              // Set the transparency here
              canvasColor: Colors.white.withOpacity(0.9), //or any other color you want. e.g Colors.blue.withOpacity(0.5)
            ),
            child: Drawer(
              elevation: 0.0,
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
                              child: Icon(Icons.circle, color: count_notif>0?default_color_red:Colors.transparent, size: 12,)),
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
                    color: _alpha,
                    child: ListTile(
                      title: new Text(
                        "Врачам",
                        style: TextStyle(
                            color: currentItemID==itemDoctors?default_color_red:default_color_black,
                            fontSize: 18.0
                        ),
                      ),
                      onTap: (){
                        Navigator.of(context).pop();
                        _selectItemMenu(itemDoctors);
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
            backgroundColor: Colors.white.withOpacity(0.8),
            //currentItemID==0?colorAppBarDefault:colorAppBarItems,
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
          body: new InkWell(
            onTap: () {
              listBackspace.add(currentItemID);
              FocusScope.of(context).requestFocus(_focusNode);
            },
            child: Stack(
              children: [
                currentItemID==itemStart
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
                    :(currentItemID==itemDoctors
                ? doctorOnline : Text(''))
                )))))))),
                Align(
                  alignment: Alignment.topCenter,
                  child: Container(
                    height: 0,
                    color: Colors.white.withOpacity(0.6),
                  ),
                )
              ],
            ),
          ),       // This trailing comma makes auto-formatting nicer for build methods.
        ),
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

_action(BuildContext context, SpecialAction action, ) {
  return Container(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        Container(
            height: MediaQuery.of(context).size.height * 0.30,
            child: new OverflowBox(
              minWidth: 0.0,
              minHeight: 0.0,
              child: Image.file(
                new File(action.img_url),
                fit: BoxFit.cover,
                height: MediaQuery.of(context).size.height,
                width: MediaQuery.of(context).size.width,
                alignment: Alignment.center,
              ),
            )
        ),
        Padding(
          padding: EdgeInsets.only(top: 20, left: 20, right: 20),
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
          padding: EdgeInsets.only(top: 16, left: 20, right: 20),
          child: Container(
            alignment: Alignment.centerLeft,
            child: Text(
                "Срок акции: "+action.date_str,
                softWrap: true,
                style: TextStyle(
                  color: Colors.grey.shade900,
                  fontSize: 14.0,
                )
            ),
          ),
        ),
        Expanded(
            child: Padding(
              padding: EdgeInsets.only(top: 8, left: 20, right: 20),
              child: Container(
                  alignment: Alignment.centerLeft,
                  child: SingleChildScrollView(
                    child: Html(
                      data: action.text,
                    ),
                  )
                // Text(
                //     action.text +'\n',
                //     softWrap: true,
                //     style: TextStyle(
                //       color: Colors.grey.shade900,
                //       fontSize: 11.0,
                //     )
                // ),
              ),
            )
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




