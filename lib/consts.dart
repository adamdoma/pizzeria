import 'package:flutter/material.dart';

const kTextFieldDecoration = InputDecoration(
  contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
  border: OutlineInputBorder(
    borderRadius: BorderRadius.all(Radius.circular(32.0)),
  ),
  enabledBorder: OutlineInputBorder(
    borderSide: BorderSide(color: Colors.lightBlueAccent, width: 1.0),
    borderRadius: BorderRadius.all(Radius.circular(32.0)),
  ),
  focusedBorder: OutlineInputBorder(
    borderSide: BorderSide(color: Colors.lightBlueAccent, width: 2.0),
    borderRadius: BorderRadius.all(Radius.circular(32.0)),
  ),
);

const kContainerDecoration = BoxDecoration(
  gradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Colors.lightBlueAccent, Colors.blue, Colors.blueGrey]),
  borderRadius: BorderRadius.only(
      topLeft: Radius.circular(20), bottomRight: Radius.circular(20)),
  boxShadow: [
    BoxShadow(
      color: Colors.white12,
      offset: Offset(2, 2),
      blurRadius: 4,
      spreadRadius: 2,
    )
  ],
);

const kAddonContainerDecoration = BoxDecoration(
  color: Colors.white,
  gradient: LinearGradient(
      colors: [Colors.white, Colors.white70],
      begin: Alignment.topRight,
      end: Alignment.bottomLeft),
  boxShadow: [
    BoxShadow(
      color: Colors.white30,
      spreadRadius: 1,
      blurRadius: 2,
      offset: Offset(6, 5), // changes position of shadow
    ),
  ],
);

const kTextStyle =
    TextStyle(fontWeight: FontWeight.w700, color: Colors.white, fontSize: 20);

const kLinearColorsContainer = LinearGradient(colors: [
  Color.fromRGBO(21, 186, 232, 0.9),
  Color.fromRGBO(21, 186, 232, 0.1)
], begin: Alignment.topLeft, end: Alignment.bottomRight);

List<Color> kDividerColors = [
  Colors.white,
  Colors.white70,
  Colors.white60,
  Colors.white54,
  Colors.white38,
  Colors.white30,
  Colors.white24,
  Colors.white12,
];
