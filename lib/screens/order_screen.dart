import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pizzeria/consts.dart';
import 'package:pizzeria/main.dart';
import 'package:pizzeria/models/user.dart';
import 'package:pizzeria/services/firebaseService.dart';
import '../components/ErrorMSG.dart';
import '../models/meal.dart';
import '../components/rounded_Button.dart';

class NewOrder extends StatefulWidget {
  @override
  _NewOrderState createState() => _NewOrderState();
}

class _NewOrderState extends State<NewOrder> {
  final _fireStore = Firestore.instance;
  User stateUser = FireBase.user;
  double count = 0;
  Map<String, dynamic> addOns;
  List<String> addOnsKeyNames;
  bool selected = false, leftSide = false, rightSide = false;
  List<Meal> orderCart = [];
  List<Image> mealImages = [];
  int mealSelector = 0;

  @override
  void initState() {
    super.initState();
    getAddons();
  }

  void getAddons() async {
    var t = await FireBase.getAddons();
    for (var i in t.documents) {
      setState(() {
        addOns = i.data;
      });
      addOnsKeyNames = addOns.keys.toList();
    }
  }

  void mealsUpdate(bool val) {
    if (val) {
      if (orderCart.isEmpty) {
        orderCart.add(new Meal(
            userEmail: FireBase.user.email,
            quantity: 0.5,
            mealType: new Map.from(addOns),
            completed: false,
            orderDate: DateTime.now(),
            status: 0));
        mealImages.add(Image.asset('img/onPizza.jpg'));
      } else {
        if (orderCart.last.quantity % 1 != 0) {
          orderCart.last.quantity += 0.5;
          mealImages.removeLast();
          mealImages.add(Image.asset('img/onFull.jpg'));
        } else {
          orderCart.add(new Meal(
              userEmail: FireBase.user.email,
              quantity: 0.5,
              mealType: new Map.from(addOns),
              completed: false,
              orderDate: DateTime.now(),
              status: 0));
          mealImages.add(Image.asset('img/onPizza.jpg'));
        }
      }
    } else if (!val) {
      if (orderCart.last.quantity % 1 == 0) {
        orderCart.last.quantity -= 0.5;
        mealImages.removeLast();
        mealImages.add(Image.asset('img/onPizza.jpg'));
      } else {
        orderCart.removeLast();
        mealImages.removeLast();
      }
    }
  }

