import 'package:flutter/material.dart';

class RoundedButton extends StatelessWidget {
  RoundedButton({this.text, @required this.onTape});

  final String text;
  final Function onTape;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.blueAccent,
      elevation: 5,
      borderRadius: BorderRadius.circular(30),
      child: MaterialButton(
        height: 40,
        minWidth: 200,
        onPressed: onTape,
        child: Text(
          text,
          style: TextStyle(
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
