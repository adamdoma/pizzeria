import 'package:flutter/material.dart';
import '../consts.dart';

class TextFieldPassword extends StatelessWidget {
  TextFieldPassword({this.hint, this.onTape});

  final String hint;
  final Function onTape;
  //TODO : add controller

  @override
  Widget build(BuildContext context) {
    return TextField(
      obscureText: true,
      textAlign: TextAlign.center,
      decoration: kTextFieldDecoration.copyWith(hintText: hint),
      onChanged: onTape,
    );
  }
}
