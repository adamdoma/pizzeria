import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/animation.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pizzeria/components/flip_card_widget.dart';
import 'package:pizzeria/consts.dart';
import 'package:pizzeria/models/meal.dart';
import 'package:pizzeria/services/firebaseService.dart';
import 'package:pizzeria/services/paypalPayment.dart';

class NewOrder extends StatefulWidget {
  Function updateCart;
  NewOrder({@required this.updateCart});
  @override
  _NewOrderState createState() => _NewOrderState(updateCart: updateCart);
}

class _NewOrderState extends State<NewOrder> {
  Function updateCart;
  _NewOrderState({this.updateCart});
  PageController pageController;
  double viewportFraction = 0.8;
  double pageOffset = 0;
  double count = 0.0;
  final double pizzaPrice = 40.0;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    pageController =
        PageController(initialPage: 0, viewportFraction: viewportFraction)
          ..addListener(() {
            setState(() {
              pageOffset = pageController.page;
            });
          });
    print(Meal.mealList);
  }

  @override
  void dispose() {
    Meal.meals = [];
    super.dispose();
  }

  double getMealCount() {
    double ans = 0;
    for (var index in Meal.meals) {
      ans += index.quantity;
    }
    return ans;
  }

  SnackBar snackBarMessage(String msg, Icon icon) {
    return SnackBar(
      content: (Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          icon,
          SizedBox(
            width: 10,
          ),
          Text(
            '$msg',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
        ],
      )),
    );
  }

  void orderToFirebase() async {
    List<Map> order = [];
    List<Map> halfQuantitiy = [];
    double count = 0;
    int side = 2; //2 - right side , 3 - left Side of the tray
    List<String> keyNames = Meal.meals[0].mealType.keys.toList();
    for (var meal in Meal.meals) {
      if (meal.quantity % 1 != 0) {
        if (side == 2) {
          for (var i in keyNames) {
            if (meal.mealType[i] != 0) {
              meal.mealType[i] = side;
            }
          }
          side = 3;
        } else if (side == 3) {
          for (var i in keyNames) {
            if (meal.mealType[i] != 0) {
              meal.mealType[i] = side;
            }
          }
          side = 2;
        }
        halfQuantitiy.add(meal.mealType);
      } else {
        for (var i in keyNames) {
          if (meal.mealType[i] != 0) {
            meal.mealType[i] = 1;
          }
        }
        order.add(meal.mealType);
      }
      count += meal.quantity;
    }
    // קיבוץ חצאי הזמנות
    //if length is 1
    if (halfQuantitiy.length == 1) {
      order.add(halfQuantitiy.first);
    }
    if (halfQuantitiy.length > 1) {
      Map<String, dynamic> temp = {};
      // לבדוק אם יש בחירה בתוספים ולהכניס אותם לשימה הגדולה עם בחירת צד נכונה
      int stopPoint = halfQuantitiy.length % 2 == 0
          ? halfQuantitiy.length
          : halfQuantitiy.length - 1;
      for (int i = 0; i <= stopPoint / 2; i += 2) {
        temp = {};
        for (var key in keyNames) {
          //אם שניהם נבחרו
          if (halfQuantitiy[i][key] != 0 && halfQuantitiy[i + 1][key] != 0) {
            // halfQuantitiy[i][key] = 1;
            temp['$key'] = 1;
          }
          //אחד נבחר
          else if ((halfQuantitiy[i][key] == 0 &&
                  halfQuantitiy[i + 1][key] != 0) ||
              (halfQuantitiy[i][key] != 0 && halfQuantitiy[i + 1][key] == 0)) {
            if (halfQuantitiy[i][key] > halfQuantitiy[i + 1][key]) {
              temp['$key'] = halfQuantitiy[i][key];
            } else {
              temp['$key'] = halfQuantitiy[i + 1][key];
            }
          } else {
            temp['$key'] = 0;
          }
        }
        order.add(temp);
      }
    }
    //הוספת האיבר האחרון במידה ואורך העגלה אינו זוגי
    if (halfQuantitiy.length % 2 != 0 && halfQuantitiy.length != 1) {
      order.add(halfQuantitiy.last);
    }
    FireBase.addNewOrder(count, order);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          flex: 1,
          child: Meal.mealList.length == 0
              ? Text('')
              : pageOffset % 1 != 0
                  ? Text('')
                  : Text(
                      'מגש: ${(pageOffset + 1).toStringAsFixed(0)}',
                      textDirection: TextDirection.rtl,
                      style: kTextStyle.copyWith(color: Colors.black54),
                    ),
        ),
        Expanded(
          flex: 10,
          child: PageView.builder(
              controller: pageController,
              itemCount: Meal.mealList.length,
              itemBuilder: (context, index) {
                double scale = max(viewportFraction,
                    (1 - (pageOffset - index).abs()) + viewportFraction);
                double angle = (pageOffset - index).abs();
                if (angle > 0.5) {
                  angle = 1 - angle;
                }

                return Container(
                  height: MediaQuery.of(context).size.height * 0.7,
                  width: MediaQuery.of(context).size.width * 0.8,
                  padding: EdgeInsets.only(
                      right: 10, left: 5, top: 20 - scale * 2, bottom: 5),
                  color: Color.fromRGBO(247, 247, 247, 1),
                  child: Transform(
                    transform: Matrix4.identity()
                      ..setEntry(3, 2, 0.001)
                      ..rotateY(angle),
                    alignment: Alignment.center,
                    child: FlipCardWidget(
                      trayNum: index,
                    ),
                  ),
                );
              }),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            FloatingActionButton(
                heroTag: null,
                backgroundColor: Colors.white,
                child: Icon(
                  Icons.delete,
                  color: Colors.red,
                ),
                onPressed: () {
                  int pageNum = pageController.page.toInt();
                  pageController.animateToPage(
                    pageNum - 1,
                    duration: Duration(milliseconds: 900),
                    curve: Curves.decelerate,
                  );
                  setState(() {
                    Meal.meals.removeAt(pageNum);
                    updateCart();
                  });
                }),
            FloatingActionButton(
              heroTag: null,
              backgroundColor: Colors.white,
              child: Icon(
                Icons.add,
                color: Colors.red,
              ),
              onPressed: () async {
                print('added');
                Map<String, dynamic> addOn = await Meal.initAddons();
                Meal.mealList.add(
                  new Meal(
                    userEmail: FireBase.user.email,
                    completed: false,
                    status: 0,
                    quantity: 0.5,
                    orderDate: DateTime.now(),
                    mealType: addOn,
                  ),
                );
                setState(() {});
                updateCart();
              },
            ),
            StreamBuilder<QuerySnapshot>(
              stream: FireBase.onlineServices(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Icon(Icons.error);
                }
                var onlineServes = snapshot.data.docs;
                bool storeOpenClose;
                for (var i in onlineServes) {
                  storeOpenClose = i.data()['onlineServes'];
                }

                return FloatingActionButton(
                  heroTag: null,
                  backgroundColor: storeOpenClose ? Colors.blue : Colors.grey,
                  child: Icon(Icons.send_rounded),
                  onPressed: !storeOpenClose
                      ? () {
                          Scaffold.of(context).showSnackBar(
                            SnackBar(
                              content: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.do_not_disturb,
                                    color: Colors.red,
                                  ),
                                  SizedBox(
                                    width: 10,
                                  ),
                                  Text('חנות סגורה'),
                                ],
                              ),
                            ),
                          );
                        }
                      : () {
                          if (Meal.meals.isNotEmpty) {
                            var success;
                            showDialog(
                              context: context,
                              builder: (_) => AlertDialog(
                                actions: [
                                  FlatButton.icon(
                                    onPressed: () async {
                                      success = await Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => PaypalPayment(
                                            itemName: 'פיצה בכפר',
                                            totalAmount:
                                                getMealCount() * pizzaPrice,
                                            onFinish: (number) {
                                              if (number != 0) {
                                                Navigator.pop(context, true);
                                              }
                                            },
                                          ),
                                        ),
                                      );
                                      if (success != null && success) {
                                        Scaffold.of(context).showSnackBar(
                                          snackBarMessage(
                                              'שולם בהצלחה',
                                              Icon(
                                                Icons.check,
                                                size: 25,
                                                color: Colors.green,
                                              )),
                                        );
                                        orderToFirebase();
                                      } else {
                                        Scaffold.of(context).showSnackBar(
                                          snackBarMessage(
                                            'בעיית תשלום- לא בוצע חיוב',
                                            Icon(
                                              Icons.clear,
                                              size: 25,
                                              color: Colors.red,
                                            ),
                                          ),
                                        );
                                      }
                                      Navigator.pop(context);
                                      Meal.meals.clear();
                                      updateCart();
                                      if (!mounted) {
                                        setState(() {});
                                      }
                                    },
                                    icon: Icon(Icons.check),
                                    label: Text('הזמן'),
                                  ),
                                  FlatButton.icon(
                                      onPressed: () {
                                        Navigator.pop(context);
                                      },
                                      icon: Icon(Icons.cancel_outlined),
                                      label: Text('בטל'))
                                ],
                                content: Container(
                                  height: 250,
                                  width: 250,
                                  child: Column(
                                    children: [
                                      Icon(
                                        Icons.payment,
                                        color: Colors.blue,
                                        size: 30,
                                      ),
                                      Container(
                                        height: 200,
                                        width: 250,
                                        child: Card(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.stretch,
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceEvenly,
                                            children: [
                                              Text(
                                                'פרטי הזמנה',
                                                textDirection:
                                                    TextDirection.rtl,
                                                style: TextStyle(
                                                    fontSize: 20,
                                                    fontWeight:
                                                        FontWeight.w600),
                                              ),
                                              Text(
                                                'מייל:',
                                                textDirection:
                                                    TextDirection.rtl,
                                              ),
                                              Center(
                                                child: Text(
                                                    '${FireBase.user.email}'),
                                              ),
                                              Text(
                                                'שם:',
                                                textDirection:
                                                    TextDirection.rtl,
                                              ),
                                              Center(
                                                child: Text(
                                                  '${FireBase.user.firstName}, ${FireBase.user.lastName}',
                                                ),
                                              ),
                                              Text(
                                                'תאריך:',
                                                textDirection:
                                                    TextDirection.rtl,
                                              ),
                                              Center(
                                                child: Text(
                                                    '${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}'),
                                              ),
                                              Text(
                                                'כמות:',
                                                textDirection:
                                                    TextDirection.rtl,
                                              ),
                                              Center(
                                                  child: Text(
                                                      '${getMealCount()}')),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }
                        },
                );
              },
            ),
          ],
        ),
      ],
    );
  }
}

