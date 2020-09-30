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
  boxShadow: [
    BoxShadow(
      color: Colors.black12,
      spreadRadius: 3,
      blurRadius: 9,
      offset: Offset(10, 10), // changes position of shadow
    ),
  ],
);

const kTextStyle =
    TextStyle(fontWeight: FontWeight.w700, color: Colors.white, fontSize: 20);
