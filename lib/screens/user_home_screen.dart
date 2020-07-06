import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user.dart';
import '../components/ErrorMSG.dart';
import '../screens/order_screen.dart';
import '../screens/order_history_screen.dart';
import '../components/updatesFromSeller.dart';

class UserHomeScreen extends StatefulWidget {
  static const String ID = 'uaer_home_screen';
  @override
  _UserHomeScreenState createState() => _UserHomeScreenState();
}

class _UserHomeScreenState extends State<UserHomeScreen>
    with SingleTickerProviderStateMixin {
  final _auth = FirebaseAuth.instance;
  final _fireStore = Firestore.instance;
  FirebaseUser loggedUser;
  User user;

  TabController _tabController;

  bool spinner = false;

  final List<Widget> myList = [
    NewOrder(),
    OrederHistory(),
  ];

  int tabIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(vsync: this, length: 3);
    getCurrentUser();
  }

  void getCurrentUser() async {
    setState(() {
      spinner = true;
    });
    try {
      final tempUser = await _auth.currentUser();
      if (tempUser != null) {
        //get all user info from database
        final collection = await _fireStore.collection('user').getDocuments();
        for (var u in collection.documents) {
          if (u.data['email'] == tempUser.email) {
            user = new User(
                email: u.data['email'],
                firstName: u.data['first_name'],
                lastName: u.data['last_name']);
          }
        }
        setState(() {
          spinner = false;
        });
      } else {
        showDialog(
          context: context,
          builder: (_) => ErrorMsg(
            msg: 'Something went wrong',
          ),
          barrierDismissible: true,
        );
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${spinner == true ? '' : user.getFirstName()}'),
        elevation: 3,
        actions: [
          FlatButton(
            child: Text(
              'logout',
              style: TextStyle(color: Colors.white),
            ),
            onPressed: () {
              try {
                _auth.signOut();
                Navigator.pop(context);
              } catch (e) {
                showDialog(
                    context: context,
                    barrierDismissible: true,
                    child: ErrorMsg(
                      msg: 'שגיאת התנתקות',
                    ));
              }
            },
          ),
        ],
      ),
      body: ModalProgressHUD(
        inAsyncCall: spinner,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            //TODO: to add the updates from seller about sales new meals atc.
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: UpdateFromSeller(
                  fireStore: _fireStore,
                  user: spinner == true ? null : user,
                ),
              ),
            ),
            Expanded(
              flex: 3,
              child: Container(
                  padding: EdgeInsets.all(10),
                  child: myList[tabIndex]
              ),
            ),
            TabBar(
              onTap: (val) {
                setState(() {
                  tabIndex = val;
                });
              },
              labelColor: Colors.deepOrange,
              controller: _tabController,
              tabs: [
                Tab(
                  icon: Icon(Icons.control_point),
                ),
                Tab(
                  icon: Icon(Icons.history),
                ),
                Tab(
                  icon: Icon(Icons.settings),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

//Text('Welcome ${spinner == true ? 'waiting' : loggedUser.email}'),
