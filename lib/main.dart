import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import './screens/login_screen.dart';
import './screens/welcome_screen.dart';
import './screens/registration_screen.dart';
import './screens/user_home_screen.dart';

void main() => runApp(Pizzeria());

class Pizzeria extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
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
}
