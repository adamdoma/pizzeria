import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pizzeria/screens/login_screen.dart';
import 'package:pizzeria/screens/user_home_screen.dart';
import 'package:pizzeria/services/firebaseService.dart';
import '../components/rounded_Button.dart';
import '../screens/registration_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';

class WelcomeScreen extends StatefulWidget {
  static const String ID = 'welcome_screen';
  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with SingleTickerProviderStateMixin {
  double test = 0;
  double padding = 0;
  double _height = 0;
  double _width = 0;

  AnimationController controller;
  Animation anim;

  @override
  void initState() {
    super.initState();

    controller = AnimationController(
      duration: Duration(seconds: 4),
      vsync: this,
    );
    anim = CurvedAnimation(parent: controller, curve: Curves.elasticIn);
    // controller.forward();
    controller.repeat(
        max: 0.94, min: 0.5, reverse: true, period: Duration(seconds: 1));
    controller.addListener(() {
      setState(() {
        // padding = controller.value * 300;
        padding = _width = _height = controller.value * 300;
      });
    });

    FireBase.user = null;
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(247, 247, 247, 1),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          //TODO: להוסיף תמונה במקום שומר המקום
          Expanded(
            flex: 3,
            child: Center(
              child: Image.asset(
                'img/pizza.png',
                fit: BoxFit.contain,
                width: _width,
                height: _height,
              ),
            ),
          ),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.15,
          ),
          Expanded(
            child: Column(
              children: [
                RoundedButton(
                  text: 'LOGIN',
                  onTape: () {
                    if (FireBase.user == null)
                      Navigator.pushNamed(context, LoginScreen.ID);
                    else {
                      Navigator.pushNamed(context, UserHomeScreen.ID);
                    }
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
          ),
        ],
      ),
    );
  }
}
