import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pizzeria/consts.dart';
import 'package:pizzeria/models/user.dart';
import 'package:pizzeria/services/firebaseService.dart';
import '../components/ErrorMSG.dart';
import '../components/rounded_Button.dart';
import '../models/meal.dart';
import 'dart:math' as math;

class NewOrder extends StatefulWidget {
  @override
  _NewOrderState createState() => _NewOrderState();
}

class _NewOrderState extends State<NewOrder> {
  Users stateUser = FireBase.user;

  Map<String, dynamic> addOns;
  List<String> addOnsKeyNames;
  List<Meal> orderCart = [];
  List<Image> mealImages = [];
  List<Map> listOfMapsToFirebase = [];

  bool selected = false, leftSide = false, rightSide = false;
  int mealSelector = 0;
  double pizzaCountInOrder = 0;

  @override
  void initState() {
    super.initState();
    getAddons();
  }

  void getAddons() async {
    var t = await FireBase.getAddons();
    for (var i in t.docs) {
      setState(() {
        addOns = i.data();
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
      value = 0;
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
          gradient: LinearGradient(
              colors: [Colors.blueAccent, Colors.white12],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight),
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
                    if (pizzaCountInOrder > 0) {
                      setState(() {
                        mealsUpdate(false);
                        pizzaCountInOrder -= 0.5;
                        if (pizzaCountInOrder == 0) {
                          orderCart.clear();
                        }
                      });
                    }
                  },
                ),
                Text(
                  '$pizzaCountInOrder',
                  style: kTextStyle,
                ),
                FlatButton(
                  child: Icon(
                    Icons.add_circle,
                    color: Colors.white70,
                    size: 40,
                  ),
                  onPressed: () {
                    if (pizzaCountInOrder < 6) {
                      setState(() {
                        mealsUpdate(true);
                        pizzaCountInOrder += 0.5;
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
                          color: Colors.white12,
                          borderRadius: BorderRadius.only(
                              bottomRight: Radius.circular(40),
                              bottomLeft: Radius.circular(20),
                              topRight: Radius.circular(40),
                              topLeft: Radius.circular(20)),
                        ),
                        child: Column(
                          children: List.generate(
                              mealSelector < orderCart.length
                                  ? orderCart[mealSelector]
                                      .mealType
                                      .keys
                                      .toList()
                                      .length
                                  : mealSelector = 0, (index) {
                            return AddOns(
                              label: addOnsKeyNames[index],
                              toSelect: orderCart[mealSelector]
                                  .mealType[addOnsKeyNames[index]],
                              func: (int x) {
                                setState(() {
                                  if (orderCart[mealSelector]
                                          .mealType[addOnsKeyNames[index]] ==
                                      x) {
                                    x = 0;
                                  }
                                  orderCart[mealSelector]
                                      .mealType[addOnsKeyNames[index]] = x;
//                                      !orderCart[mealSelector]
//                                          .mealType[addOnsKeyNames[index]];
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
                stream: FireBase.onlineServices(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                  var onlineServes = snapshot.data;

                  if (onlineServes.docs.first.data()['onlineServes'] == true) {
                    return Padding(
                      padding: EdgeInsets.symmetric(vertical: 5),
                      child: RoundedButton(
                        text: 'הזמן',
                        onTape: () {
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
                                    for (int i = 0; i < orderCart.length; i++) {
                                      listOfMapsToFirebase
                                          .add(orderCart[i].mealType);
                                    }
                                    try {
                                      FireBase.addNewOrder(pizzaCountInOrder,
                                          listOfMapsToFirebase);
                                    } catch (e) {
                                      ErrorMsg(
                                        msg: e.toString(),
                                      );
                                    }
                                    setState(() {
                                      getAddons();
                                    });
                                    Navigator.pop(context);
                                    listOfMapsToFirebase.clear();
                                    orderCart.clear();
                                    mealImages.clear();
                                    mealSelector = 0;
                                    pizzaCountInOrder = 0;
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
                      ),
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

//TODO: new file widget for addons

// ignore: must_be_immutable
class AddOns extends StatelessWidget {
  AddOns({this.label, this.func, this.toSelect});

  final String label;
  final int toSelect;
  final Function func;
//  final Function toggleCheckBoxState;
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10),
      decoration: kAddonContainerDecoration.copyWith(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(10),
              topRight: Radius.circular(20),
              bottomLeft: Radius.circular(20),
              bottomRight: Radius.circular(10)),
          gradient: LinearGradient(
              colors: [Colors.blueGrey, Colors.white],
              begin: Alignment.topRight,
              end: Alignment.bottomLeft)),
      child: Container(
        child: Row(
          textDirection: TextDirection.rtl,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Expanded(
              flex: 2,
              child: Center(
                child: Text(
                  label,
                  style: kTextStyle.copyWith(color: Colors.black),
                ),
              ),
            ),
            Expanded(
              flex: 5,
              child: Row(
                textDirection: TextDirection.rtl,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  GestureDetector(
                    child: AnimatedSwitcher(
                      duration: Duration(milliseconds: 400),
                      transitionBuilder:
                          (Widget child, Animation<double> animation) {
                        return ScaleTransition(
                          scale: animation,
                          child: child,
                        );
                      },
                      child: toSelect == 2
                          ? ClipRRect(
                              key: ValueKey(1),
                              borderRadius: BorderRadius.circular(50),
                              child: Transform.rotate(
                                angle: 180 * math.pi / 180,
                                child: Image.asset(
                                  'img/onPizza.jpg',
//                                : 'img/offPizza.png',
                                  height: 50,
                                  width: 50,
                                ),
                              ),
                            )
                          : ClipRRect(
                              key: ValueKey(2),
                              borderRadius: BorderRadius.circular(50),
                              child: Transform.rotate(
                                angle: 180 * math.pi / 180,
                                child: Image.asset(
//                      'img/onPizza.jpg',
                                  'img/offPizza.png',
                                  height: 50,
                                  width: 50,
                                ),
                              ),
                            ),
                    ),
                    onTap: () => func(2),
                  ),
                  GestureDetector(
                    child: AnimatedSwitcher(
                      duration: Duration(milliseconds: 400),
                      transitionBuilder:
                          (Widget child, Animation<double> animation) {
                        return RotationTransition(
                          turns: animation,
                          child: child,
                        );
                      },
                      child: toSelect == 1
                          ? ClipRRect(
                              key: ValueKey(3),
                              borderRadius: BorderRadius.circular(50),
                              child: Image.asset(
                                'img/onFull.jpg',
                                height: 50,
                                width: 50,
                              ),
                            )
                          : ClipRRect(
                              key: ValueKey(4),
                              borderRadius: BorderRadius.circular(50),
                              child: Image.asset(
                                'img/offFull.png',
                                height: 50,
                                width: 50,
                              ),
                            ),
                    ),
                    onTap: () => func(1),
                  ),
                  GestureDetector(
                    child: AnimatedSwitcher(
                      duration: Duration(milliseconds: 400),
                      transitionBuilder:
                          (Widget child, Animation<double> animation) {
                        return ScaleTransition(
                          scale: animation,
                          child: child,
                        );
                      },
                      child: toSelect == 3
                          ? ClipRRect(
                              key: ValueKey(5),
                              borderRadius: BorderRadius.circular(50),
                              child: Image.asset(
                                'img/onPizza.jpg',
                                height: 50,
                                width: 50,
                              ),
                            )
                          : ClipRRect(
                              key: ValueKey(6),
                              borderRadius: BorderRadius.circular(50),
                              child: Image.asset(
                                'img/offPizza.png',
                                height: 50,
                                width: 50,
                              ),
                            ),
                    ),
                    onTap: () => func(3),
                  ),
                ],
              ),
            ),
          ],
        ),
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
