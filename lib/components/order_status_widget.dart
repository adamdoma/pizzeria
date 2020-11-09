import 'package:flutter/material.dart';

class orderStatus extends StatelessWidget {
  orderStatus({this.status});
  int status;

  List<Color> statColor = [
    Colors.red,
    Colors.yellow,
    Colors.green,
  ];

  @override
  Widget build(BuildContext context) {
    return Icon(
      Icons.brightness_1,
      color: statColor[status],
      size: 40,
    );
  }
}