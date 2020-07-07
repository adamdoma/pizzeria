import 'dart:ffi';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pizzeria/models/user.dart';
import '../models/meal.dart';

class UpdateFromSeller extends StatefulWidget {
  UpdateFromSeller({this.fireStore, this.user});

  final Firestore fireStore;
  final User user;

  @override
  _UpdateFromSellerState createState() => _UpdateFromSellerState();
}

class _UpdateFromSellerState extends State<UpdateFromSeller> {
  Firestore ordersCollection = Firestore.instance;
  FirebaseAuth _auth = FirebaseAuth.instance;
  FirebaseUser stateUser;
  Meal activeMeal;
  List<Meal> allOrders = new List();
  List<String> stateMsg =[
    'בהמתנה',
    'בהכנה',
    'הזמנה מוכנה'
  ];

  @override
  void initState() {
    super.initState();
    setMeal();
  }

  void setUser() async {
    stateUser = await _auth.currentUser();
  }

  void setMeal() async {
    ordersCollection = widget.fireStore;
    final orderCollection =
        await ordersCollection.collection('orders').getDocuments();

    for (var i in orderCollection.documents) {
      print(i.data['status']);
    }
  }

  void getActiveMeal(
      {bool completed,
      Map mealType,
      Timestamp orderDate,
      int quantity,
      int status,
      String userEmail}) {
    DateTime tempDate = orderDate.toDate();

    allOrders.add(new Meal(
        completed: completed,
        mealType: mealType,
        orderDate: tempDate,
        quantity: quantity,
        status: status,
        userEmail: userEmail));
    if (completed == false) {
      activeMeal = new Meal(
          completed: completed,
          mealType: mealType,
          orderDate: tempDate,
          quantity: quantity,
          status: status,
          userEmail: userEmail);
    }
  }

  @override
  Widget build(BuildContext context) {
    //TODO לתקן :אם הבסיס נתיונים יגדל משמעותית צריך לחכות יותר ואז פ ה יספיק לטעון
    setUser();
    return StreamBuilder<QuerySnapshot>(
      stream: widget.fireStore.collection('orders').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(
            child: CircularProgressIndicator(
              backgroundColor: Colors.blueAccent,
            ),
          );
        }
        final orders = snapshot.data.documents;
        for (var order in orders) {
          if (stateUser.email == order.data['user_email']) {
            getActiveMeal(
                status: order.data['status'],
                orderDate: order.data['order_date'],
                mealType: order.data['meal_type'],
                completed: order.data['completed'],
                quantity: order.data['quantity'],
                userEmail: order.data['user_email']);
            if (order.data['status'] <=2) {
              return (Container(
                child: Card(
                  elevation: 3,
                  child: ListTile(
                      isThreeLine: true,
                      title: Text('${activeMeal.orderDate.day}/${activeMeal.orderDate.month}/${activeMeal.orderDate.year}'),
                      subtitle: Text('${stateMsg[activeMeal.status]}'),
                      trailing: orderStatus(
                        status: activeMeal.status,
                      )),
                ),
              ));
            }
            else {
              return Container(
                color: Colors.white,
                child: Center(child: Text('אין הזמנות פעילות')),
              );
            }
          }
        }
        return Container(
          color: Colors.white,
          child: Center(child: Text('אין הזמנות פעילות')),
        );;
      },
    );
  }
}

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
