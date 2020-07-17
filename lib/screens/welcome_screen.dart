import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pizzeria/screens/login_screen.dart';
import '../components/rounded_Button.dart';
import '../screens/registration_screen.dart';

class WelcomeScreen extends StatefulWidget {
  static const String ID = 'welcome_screen';
  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with SingleTickerProviderStateMixin {
  double test = 0;
  double padding = 0;

  AnimationController controller;
  Animation anim;

  @override
  void initState() {
    super.initState();

    controller = AnimationController(
      duration: Duration(seconds: 2),
      vsync: this,
    );
    anim = CurvedAnimation(parent: controller, curve: Curves.bounceIn);
    controller.forward();
    controller.addListener(() {
      setState(() {
        padding = controller.value * 300;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(247, 247, 247, 1),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          //TODO: להוסיף תמונה במקום שומר המקום
          Container(
            height: MediaQuery.of(context).size.height * 0.6,
            width: MediaQuery.of(context).size.width,
            child: AnimatedContainer(
              duration: Duration(seconds: 2),
              curve: Curves.ease,
              padding: EdgeInsets.only(top: padding * 0.7),
              child: Image.asset(
                'img/pizza.png',
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
          ),
        ],
      ),
    );
  }
}
