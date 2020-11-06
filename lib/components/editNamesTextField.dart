import 'package:flutter/material.dart';
import 'package:pizzeria/consts.dart';

class EditNameContainerWithTextField extends StatelessWidget {
  const EditNameContainerWithTextField({
    Key key,
    @required this.animation2,
    @required this.animation,
    @required this.func,
    @required this.controller,
  }) : super(key: key);

  final Animation animation2;
  final Animation animation;
  final Function func;
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.4,
      child: TextField(
        controller: controller,
        style: kTextStyle,
        textAlign: TextAlign.center,
        decoration: kTextFieldDecoration.copyWith(
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(40),
            borderSide: BorderSide(color: Colors.white),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.only(
                topRight: Radius.circular(animation2.value * 20),
                topLeft: Radius.circular(animation.value * 30),
                bottomRight: Radius.circular(animation.value * 30),
                bottomLeft: Radius.circular(animation2.value * 20)),
            borderSide: BorderSide(
              color: Colors.white,
              width: 3,
            ),
          ),
        ),
        onChanged: func,
      ),
    );
  }
}
