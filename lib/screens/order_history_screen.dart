import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pizzeria/models/meal.dart';
import 'package:pizzeria/services/firebaseService.dart';

class OrederHistory extends StatefulWidget {
  @override
  _OrederHistoryState createState() => _OrederHistoryState();
}

class _OrederHistoryState extends State<OrederHistory> {
//  final _auth = FirebaseAuth.instance;
//  final _fireStore = Firestore.instance;
//  FirebaseUser fbu;
  List<Meal> mealList = new List();

  @override
  void initState() {
    super.initState();
    UserOrderHistory();
  }

  void UserOrderHistory() async {
    QuerySnapshot doc = await FireBase.getUserHistoryOrders();
    for (var i in doc.documents) {
      setState(() {
        mealList.add(new Meal(
            userEmail: FireBase.user.email,
            completed: i.data['completed'],
            mealType: i.data['meal_type'],
            orderDate: i.data['order_date'].toDate(),
            quantity: i.data['quantity'],
            status: i.data['status']));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (mealList.isEmpty) {
      return Center(
        child: Text('אין היסטוריה'),
      );
    } else
      return Container(
        padding: EdgeInsets.only(top: 20, left: 10, right: 10),
        decoration: BoxDecoration(
          color: Colors.blueAccent,
          borderRadius: BorderRadius.only(
            topRight: Radius.circular(30),
            topLeft: Radius.circular(30),
          ),
        ),
        child: Column(
          children: <Widget>[
            Expanded(
              child: ListView.builder(
                itemCount: mealList.length,
                itemBuilder: (context, index) {
                  return Card(
                      color: Colors.white70,
                      elevation: 5,
                      child: ListTile(
                        leading: Icon(Icons.account_circle),
                        title: Text(
                            'Date: ${mealList[index].orderDate.day}/${mealList[index].orderDate.month}/${mealList[index].orderDate.year}'),
                        subtitle: Text('Quantity: ${mealList[index].quantity}'),
                        trailing: Text('20\u20AA'),
                      ));
                },
              ),
            )
          ],
        ),
      );
  }
}
