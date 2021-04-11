import 'package:flutter/material.dart';
import 'package:pizzeria/screens/user_home_screen.dart';
import '../components/textFieldEmail.dart';
import '../components/textFieldPassword.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import '../components/ErrorMSG.dart';

class LoginScreen extends StatefulWidget {
  static const String ID = 'login_screen';
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _auth = FirebaseAuth.instance;

  bool spinner = false;
  String email, password;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: ModalProgressHUD(
        inAsyncCall: spinner,
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Icon(
                    Icons.account_circle,
                    size: 90,
                    color: Colors.blueAccent,
                  ),
                  SizedBox(
                    height: 30,
                  ),
                  TextFieldEmail(
                    hint: 'Enter Email',
                    onTape: (val) {
                      email = val;
                    },
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  TextFieldPassword(
                    hint: 'Password',
                    onTape: (val) {
                      password = val;
                    },
                  ),
                  SizedBox(
                    height: 30,
                  ),
                  FloatingActionButton(
                    heroTag: null,
                    child: Text('כניסה'),
                    elevation: 5,
                    onPressed: () async {
                      setState(() {
                        spinner = true;
                      });

                      try {
                        final toLogUser =
                            await _auth.signInWithEmailAndPassword(
                                email: email, password: password);
                        if (toLogUser != null) {
                          Navigator.popAndPushNamed(context, UserHomeScreen.ID);
                        }
                        setState(() {
                          spinner = false;
                        });
                      } catch (e) {
                        showDialog(
                          context: context,
                          builder: (_) => ErrorMsg(
                            msg: 'Email/Password incorrect',
                          ),
                          barrierDismissible: true,
                        );
                        setState(() {
                          spinner = false;
                        });
                      }
                    },
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
