import 'package:flutter/material.dart';
import 'dart:math' as math;

class OrderHistoryInfoTabWidget extends StatefulWidget {
  OrderHistoryInfoTabWidget({this.number, this.lbl});

  final double number;
  final String lbl;

  @override
  _OrderHistoryInfoTabWidgetState createState() =>
      _OrderHistoryInfoTabWidgetState();
}

class _OrderHistoryInfoTabWidgetState extends State<OrderHistoryInfoTabWidget>
    with SingleTickerProviderStateMixin {
  AnimationController controller;
  Animation animation;
  @override
  void initState() {
    super.initState();
    controller =
        AnimationController(vsync: this, duration: Duration(seconds: 2));
    animation = CurvedAnimation(parent: controller, curve: Curves.bounceIn);
    controller.repeat(min: 0, max: 1, reverse: true);

    controller.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 5),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.black, width: animation.value * 3),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
              color: Colors.grey.withOpacity(0.7),
              offset: Offset(0, 3),
              blurRadius: 7,
              spreadRadius: 5),
        ],
      ),
      child: Row(
        textDirection: TextDirection.rtl,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text('${widget.lbl}:${widget.number}'),
        ],
      ),
    );
  }
}
