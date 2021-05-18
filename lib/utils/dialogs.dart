
import 'package:flushbar/flushbar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CustomDialogs {

  void showCustomFlushbar(
      BuildContext context, String title, String msg, Icon icon) {

    Flushbar(
      duration: Duration(seconds: 3),
      margin: EdgeInsets.all(8),
      padding: EdgeInsets.all(10),
      icon: icon,
      borderRadius: 8,
      backgroundGradient: LinearGradient(
        colors: [
          Colors.lightBlue.shade900,
          Colors.lightBlue.shade300
        ],
        stops: [0.6, 1],
      ),
      boxShadows: [
        BoxShadow(
          color: Colors.black45,
          offset: Offset(3, 3),
          blurRadius: 3,
        ),
      ],
      // All of the previous Flushbars could be dismissed by swiping down
      // now we want to swipe to the sides
      dismissDirection: FlushbarDismissDirection.HORIZONTAL,
      // The default curve is Curves.easeOut
      forwardAnimationCurve: Curves.fastLinearToSlowEaseIn,
      title: title,
      message: msg,
    )..show(context);
  }
}