import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pizzeria/consts.dart';
import 'package:pizzeria/models/meal.dart';
import 'package:pizzeria/services/firebaseService.dart';
import '../components/InfoTabWidget.dart';
import '../files/order_history_file.dart';

class OrderHistory extends StatefulWidget {
  @override
  _OrderHistoryState createState() => _OrderHistoryState();
}

class _OrderHistoryState extends State<OrderHistory> {
  List<Meal> mealList = new List();
  double colorIndex = 0.0;
  double drink, pizza = 0.0;
  OrderHistoryFile orderHistory = new OrderHistoryFile();
  List<Map<String, dynamic>> orderListFromFile = [];

  void initPrices() async {
    DocumentSnapshot ds = await FireBase.getPrices();
    pizza = ds.data()['p_price'].toDouble();
    drink = ds.data()['drink_price'].toDouble();
    setState(() {});
  }

  void initOrderHistoryFromFile() async {
    orderListFromFile = await orderHistory.readOrderHistoryFile();
    setState(() {});
  }

  double get _trayCount {
    double count = 0;
    for (var i in orderListFromFile) {
      count += i['quantity'];
    }
    return count;
  }

  @override
  void initState() {
    super.initState();
    // UserOrderHistory();
    initPrices();
    initOrderHistoryFromFile();
  }

  // void UserOrderHistory() async {
  //   QuerySnapshot qs = await FireBase.getUserHistoryOrders();
  //   for (var doc in qs.docs) {
  //     setState(() {
  //       mealList.add(new Meal(
  //           userEmail: FireBase.user.email,
  //           completed: doc.data()['completed'],
  //           orderDate: doc.data()['order_date'].toDate(),
  //           quantity: doc.data()['quantity'],
  //           status: doc.data()['status']));
  //     });
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    if (orderListFromFile.isEmpty) {
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
                  itemCount: orderListFromFile.length,
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
                              'Date: ${orderListFromFile[index]['orderDate'].day}/${orderListFromFile[index]['orderDate'].month}/${orderListFromFile[index]['orderDate'].year}'),
                          subtitle: Text(
                              'Quantity: ${orderListFromFile[index]['quantity']}'),
                          trailing: Text(
                            '${orderListFromFile[index]['quantity'] * pizza}',
                          ),
                        ),
                      ),
                    );
                  },
                ))
              ],
            ),
          ),
          Positioned(
            top: -15,
            right: 10,
            height: 30,
            width: MediaQuery.of(context).size.width / 3,
            child: FittedBox(
              fit: BoxFit.contain,
              child: OrderHistoryInfoTabWidget(
                number: _trayCount,
                lbl: "כמות הזמנות",
              ),
            ),
          ),
          Positioned(
              top: -15,
              left: 10,
              height: 30,
              width: MediaQuery.of(context).size.width / 3,
              child: FittedBox(
                fit: BoxFit.contain,
                child: OrderHistoryInfoTabWidget(
                  number: _trayCount * pizza.toDouble(),
                  lbl: '\u20AA',
                ),
              )),
        ],
      );
  }
}
