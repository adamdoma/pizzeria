import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pizzeria/consts.dart';
import 'package:pizzeria/models/meal.dart';
import 'package:pizzeria/services/firebaseService.dart';
import '../components/InfoTabWidget.dart';

class OrderHistory extends StatefulWidget {
  @override
  _OrderHistoryState createState() => _OrderHistoryState();
}

class _OrderHistoryState extends State<OrderHistory> {
  List<Meal> mealList = new List();
  double colorIndex = 0.0;
  double drink, pizza;

  void initPirces() async {
    DocumentSnapshot ds = await FireBase.getPrices();
    pizza = ds.data()['p_price'].toDouble();
    drink = ds.data()['drink_price'].toDouble();
  }

  @override
  void initState() {
    super.initState();
    UserOrderHistory();
    initPirces();
  }

  void UserOrderHistory() async {
    QuerySnapshot qs = await FireBase.getUserHistoryOrders();
    for (var doc in qs.docs) {
      setState(() {
        mealList.add(new Meal(
            userEmail: FireBase.user.email,
            completed: doc.data()['completed'],
            orderDate: doc.data()['order_date'].toDate(),
            quantity: doc.data()['quantity'],
            status: doc.data()['status']));
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
      return Stack(
        overflow: Overflow.visible,
        children: <Widget>[
          Container(
            padding: EdgeInsets.only(top: 20, left: 10, right: 10),
            decoration: BoxDecoration(
              gradient: kLinearColorsContainer,
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
                      return Container(
                        margin: EdgeInsets.only(top: 10),
                        child: Card(
                            color: Colors.white70,
                            elevation: 5,
                            child: ListTile(
                              leading: Icon(
                                Icons.check_box,
                                color: Colors.white,
                              ),
                              title: Text(
                                  'Date: ${mealList[index].orderDate.day}/${mealList[index].orderDate.month}/${mealList[index].orderDate.year}'),
                              subtitle:
                                  Text('Quantity: ${mealList[index].quantity}'),
                              trailing:
                                  Text('${mealList[index].quantity * pizza}'),
                            )),
                      );
                    },
                  ),
                )
              ],
            ),
          ),
          Positioned(
            top: -15,
            right: 10,
            height: 30,
            width: MediaQuery.of(context).size.width / 3,
            child: OrderHistoryInfoTabWidget(
              number: mealList.length.toDouble(),
              lbl: "כמות הזמנות",
            ),
          ),
          Positioned(
              top: -15,
              left: 10,
              height: 30,
              width: MediaQuery.of(context).size.width / 3,
              child: OrderHistoryInfoTabWidget(
                number: mealList.length.toDouble() * pizza.toDouble(),
                lbl: '\u20AA',
              )),
        ],
      );
  }
}
