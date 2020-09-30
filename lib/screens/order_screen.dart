import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pizzeria/consts.dart';
import 'package:pizzeria/models/user.dart';
import 'package:pizzeria/services/firebaseService.dart';
import '../components/ErrorMSG.dart';
import '../components/rounded_Button.dart';

class NewOrder extends StatefulWidget {
  @override
  _NewOrderState createState() => _NewOrderState();
}

class _NewOrderState extends State<NewOrder> {
  final _fireStore = Firestore.instance;
  User stateUser = FireBase.user;
  double count = 0.5;
  Map<String, dynamic> addOns;
  List<String> addOnsKeyNames;
  bool selected = false;

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
    return Container(
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
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              FlatButton(
                textColor: Colors.white70,
                child: Icon(
                  Icons.remove_circle,
                  size: 40,
                ),
                onPressed: () {
                  if (count > 0.5) {
                    setState(() {
                      count -= 0.5;
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
                  if (count < 4) {
                    setState(() {
                      count += 0.5;
                    });
                  }
                },
              ),
              Text(
                'כמות (מגש)',
                style: kTextStyle,
              ),
            ],
          ),
          SizedBox(
            height: 10,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                'תוספות',
                style: kTextStyle,
              ),
            ],
          ),
          /*מיכל המכיל את שמות התוספות*/
          Expanded(
            flex: 6,
            child: addOns == null
                ? Center(
                    child: CircularProgressIndicator(),
                  )
                : Container(
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
                          offset: Offset(0, 3), // changes position of shadow
                        ),
                      ],
                    ),
                    child: GridView.count(
                      crossAxisSpacing: 20,
                      mainAxisSpacing: 20,
                      crossAxisCount: 2,
                      children: List.generate(addOnsKeyNames.length, (index) {
                        return Container(
                          decoration: kAddonContainerDecoration.copyWith(
                              borderRadius:
                                  addOns[addOnsKeyNames[index]] == false
                                      ? BorderRadius.circular(40)
                                      : BorderRadius.circular(80)),
                          child: GestureDetector(
                            child: AddOns(
                              label: addOnsKeyNames[index],
                              isChecked: addOns[addOnsKeyNames[index]],
                            ),
                            onTap: () {
                              setState(() {
                                addOns[addOnsKeyNames[index]] =
                                    !addOns[addOnsKeyNames[index]];
                              });
                            },
                          ),
                        );
                      }),
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
                      style: kTextStyle.copyWith(color: Colors.lightBlueAccent),
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
    );
  }
}

// ignore: must_be_immutable
class AddOns extends StatelessWidget {
  AddOns({this.label, this.isChecked});

  final String label;
  final bool isChecked;
//  final Function toggleCheckBoxState;
  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      overflow: Overflow.clip,
      children: <Widget>[
        isChecked
            ? Icon(
                Icons.trip_origin,
                size: MediaQuery.of(context).size.width * 0.4,
                color: Colors.green.withAlpha(90),
              )
            : Icon(
                Icons.trip_origin,
                size: MediaQuery.of(context).size.width * 0.3,
                color: Colors.red.withAlpha(70),
              ),
        Text(
          label,
          style: kTextStyle.copyWith(color: Colors.black),
        ),
      ],
    );
  }
}
