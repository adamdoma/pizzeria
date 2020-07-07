import 'dart:math' as math;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class NewOrder extends StatefulWidget {
  @override
  _NewOrderState createState() => _NewOrderState();
}

class _NewOrderState extends State<NewOrder> {

  final _fireStore = Firestore.instance;
  List<MyPainter> pizza = [MyPainter(direction: 1),MyPainter(direction: -1)];
  int index =0;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    test();
  }

  void test()async{
    var t = await _fireStore.collection('menu/ixrmSDe3HG4F1dvJx6hr/add_on').getDocuments();
    for(var i in t.documents){
      print(i.data['onion']);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.blueAccent,
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(30),
          topLeft: Radius.circular(30),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Text('הזמנה חדשה',style: TextStyle(
            fontSize: 20,
            color: Colors.white,
            letterSpacing: 3,
          ),
          ),
          Expanded(
            flex: 1,
            child: Container(
              color: Colors.green,
              child: FittedBox(
                fit: BoxFit.fill,
                child: CustomPaint(
                  size: Size(200,200),
                  painter: pizza[index],
                ),
              ),
            ),
          ),
//          Expanded(
//            flex: 2,
//            child: Container(
//              color: Colors.black,
//            ),
//          ),
        ],
      ),
    );
  }
}

class MyPainter extends CustomPainter{
  int direction;
  MyPainter({this.direction});
  @override
  void paint(Canvas canvas, Size size) {
    var centerX = size.width/2;
    var centerY = size.height/2;
    var center = Offset(centerX,centerY);
    var radius = math.min(centerX,size.height);
    var brush = Paint()
    ..color=Colors.deepOrange;

    var line = Paint()
    ..color = Colors.white
    ..strokeWidth = 1;

    canvas.drawArc(Rect.fromCenter(center: center,height: centerY+20,width: centerX),4.7*direction,math.pi,false,line);
//    canvas.drawCircle(center, radius, brush);
    print(radius);
//    canvas.drawLine(center, Offset(centerX,0), line);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
    throw UnimplementedError();
  }


}