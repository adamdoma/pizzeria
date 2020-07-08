import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pizzeria/models/user.dart';
import '../components/rounded_Button.dart';

class NewOrder extends StatefulWidget {
  @override
  _NewOrderState createState() => _NewOrderState();
}

class _NewOrderState extends State<NewOrder> {
  final _fireStore = Firestore.instance;
  FirebaseAuth _auth = FirebaseAuth.instance;
  FirebaseUser stateUser;
  double count = 0.5;
  Map<String, dynamic> addOns;
  List<String> addOnsKeyNames;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    test();
  }

  void test() async {
    stateUser = await _auth.currentUser();
    var t = await _fireStore.collection('add_on').getDocuments();
    for (var i in t.documents) {
      setState(() {
        addOns = i.data;
      });
      addOnsKeyNames = addOns.keys.toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (addOnsKeyNames == null && stateUser == null) {
      return Center(
        child: CircularProgressIndicator(),
      );
    }
    return Container(
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
                child: Icon(Icons.remove),
                onPressed: () {
                  if (count > 0.5) {
                    setState(() {
                      count -= 0.5;
                    });
                  }
                },
              ),
              Text('$count'),
              FlatButton(
                child: Icon(Icons.add),
                onPressed: () {
                  if (count < 4) {
                    setState(() {
                      count += 0.5;
                    });
                  }
                },
              ),
              Text('כמות (מגש)'),
            ],
          ),
          SizedBox(
            height: 10,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text('תוספות'),
            ],
          ),
          Expanded(
            flex: 4,
            child: Container(
              margin: EdgeInsets.only(top: 10, bottom: 10),
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(30),
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
                    padding: EdgeInsets.only(top: 30),
                    alignment: Alignment.center,
                    margin:
                        EdgeInsets.only(top: 5, bottom: 5, left: 5, right: 5),
                    decoration: BoxDecoration(
                      color: Color(0xff57ccba),
                      borderRadius: BorderRadius.circular(100),
                      border: Border.all(color: Colors.white, width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.deepPurple.withOpacity(0.7),
                          spreadRadius: 2,
                          blurRadius: 9,
                          offset: Offset(0, 8), // changes position of shadow
                        ),
                      ],
                    ),
                    child: AddOns(
                      label: addOnsKeyNames[index],
                      isChecked: addOns[addOnsKeyNames[index]],
                      toggleCheckBoxState: (bool newVal) {
                        setState(() {
                          addOns[addOnsKeyNames[index]] = newVal;
                        });
                      },
                    ),
                  );
                }),
              ),
            ),
          ),
          Expanded(
            child: RoundedButton(
              text: 'Order',
              onTape: () {
                try {
                  _fireStore.collection('orders').add({
                    'completed': false,
                    'meal_type': addOns,
                    'order_date': Timestamp.now(),
                    'quantity': count,
                    'status': 0,
                    'user_email': stateUser.email
                  });
                } catch (e) {
                  print(e);
                }
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
  AddOns({this.label, this.isChecked, this.toggleCheckBoxState});

  final String label;
  final bool isChecked;
  final Function toggleCheckBoxState;
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label),
        Checkbox(
          value: isChecked,
          onChanged: toggleCheckBoxState,
        ),
      ],
    );
  }
}
//
//Container(
//decoration: BoxDecoration(
//color: Colors.white,
//borderRadius: BorderRadius.all(
//Radius.circular(15),
//),
//),
//padding: EdgeInsets.all(10),
//margin: EdgeInsets.only(bottom: 40, top: 10),
//child: ListView.builder(
//itemCount: addOnsKeyNames.length,
//itemBuilder: (context, index) {
//return AddOns(
//label: addOnsKeyNames[index],
//isChecked: addOns[addOnsKeyNames[index]],
//toggleCheckBoxState: (bool newVal) {
//setState(() {
//addOns[addOnsKeyNames[index]] = newVal;
//});
//},
//);
//},
//),
//),
