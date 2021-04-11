import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:firebase_core/firebase_core.dart';
import './screens/login_screen.dart';
import './screens/welcome_screen.dart';
import './screens/registration_screen.dart';
import './screens/user_home_screen.dart';

void main() => runApp(Pizzeria());

class Pizzeria extends StatefulWidget {
  @override
  _PizzeriaState createState() => _PizzeriaState();
}

class _PizzeriaState extends State<Pizzeria> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Firebase.initializeApp(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Container(
              child: Text('error'),
            ),
          );
        }
        if (snapshot.connectionState == ConnectionState.done) {
          return MaterialApp(
            initialRoute: WelcomeScreen.ID,
            routes: {
              LoginScreen.ID: (context) => LoginScreen(),
              WelcomeScreen.ID: (context) => WelcomeScreen(),
              RegistrationScreen.ID: (context) => RegistrationScreen(),
              UserHomeScreen.ID: (context) => UserHomeScreen(),
            },
          );
        }
        return CircularProgressIndicator();
      },
    );
  }
}