//---------------------------------------------------------------------

// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:pizzeria/consts.dart';
// import 'package:pizzeria/models/user.dart';
// import 'package:pizzeria/services/firebaseService.dart';
// import '../components/ErrorMSG.dart';
// import '../components/rounded_Button.dart';
// import '../models/meal.dart';
// import 'dart:math' as math;
// import '../services/paypalPayment.dart';
//
// class NewOrder extends StatefulWidget {
//   Function updateCart;
//   NewOrder({@required this.updateCart});
//   @override
//   _NewOrderState createState() => _NewOrderState(updateCart: updateCart);
// }
//
// class _NewOrderState extends State<NewOrder> {
//   Function updateCart;
//   _NewOrderState({this.updateCart});
//   Users stateUser = FireBase.user;
//
//   Map<String, dynamic> addOns;
//   List<String> addOnsKeyNames;
//   List<Meal> orderCart = [];
//   List<Image> mealImages = [];
//   List<Map> listOfMapsToFirebase = [];
//
//   bool selected = false, leftSide = false, rightSide = false;
//   int mealSelector = 0;
//   double pizzaCountInOrder = 0;
//
//   @override
//   void initState() {
//     super.initState();
//     getAddons();
//   }
//
//   Future<double> getPrice() async {
//     double orderCost = 0;
//     DocumentSnapshot ds = await FireBase.getPrices();
//     setState(() {
//       orderCost = ds.data()['p_price'] * pizzaCountInOrder;
//     });
//     return orderCost;
//   }
//
//   /*משיג מדאטה בייס את התוספות כ-סנאפשוט
//    ומוסיף אותם לרשימה של התוספות*/
//   void getAddons() async {
//     var t = await FireBase.getAddons();
//
//     for (var i in t.docs) {
//       setState(() {
//         addOns = i.data();
//       });
//       addOnsKeyNames = addOns.keys.toList();
//     }
//   }
//
//   void mealsUpdate(bool val) {
//     if (val) {
//       if (orderCart.isEmpty) {
//         orderCart.add(new Meal(
//             userEmail: FireBase.user.email,
//             quantity: 0.5,
//             mealType: new Map.from(addOns),
//             completed: false,
//             orderDate: DateTime.now(),
//             status: 0));
//         mealImages.add(Image.asset('img/onPizza.jpg'));
//       } else {
//         if (orderCart.last.quantity % 1 != 0) {
//           orderCart.last.quantity += 0.5;
//           mealImages.removeLast();
//           mealImages.add(Image.asset('img/onFull.jpg'));
//         } else {
//           orderCart.add(new Meal(
//               userEmail: FireBase.user.email,
//               quantity: 0.5,
//               mealType: new Map.from(addOns),
//               completed: false,
//               orderDate: DateTime.now(),
//               status: 0));
//           mealImages.add(Image.asset('img/onPizza.jpg'));
//         }
//       }
//     } else if (!val) {
//       if (orderCart.last.quantity % 1 == 0) {
//         orderCart.last.quantity -= 0.5;
//         mealImages.removeLast();
//         mealImages.add(Image.asset('img/onPizza.jpg'));
//       } else {
//         orderCart.removeLast();
//         mealImages.removeLast();
//       }
//     }
//   }
//
//   void clearMap() {
//     addOns.forEach((key, value) {
//       value = 0;
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     if (addOnsKeyNames == null && stateUser == null) {
//       return Center(
//         child: CircularProgressIndicator(),
//       );
//     }
//     return SingleChildScrollView(
//       child: Container(
//         height: MediaQuery.of(context).size.height * 0.7,
//         padding: EdgeInsets.all(10),
//         decoration: BoxDecoration(
//           gradient: LinearGradient(
//               colors: [Colors.blueAccent, Colors.white12],
//               begin: Alignment.topLeft,
//               end: Alignment.bottomRight),
//           borderRadius: BorderRadius.only(
//             topRight: Radius.circular(30),
//             topLeft: Radius.circular(30),
//           ),
//         ),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.start,
//           children: [
//             Text(
//               'הזמנה חדשה',
//               style: TextStyle(
//                   fontSize: 20,
//                   color: Colors.white,
//                   letterSpacing: 3,
//                   fontWeight: FontWeight.w700),
//             ),
//             SizedBox(
//               height: 10,
//             ),
//             FittedBox(
//               fit: BoxFit.fitWidth,
//               child: Row(
//                 textDirection: TextDirection.rtl,
//                 children: [
//                   Text(
//                     'כמות (מגש)',
//                     style: kTextStyle,
//                   ),
//                   FlatButton(
//                     textColor: Colors.white70,
//                     child: Icon(
//                       Icons.remove_circle,
//                       size: 40,
//                     ),
//                     onPressed: () {
//                       if (pizzaCountInOrder > 0) {
//                         setState(() {
//                           mealsUpdate(false);
//                           pizzaCountInOrder -= 0.5;
//                           if (pizzaCountInOrder == 0) {
//                             orderCart.clear();
//                           }
//                         });
//                       }
//                     },
//                   ),
//                   Text(
//                     '$pizzaCountInOrder',
//                     style: kTextStyle,
//                   ),
//                   FlatButton(
//                     child: Icon(
//                       Icons.add_circle,
//                       color: Colors.white70,
//                       size: 40,
//                     ),
//                     onPressed: () {
//                       if (pizzaCountInOrder < 6) {
//                         setState(() {
//                           mealsUpdate(true);
//                           pizzaCountInOrder += 0.5;
//                         });
//                       }
//                     },
//                   ),
//                 ],
//               ),
//             ),
//             SizedBox(
//               height: 10,
//             ),
//             Expanded(
//               flex: 3,
//               child: SingleChildScrollView(
//                 scrollDirection: Axis.horizontal,
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                   textDirection: TextDirection.rtl,
//                   children: List.generate(mealImages.length, (index) {
//                     return GestureDetector(
//                       onTap: () {
//                         setState(() {
//                           mealSelector = index;
//                         });
//                       },
//                       child: Container(
//                         padding:
//                             EdgeInsets.symmetric(horizontal: 5, vertical: 5),
//                         decoration: mealSelector == index
//                             ? BoxDecoration(
//                                 color: Colors.transparent,
//                                 borderRadius: BorderRadius.circular(40),
//                                 boxShadow: [
//                                   BoxShadow(
//                                     color: Colors.deepOrangeAccent
//                                         .withOpacity(0.7),
//                                     spreadRadius: 6,
//                                     blurRadius: 10,
//                                     offset: Offset(
//                                         0, 0), // changes position of shadow
//                                   ),
//                                 ],
//                               )
//                             : BoxDecoration(
//                                 color: Colors.transparent,
//                               ),
//                         child: ClipRRect(
//                           child: mealImages[index],
//                           borderRadius: BorderRadius.circular(50),
//                         ),
//                       ),
//                     );
//                   }),
//                 ),
//               ),
//             ),
//             SizedBox(
//               height: 10,
//             ),
//             Divider(
//               color: Colors.grey,
//               thickness: 2,
//               indent: MediaQuery.of(context).size.width * 0.1,
//               endIndent: MediaQuery.of(context).size.width * 0.1,
//             ),
//             Text(
//               orderCart.length == 0 ? '' : '${mealSelector + 1} תוספות למגש',
//               style: kTextStyle,
//             ),
//             /*מיכל המכיל את שמות התוספות*/
//             Expanded(
//               flex: 6,
//               child: orderCart.isEmpty
//                   ? Center(
//                       child: Text('בחר כמות מגש'),
//                     )
//                   : SingleChildScrollView(
//                       child: Container(
//                         margin: EdgeInsets.only(top: 10, bottom: 10),
//                         decoration: BoxDecoration(
//                           color: Colors.white12,
//                           borderRadius: BorderRadius.only(
//                               bottomRight: Radius.circular(40),
//                               bottomLeft: Radius.circular(20),
//                               topRight: Radius.circular(40),
//                               topLeft: Radius.circular(20)),
//                         ),
//                         child: Column(
//                           children: List.generate(
//                               mealSelector < orderCart.length
//                                   ? orderCart[mealSelector]
//                                       .mealType
//                                       .keys
//                                       .toList()
//                                       .length
//                                   : mealSelector = 0, (index) {
//                             return AddOns(
//                               label: addOnsKeyNames[index],
//                               toSelect: orderCart[mealSelector]
//                                   .mealType[addOnsKeyNames[index]],
//                               func: (int x) {
//                                 setState(() {
//                                   if (orderCart[mealSelector]
//                                           .mealType[addOnsKeyNames[index]] ==
//                                       x) {
//                                     x = 0;
//                                   }
//                                   orderCart[mealSelector]
//                                       .mealType[addOnsKeyNames[index]] = x;
// //                                      !orderCart[mealSelector]
// //                                          .mealType[addOnsKeyNames[index]];
//                                 });
//                               },
//                             );
//                           }),
//                         ),
//                       ),
//                     ),
//             ),
//             Expanded(
//               child: StreamBuilder<QuerySnapshot>(
//                 stream: FireBase.onlineServices(),
//                 builder: (context, snapshot) {
//                   if (!snapshot.hasData) {
//                     return Center(
//                       child: CircularProgressIndicator(),
//                     );
//                   }
//                   var onlineServes = snapshot.data;
//                   bool storeOpenClose;
//                   for (var i in onlineServes.docs) {
//                     storeOpenClose = i.data()['onlineServes'];
//                   }
//                   if (storeOpenClose == true) {
//                     return Padding(
//                       padding: EdgeInsets.symmetric(vertical: 5),
//                       child: RoundedButton(
//                         text: 'הזמן',
//                         onTape: () async {
//                           double orderCost = await getPrice();
//                           if (orderCart.isNotEmpty) {
//                             showDialog(
//                               context: context,
//                               barrierDismissible: false,
//                               builder: (_) => AlertDialog(
//                                 title: Text(
//                                   'אישור הזמנה',
//                                   textAlign: TextAlign.end,
//                                 ),
//                                 content: orderCost != 0
//                                     ? Text(
//                                         'כמות: $pizzaCountInOrder, מחיר: $orderCost',
//                                         textDirection: TextDirection.rtl,
//                                       )
//                                     : ('...'),
//                                 elevation: 3,
//                                 actions: [
//                                   FlatButton(
//                                     child: Text(
//                                       'כן',
//                                       textAlign: TextAlign.start,
//                                     ),
//                                     onPressed: () async {
//                                       await Navigator.push(
//                                         context,
//                                         MaterialPageRoute(
//                                           builder: (context) => PaypalPayment(
//                                             totalAmount: orderCost,
//                                             itemName: 'פיצה בכפר',
//                                             quantity: pizzaCountInOrder,
//                                             onFinish: (number) {
//                                               if (number != null) {
//                                                 for (int i = 0;
//                                                     i < orderCart.length;
//                                                     i++) {
//                                                   listOfMapsToFirebase.add(
//                                                       orderCart[i].mealType);
//                                                 }
//                                                 try {
//                                                   FireBase.addNewOrder(
//                                                       pizzaCountInOrder,
//                                                       listOfMapsToFirebase);
//                                                 } catch (e) {
//                                                   ErrorMsg(
//                                                     msg: e.toString(),
//                                                   );
//                                                 }
//                                                 setState(() {
//                                                   getAddons();
//                                                 });
//                                                 listOfMapsToFirebase.clear();
//                                                 orderCart.clear();
//                                                 mealImages.clear();
//                                                 mealSelector = 0;
//                                                 pizzaCountInOrder = 0;
//                                               }
//                                             },
//                                           ),
//                                         ),
//                                       );
//                                       Navigator.pop(context);
//                                     },
//                                   ),
//                                   FlatButton(
//                                     child: Text(
//                                       'לא',
//                                       textAlign: TextAlign.start,
//                                     ),
//                                     onPressed: () {
//                                       Navigator.pop(context);
//                                     },
//                                   ),
//                                 ],
//                               ),
//                             );
//                           } else {
//                             return showDialog(
//                               context: context,
//                               builder: (_) => AlertDialog(
//                                 elevation: 5,
//                                 title: Icon(
//                                   Icons.error_outline_sharp,
//                                   size: 30,
//                                 ),
//                                 content: Text(
//                                   'סל קניות ריק',
//                                   textDirection: TextDirection.rtl,
//                                 ),
//                               ),
//                             );
//                           }
//                         },
//                       ),
//                     );
//                   }
//                   return Text(
//                     'חנות סגורה',
//                     style: kTextStyle.copyWith(color: Colors.black),
//                   );
//                 },
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
//
// //TODO: new file widget for addons
//
// // ignore: must_be_immutable
// class AddOns extends StatelessWidget {
//   AddOns({this.label, this.func, this.toSelect});
//
//   final String label;
//   final int toSelect;
//   final Function func;
// //  final Function toggleCheckBoxState;
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       margin: EdgeInsets.symmetric(vertical: 10),
//       decoration: kAddonContainerDecoration.copyWith(
//           borderRadius: BorderRadius.only(
//               topLeft: Radius.circular(10),
//               topRight: Radius.circular(20),
//               bottomLeft: Radius.circular(20),
//               bottomRight: Radius.circular(10)),
//           gradient: LinearGradient(
//               colors: [Colors.blueGrey, Colors.white],
//               begin: Alignment.topRight,
//               end: Alignment.bottomLeft)),
//       child: Container(
//         child: Row(
//           textDirection: TextDirection.rtl,
//           mainAxisAlignment: MainAxisAlignment.start,
//           children: <Widget>[
//             Expanded(
//               flex: 2,
//               child: Center(
//                 child: Text(
//                   label,
//                   style: kTextStyle.copyWith(color: Colors.black),
//                 ),
//               ),
//             ),
//             Expanded(
//               flex: 5,
//               child: Row(
//                 textDirection: TextDirection.rtl,
//                 mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                 children: <Widget>[
//                   GestureDetector(
//                     child: AnimatedSwitcher(
//                       duration: Duration(milliseconds: 400),
//                       transitionBuilder:
//                           (Widget child, Animation<double> animation) {
//                         return ScaleTransition(
//                           scale: animation,
//                           child: child,
//                         );
//                       },
//                       child: toSelect == 2
//                           ? ClipRRect(
//                               key: ValueKey(1),
//                               borderRadius: BorderRadius.circular(50),
//                               child: Transform.rotate(
//                                 angle: 180 * math.pi / 180,
//                                 child: Image.asset(
//                                   'img/onPizza.jpg',
// //                                : 'img/offPizza.png',
//                                   height: 50,
//                                   width: 50,
//                                 ),
//                               ),
//                             )
//                           : ClipRRect(
//                               key: ValueKey(2),
//                               borderRadius: BorderRadius.circular(50),
//                               child: Transform.rotate(
//                                 angle: 180 * math.pi / 180,
//                                 child: Image.asset(
// //                      'img/onPizza.jpg',
//                                   'img/offPizza.png',
//                                   height: 50,
//                                   width: 50,
//                                 ),
//                               ),
//                             ),
//                     ),
//                     onTap: () => func(2),
//                   ),
//                   GestureDetector(
//                     child: AnimatedSwitcher(
//                       duration: Duration(milliseconds: 400),
//                       transitionBuilder:
//                           (Widget child, Animation<double> animation) {
//                         return RotationTransition(
//                           turns: animation,
//                           child: child,
//                         );
//                       },
//                       child: toSelect == 1
//                           ? ClipRRect(
//                               key: ValueKey(3),
//                               borderRadius: BorderRadius.circular(50),
//                               child: Image.asset(
//                                 'img/onFull.jpg',
//                                 height: 50,
//                                 width: 50,
//                               ),
//                             )
//                           : ClipRRect(
//                               key: ValueKey(4),
//                               borderRadius: BorderRadius.circular(50),
//                               child: Image.asset(
//                                 'img/offFull.png',
//                                 height: 50,
//                                 width: 50,
//                               ),
//                             ),
//                     ),
//                     onTap: () => func(1),
//                   ),
//                   GestureDetector(
//                     child: AnimatedSwitcher(
//                       duration: Duration(milliseconds: 400),
//                       transitionBuilder:
//                           (Widget child, Animation<double> animation) {
//                         return ScaleTransition(
//                           scale: animation,
//                           child: child,
//                         );
//                       },
//                       child: toSelect == 3
//                           ? ClipRRect(
//                               key: ValueKey(5),
//                               borderRadius: BorderRadius.circular(50),
//                               child: Image.asset(
//                                 'img/onPizza.jpg',
//                                 height: 50,
//                                 width: 50,
//                               ),
//                             )
//                           : ClipRRect(
//                               key: ValueKey(6),
//                               borderRadius: BorderRadius.circular(50),
//                               child: Image.asset(
//                                 'img/offPizza.png',
//                                 height: 50,
//                                 width: 50,
//                               ),
//                             ),
//                     ),
//                     onTap: () => func(3),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
