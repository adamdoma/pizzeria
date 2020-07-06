import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pizzeria/models/meal.dart';

class OrederHistory extends StatefulWidget {
  @override
  _OrederHistoryState createState() => _OrederHistoryState();
}

class _OrederHistoryState extends State<OrederHistory> {

  final _auth = FirebaseAuth.instance;
  final _fireStore = Firestore.instance;
  FirebaseUser fbu;
  List<Meal> mealList =new List();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Future.delayed(Duration(seconds: 3));
    UserOrderHistory();
  }

  void UserOrderHistory()async{
    fbu = await _auth.currentUser();
    await _fireStore.collection('orders').where('user_email',isEqualTo: fbu.email).getDocuments().then((doc){
      for(var i in doc.documents){
        setState(() {
          mealList.add(new Meal(userEmail: fbu.email,completed: i.data['completed'],mealType: i.data['meal_type'],orderDate: i.data['order_date'].toDate(),quantity: i.data['quantity'],status: i.data['status']));
        });
      }
    });

  }

  @override
  Widget build(BuildContext context) {
    if(mealList.isEmpty){
      return Center(child: Text('אין היסטוריה'),);
    }
    else
    return Container(
      padding: EdgeInsets.only(top: 20),
      decoration: BoxDecoration(
        color: Colors.blueAccent,
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(30),
          topLeft: Radius.circular(30),
        ),
      ),
      child: Column(
        children: <Widget>[
          Expanded(child:  ListView.builder(
            itemCount:mealList.length ,
            itemBuilder: (context,index){
              return Card(
                elevation: 5,
                child: ListTile(
                  subtitle: Text('Date: ${mealList[index].orderDate.day}/${mealList[index].orderDate.month}/${mealList[index].orderDate.year}'),
                  title: Text('${mealList[index].userEmail}'),
                  trailing: Text('20\$'),
                )
              );
            },
          ),
          )
        ],
      ),
    );
  }
}
