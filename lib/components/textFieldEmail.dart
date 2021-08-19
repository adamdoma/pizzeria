import 'package:flutter/material.dart';
import '../consts.dart';

class TextFieldEmail extends StatelessWidget {
  TextFieldEmail({this.hint, this.onTape});

  final String hint;
  final Function onTape;

  @override
  Widget build(BuildContext context) {
    return TextField(
      textAlign: TextAlign.center,
      keyboardType: TextInputType.emailAddress,
      decoration:
          kTextFieldDecoration.copyWith(hintText: hint, labelText: hint),
      onChanged: onTape,
    );
  }
}
