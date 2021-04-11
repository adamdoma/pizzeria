import 'dart:ffi';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pizzeria/services/firebaseService.dart';
import '../models/meal.dart';
import '../components/order_status_widget.dart';

class UpdateFromSeller extends StatefulWidget {
  @override
  _UpdateFromSellerState createState() => _UpdateFromSellerState();
}

class _UpdateFromSellerState extends State<UpdateFromSeller> {
  FirebaseFirestore ordersCollection = FirebaseFirestore.instance;
  FirebaseAuth _auth = FirebaseAuth.instance;
  User stateUser;
  bool userLoaded = false;
  Meal activeMeal;
  List<Meal> allOrders = new List();
  List<String> stateMsg = ['בהמתנה', 'בהכנה', 'הזמנה מוכנה'];

  @override
  void initState() {
    super.initState();
    setMeal();
  }

  void setUser() async {
    stateUser = _auth.currentUser;
    setState(() {
      userLoaded = true;
    });
  }

  void setMeal() async {
    ordersCollection = FirebaseFirestore.instance;
    final orderCollection = await ordersCollection.collection('orders').get();
  }

  void getActiveMeal(
      {bool completed,
      Map mealType,
      Timestamp orderDate,
      double quantity,
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
    if (userLoaded == false) {
      return Center(child: CircularProgressIndicator());
    }
    if (FireBase.user == null) {
      return Text('user offline');
    }
    return StreamBuilder<QuerySnapshot>(
      stream: FireBase.getActiveOrders(FireBase.user.email),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator());
        }
        var orders = snapshot.data;
        for (var order in orders.docs) {
          if (stateUser.email == order['user_email']) {
            getActiveMeal(
                status: order.data()['status'],
                orderDate: order.data()['order_date'],
//                mealType: order.data['meal_type'].toList(),
                completed: order.data()['completed'],
                quantity: order.data()['quantity'],
                userEmail: order.data()['user_email']);
            if (order.data()['status'] <= 2) {
              return (Container(
                height: 20,
                width: MediaQuery.of(context).size.width * 0.9,
                child: ListTile(
                    isThreeLine: true,
                    title: Text(
                        '${activeMeal.orderDate.day}/${activeMeal.orderDate.month}/${activeMeal.orderDate.year}'),
                    subtitle: Text('${stateMsg[activeMeal.status]}'),
                    trailing: orderStatus(
                      status: activeMeal.status,
                    )),
              ));
            } else {
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
        );
      },
    );
  }
}
