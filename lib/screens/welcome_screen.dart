import 'package:flutter/material.dart';
import 'package:pizzeria/screens/login_screen.dart';
import '../components/rounded_Button.dart';
import '../screens/registration_screen.dart';

class WelcomeScreen extends StatefulWidget {
  static const String ID = 'welcome_screen';
  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          //TODO: להוסיף תמונה במקום שומר המקום
          Placeholder(
            fallbackWidth: 100,
            fallbackHeight: 60,
          ),
          SizedBox(
            height: 10,
          ),
          RoundedButton(
            text: 'LOGIN',
            onTape: () {
              Navigator.pushNamed(context, LoginScreen.ID);
            },
          ),
          SizedBox(
            height: 10,
          ),
          RoundedButton(
            text: 'Register',
            onTape: () {
              Navigator.pushNamed(context, RegistrationScreen.ID);
            },
          ),
        ],
      ),
    );
  }
}
