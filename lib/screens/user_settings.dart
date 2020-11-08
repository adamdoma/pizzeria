import 'package:flutter/material.dart';
import 'package:pizzeria/components/ErrorMSG.dart';
import 'package:pizzeria/consts.dart';
import 'package:pizzeria/services/firebaseService.dart';
import '../components/editNamesTextField.dart';
import '../components/rounded_Button.dart';

class UserSettings extends StatefulWidget {
  @override
  _UserSettingsState createState() => _UserSettingsState();
}

class _UserSettingsState extends State<UserSettings>
    with TickerProviderStateMixin {
  AnimationController controller;
  AnimationController controller2;
  Animation animation;
  Animation animation2;
  final textEditingControllerFirstName = TextEditingController();
  final textEditingControllerLastName = TextEditingController();
  ScrollController _scrollController;

  String firsName = '';
  String lastName = '';

  @override
  void initState() {
    super.initState();
    controller =
        AnimationController(vsync: this, duration: Duration(seconds: 2));
    controller2 =
        AnimationController(vsync: this, duration: Duration(seconds: 4));
    animation = CurvedAnimation(parent: controller, curve: Curves.ease);
    animation2 = CurvedAnimation(parent: controller2, curve: Curves.ease);
//    controller.forward();
    controller.repeat(min: 0, max: 1, reverse: true);
    controller2.repeat(min: 0, max: 1, reverse: true);

    controller.addListener(() {
      setState(() {
//        print(animation2.value);
      });
    });
    controller2.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    controller.dispose();
    controller2.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      controller: _scrollController,
      child: Container(
        height: MediaQuery.of(context).size.height * 0.75,
        decoration: kContainerDecoration,
        child: Column(
          textDirection: TextDirection.rtl,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Text(
                '? מה תרצה לעשות',
                style: kTextStyle,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 30),
              child: Text(
                'שינוי שם',
                style: kTextStyle,
              ),
            ),
            ShaderMask(
              shaderCallback: (val) =>
                  LinearGradient(colors: kDividerColors).createShader(val),
              child: Divider(
                thickness: 6,
                color: Colors.white,
                indent: MediaQuery.of(context).size.width * 0.6,
                endIndent: 2,
              ),
            ),
            Row(
              textDirection: TextDirection.rtl,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  'שנה שם פרטי',
                  style: kTextStyle.copyWith(fontSize: 16),
                ),
                EditNameContainerWithTextField(
                  controller: textEditingControllerFirstName,
                  animation2: animation2,
                  animation: animation,
                  func: (val) {
                    firsName = val;
                    print(_scrollController.debugLabel.length);
                  },
                ),
              ],
            ),
            SizedBox(
              height: 10,
            ),
            Row(
              textDirection: TextDirection.rtl,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  'שנה שם מפשחה',
                  style: kTextStyle.copyWith(fontSize: 16),
                ),
                EditNameContainerWithTextField(
                  controller: textEditingControllerLastName,
                  animation2: animation2,
                  animation: animation,
                  func: (val) {
                    lastName = val;
                  },
                ),
              ],
            ),
            SizedBox(
              height: 20,
            ),
            Center(
              child: RoundedButton(
                text: "בצע",
                onTape: () {
                  try {
                    FireBase.editUserNameAndLastName(firsName, lastName);
                    showDialog(
                      context: context,
                      builder: (_) => ErrorMsg(
                        msg: "השם שונה בהצלחה אנא התחבר מחדש",
                      ),
                    );
                    textEditingControllerFirstName.clear();
                    textEditingControllerLastName.clear();
//                    setState(() {});
                  } catch (e) {
//                    showDialog(
//                      context: context,
//                      builder: (_) => ErrorMsg(
//                        msg: "הייתה בעיה, אנא נסה מאוחר יותר",
//                      ),
//                    );
                    print('wtf ------$e');
                  }
                },
              ),
            ),
            SizedBox(
              height: 20,
            ),
            ShaderMask(
//              blendMode: BlendMode.dstATop,
              shaderCallback: (val) =>
                  LinearGradient(colors: kDividerColors).createShader(val),
              child: Divider(
                thickness: 6,
                color: Colors.white,
              ),
            ),
            SizedBox(
              height: 20,
            ),
            Center(
              child: MaterialButton(
                elevation: 10,
                enableFeedback: true,
                child: Text(
                  'אפס היסטוריה',
                  style: kTextStyle.copyWith(color: Colors.black),
                ),
                shape: Border(
                    top: BorderSide(color: Colors.red, width: 3),
                    bottom: BorderSide(color: Colors.red, width: 3)),
                onPressed: () {
                  FireBase.clearHistory();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
