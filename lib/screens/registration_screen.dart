import 'package:flutter/material.dart';
import 'package:pizzeria/services/firebaseService.dart';
import '../components/textFieldEmail.dart';
import '../components/textFieldPassword.dart';
import '../components/rounded_Button.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../screens/user_home_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

//TODO: להוסיף אם השם ושם משפחה ריקים להציג הודעה מתאימה
class RegistrationScreen extends StatefulWidget {
  static const String ID = 'registration_screen';
  @override
  _RegistrationScreenState createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _auth = FirebaseAuth.instance;
  final _fireStore = FirebaseFirestore.instance;
  String email, password, conformPassword;
  String firstName;
  String lastName;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Align(
                alignment: Alignment.center,
                child: Text(
                  'Register New User',
                  style: TextStyle(
                    fontSize: 20,
                    letterSpacing: 1.2,
                    color: Colors.blueAccent,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
              SizedBox(
                height: 20,
              ),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      child: TextFieldEmail(
                        hint: 'First Name',
                        onTape: (val) {
                          firstName = val;
                        },
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      child: TextFieldEmail(
                        hint: "Last Name",
                        onTape: (val) {
                          lastName = val;
                        },
                      ),
                    ),
                  )
                ],
              ),
              SizedBox(
                height: 20,
              ),
              TextFieldEmail(
                hint: 'Enter Email',
                onTape: (val) {
                  email = val;
                },
              ),
              SizedBox(
                height: 20,
              ),
              //name and last name
              SizedBox(
                height: 20,
              ),
              TextFieldPassword(
                hint: 'Enter Password',
                onTape: (val) {
                  password = val;
                },
              ),
              SizedBox(
                height: 20,
              ),
              TextFieldPassword(
                hint: 'Conform Password',
                onTape: (val) {
                  conformPassword = val;
                },
              ),
              SizedBox(
                height: 20,
              ),
              RoundedButton(
                text: 'Register',
                onTape: () async {
                  if (conformPassword == password && password.length > 5) {
                    try {
                      FireBase.addNewUser(email, password, firstName, lastName);
                    } catch (e) {
                      print(e);
                    }
                    Navigator.pushNamed(context, UserHomeScreen.ID);
                  } else {
                    showDialog(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: Text(
                          'Password don\'t match \nPassword To Short ',
                          style: TextStyle(color: Colors.red),
                        ),
                        elevation: 5,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      barrierDismissible: true,
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
