import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ping_me/utils/custom_text_style.dart';

class Dialogs {
  static void myShowSnackBar(
    BuildContext context,
    String title,
    Color backgroundColor,
    Color textColor,
  ) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          title,
          style: myTextStyle18(context, fontColor: textColor),
        ),
        backgroundColor: backgroundColor,
      ),
    );


  }
/// Circular progressbar
static void myShowProgressbar(BuildContext context){
    showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      return Center(
        child: CircularProgressIndicator(),
      );
    },
  );

}
}