  void clearMap() {
    addOns.forEach((key, value) {
      value = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (addOnsKeyNames == null && stateUser == null) {
      return Center(
        child: CircularProgressIndicator(),
      );
    }
    return SingleChildScrollView(
      child: Container(
        height: MediaQuery.of(context).size.height * 0.65,
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Color(0xff45b0ff),
          borderRadius: BorderRadius.only(
            topRight: Radius.circular(30),
            topLeft: Radius.circular(30),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text(
              'הזמנה חדשה',
              style: TextStyle(
                fontSize: 20,
                color: Colors.white,
                letterSpacing: 3,
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Row(
              textDirection: TextDirection.rtl,
              children: [
                Text(
                  'כמות (מגש)',
                  style: kTextStyle,
                ),
                FlatButton(
                  textColor: Colors.white70,
                  child: Icon(
                    Icons.remove_circle,
                    size: 40,
                  ),
                  onPressed: () {
                    if (count > 0) {
                      setState(() {
                        mealsUpdate(false);
                        count -= 0.5;
                        if (count == 0) {
                          orderCart.clear();
                        }
                      });
                    }
                  },
                ),
                Text(
                  '$count',
                  style: kTextStyle,
                ),
                FlatButton(
                  child: Icon(
                    Icons.add_circle,
                    color: Colors.white70,
                    size: 40,
                  ),
                  onPressed: () {
                    if (count < 6) {
                      setState(() {
                        mealsUpdate(true);
                        count += 0.5;
                      });
                    }
                  },
                ),
              ],
            ),
            SizedBox(
              height: 10,
            ),
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                textDirection: TextDirection.rtl,
                children: List.generate(mealImages.length, (index) {
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        mealSelector = index;
                      });
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 5),
                      decoration: mealSelector == index
                          ? BoxDecoration(
                              color: Colors.transparent,
                              borderRadius: BorderRadius.circular(50),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.white70.withOpacity(0.7),
                                  spreadRadius: 6,
                                  blurRadius: 10,
                                  offset: Offset(
                                      0, 0), // changes position of shadow
                                ),
                              ],
                            )
                          : BoxDecoration(
                              color: Colors.transparent,
                            ),
                      child: ClipRRect(
                        child: mealImages[index],
                        borderRadius: BorderRadius.circular(50),
                      ),
                    ),
                  );
                }),
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Divider(
              color: Colors.grey,
              thickness: 2,
              indent: MediaQuery.of(context).size.width * 0.1,
              endIndent: MediaQuery.of(context).size.width * 0.1,
            ),
            Text(
              orderCart.length == 0 ? '' : '${mealSelector + 1} תוספות למגש',
              style: kTextStyle,
            ),
            /*מיכל המכיל את שמות התוספות*/
            Expanded(
              flex: 6,
              child: orderCart.isEmpty
                  ? Center(
                      child: Text('בחר כמות מגש'),
                    )
                  : SingleChildScrollView(
                      child: Container(
                        margin: EdgeInsets.only(top: 10, bottom: 10),
                        decoration: BoxDecoration(
                          color: Colors.white24,
                          borderRadius: BorderRadius.only(
                              bottomRight: Radius.circular(40),
                              bottomLeft: Radius.circular(20),
                              topRight: Radius.circular(40),
                              topLeft: Radius.circular(20)),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.5),
                              spreadRadius: 5,
                              blurRadius: 7,
                              offset:
                                  Offset(0, 3), // changes position of shadow
                            ),
                          ],
                        ),
                        child: Column(
                          children: List.generate(
                              orderCart[mealSelector]
                                  .mealType
                                  .keys
                                  .toList()
                                  .length, (index) {
                            return AddOns(
                              label: addOnsKeyNames[index],
                              toSelect: orderCart[mealSelector]
                                  .mealType[addOnsKeyNames[index]],
                              func: () {
                                setState(() {
                                  orderCart[mealSelector]
                                          .mealType[addOnsKeyNames[index]] =
                                      !orderCart[mealSelector]
                                          .mealType[addOnsKeyNames[index]];
                                });
                              },
                            );
                          }),
                        ),
                      ),
                    ),
            ),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FireBase.onlineServess(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                  var onlineServes = snapshot.data.documents;

                  if (onlineServes.first.data['onlineServes'] == true) {
                    return FloatingActionButton(
                      elevation: 6,
                      backgroundColor: Colors.white,
                      child: Text(
                        'הזמן',
                        style:
                            kTextStyle.copyWith(color: Colors.lightBlueAccent),
                      ),
                      onPressed: () {
                        showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (_) => AlertDialog(
                            title: Text(
                              'אישור הזמנה',
                              textAlign: TextAlign.end,
                            ),
                            elevation: 3,
                            actions: [
                              FlatButton(
                                child: Text(
                                  'כן',
                                  textAlign: TextAlign.start,
                                ),
                                onPressed: () {
                                  try {
                                    _fireStore.collection('active_orders').add({
                                      'completed': false,
                                      'meal_type': addOns,
                                      'order_date': Timestamp.now(),
                                      'quantity': count,
                                      'status': 0,
                                      'user_email': stateUser.email
                                    });
                                  } catch (e) {
                                    ErrorMsg(
                                      msg: e.toString(),
                                    );
                                  }
                                  setState(() {
                                    getAddons();
                                  });
                                  Navigator.pop(context);
                                },
                              ),
                              FlatButton(
                                child: Text(
                                  'לא',
                                  textAlign: TextAlign.start,
                                ),
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  }
                  return Text(
                    'חנות סגורה',
                    style: kTextStyle,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ignore: must_be_immutable
class AddOns extends StatelessWidget {
  AddOns({this.label, this.func, this.toSelect});

  final String label;
  final bool toSelect;
  final Function func;
//  final Function toggleCheckBoxState;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 10),
      decoration: kAddonContainerDecoration.copyWith(),
      child: Row(
        textDirection: TextDirection.rtl,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Expanded(
            child: Text(
              label,
              style: kTextStyle.copyWith(color: Colors.black45),
            ),
          ),
          Expanded(
            child: Row(
              textDirection: TextDirection.rtl,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                GestureDetector(
                  child: toSelect ? Icon(Icons.lens) : Icon(Icons.trip_origin),
                  onTap: func,
                ),
                GestureDetector(
                  child: toSelect ? Icon(Icons.lens) : Icon(Icons.trip_origin),
                  onTap: func,
                ),
                GestureDetector(
                  child: toSelect ? Icon(Icons.lens) : Icon(Icons.trip_origin),
                  onTap: func,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

//            Icon(
//                Icons.trip_origin,
//                size: MediaQuery.of(context).size.width * 0.4,
//                color: Colors.green.withAlpha(90),
//              )

//            Icon(
//                Icons.trip_origin,
//                size: MediaQuery.of(context).size.width * 0.3,
//                color: Colors.red.withAlpha(70),
//              ),

//GridView.count(
//crossAxisSpacing: 10,
//mainAxisSpacing: 10,
//crossAxisCount: 2,
//children: List.generate(addOnsKeyNames.length, (index) {
//return Container(
//decoration: kAddonContainerDecoration.copyWith(
//borderRadius: BorderRadius.circular(40),
//),
//child: GestureDetector(
//child: AddOns(
//label: addOnsKeyNames[index],
//isChecked: addOns[addOnsKeyNames[index]],
//leftChecked: leftSide,
//rightChecked: rightSide,
//),
//onTap: () {
//setState(() {
//addOns[addOnsKeyNames[index]] =
//!addOns[addOnsKeyNames[index]];
//});
//},
//),
//);
//}),
//),
