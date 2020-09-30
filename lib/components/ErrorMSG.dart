import 'package:flutter/material.dart';

class ErrorMsg extends StatelessWidget {
  ErrorMsg({this.msg});
  String msg;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.transparent,
      title: Text(
        msg,
        style: TextStyle(color: Colors.red),
      ),
      elevation: 5,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(width: 2, color: Colors.black)),
    );
  }
}
