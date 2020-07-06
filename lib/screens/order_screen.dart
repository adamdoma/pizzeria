import 'package:flutter/material.dart';

class NewOrder extends StatelessWidget {
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
          Slider(
            value: 5,
            onChanged: (val){
              val +=1;
            },
            min: 0.5,
            max: 5,
            divisions: 5,
          ),
        ],
      ),
    );
  }
}
