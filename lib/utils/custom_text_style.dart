import 'package:flutter/material.dart';

/// Helper function to get the correct text color
Color getTextColor(BuildContext context, Color? fontColor) {
  return fontColor ?? Theme.of(context).textTheme.bodyLarge!.color!;
}

/// font Size 12
TextStyle myTextStyle12(BuildContext context,
    {String fontFamily = "primary",
      Color? fontColor,
      FontWeight fontWeight = FontWeight.normal}) {
  return TextStyle(
    color: getTextColor(context, fontColor),
    fontSize: 12,
    fontFamily: fontFamily,
    fontWeight: fontWeight,
  );
}

/// font Size 15
TextStyle myTextStyle15(BuildContext context,
    {String fontFamily = "primary",
      Color? fontColor,
      FontWeight fontWeight = FontWeight.normal}) {
  return TextStyle(
    color: getTextColor(context, fontColor),
    fontSize: 15,
    fontFamily: fontFamily,
    fontWeight: fontWeight,
  );
}

/// font Size 18
TextStyle myTextStyle18(BuildContext context,
    {String fontFamily = "primary",
      Color? fontColor,
      FontWeight fontWeight = FontWeight.normal}) {
  return TextStyle(
    color: getTextColor(context, fontColor),
    fontSize: 18,
    fontFamily: fontFamily,
    fontWeight: fontWeight,
  );
}

/// font Size 24
TextStyle myTextStyle24(BuildContext context,
    {String fontFamily = "primary",
      Color? fontColor,
      FontWeight fontWeight = FontWeight.normal}) {
  return TextStyle(
    color: getTextColor(context, fontColor),
    fontSize: 24,
    fontFamily: fontFamily,
    fontWeight: fontWeight,
  );
}

/// font Size 36
TextStyle myTextStyle36(BuildContext context,
    {String fontFamily = "primary",
      Color? fontColor,
      FontWeight fontWeight = FontWeight.normal}) {
  return TextStyle(
    color: getTextColor(context, fontColor),
    fontSize: 36,
    fontFamily: fontFamily,
    fontWeight: fontWeight,
  );
}

/// font Size 48
TextStyle myTextStyle48(BuildContext context,
    {String fontFamily = "primary",
      Color? fontColor,
      FontWeight fontWeight = FontWeight.normal}) {
  return TextStyle(
    color: getTextColor(context, fontColor),
    fontSize: 48,
    fontFamily: fontFamily,
    fontWeight: fontWeight,
  );
}
