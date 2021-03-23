import 'dart:math';

import 'package:flutter/material.dart';
import 'package:pizzeria/components/animated_switch.dart';
import '../models/meal.dart';
import 'package:pizzeria/consts.dart';

class FlipCardWidget extends StatefulWidget {
  int trayNum;
  FlipCardWidget({this.trayNum});
  @override
  _FlipCardWidgetState createState() => _FlipCardWidgetState(trayNum: trayNum);
}

class _FlipCardWidgetState extends State<FlipCardWidget> {
  _FlipCardWidgetState({this.trayNum});
  int trayNum;
  bool _isFlipped;
  double pizzaSize = 0.37;

  Color getAddonColorBox(Map<String, dynamic> map, int index) {
    List<String> keyNames = map.keys.toList();
    if (map[keyNames[index]] == 0) {
      return Colors.red;
    }
    return Colors.green;
  }

  void refresh(double size) {
    setState(() {
      pizzaSize = size;
    });
  }

  _frontPanel(BuildContext context, int trayNum) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      decoration: BoxDecoration(
        gradient: kLinearColorsContainer,
        borderRadius: BorderRadius.circular(50),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          AnmiSwitch(
            index: trayNum,
            refresh: refresh,
          ),
          AnimatedContainer(
            duration: Duration(milliseconds: 1200),
            height: MediaQuery.of(context).size.width * pizzaSize,
            width: MediaQuery.of(context).size.width * pizzaSize,
            curve: Curves.bounceOut,
            margin: EdgeInsets.only(top: 10),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(100),
              clipBehavior: Clip.antiAlias,
              child: Image.asset(
                'img/onFull.jpg',
                fit: BoxFit.fill,
              ),
            ),
          ),
          Text(
            'מעבר לתוספות',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 18,
            ),
          ),
        ],
      ),
    );
  }

  _backPanel(BuildContext context, int trayNum) {
    return Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
          gradient: kLinearColorsContainer,
          borderRadius: BorderRadius.circular(50),
        ),
        child: GridView.builder(
          itemCount: Meal.meals[trayNum].mealType.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              childAspectRatio: 1,
              mainAxisSpacing: 5,
              crossAxisSpacing: 5,
              crossAxisCount: 2),
          itemBuilder: (context, index) {
            bool isSelected = Meal.meals[trayNum].mealType[
                        '${Meal.meals[trayNum].mealType.keys.toList()[index]}'] ==
                    0
                ? false
                : true;
            return GestureDetector(
              onTap: () {
                if (isSelected) {
                  Meal.meals[trayNum].mealType[
                      '${Meal.meals[trayNum].mealType.keys.toList()[index]}'] = 0;
                } else {
                  if (Meal.meals[trayNum].quantity == 1) {
                    Meal.meals[trayNum].mealType[
                        '${Meal.meals[trayNum].mealType.keys.toList()[index]}'] = 3;
                  } else {
                    Meal.meals[trayNum].mealType[
                        '${Meal.meals[trayNum].mealType.keys.toList()[index]}'] = 1;
                  }
                }
                setState(() {});
              },
              // child: Image.asset(
              //   'img/olive.jpg',
              //   fit: BoxFit.contain,
              // ),
              child: Stack(
                children: [
                  AnimatedContainer(
                    duration: Duration(milliseconds: 600),
                    margin: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: isSelected
                              ? Colors.blueGrey.shade700
                              : Colors.grey.shade700,
                          spreadRadius: 3,
                          blurRadius: 5,
                          offset: isSelected ? Offset(-5, 7) : Offset(5, 7),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        '${Meal.meals[trayNum].mealType.keys.toList()[index]}',
                        style: TextStyle(fontWeight: FontWeight.w900),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 10,
                    left: 20,
                    child: Checkbox(
                        value: isSelected,
                        onChanged: (val) {
                          print(val);
                        }),
                  )
                ],
              ),
            );
          },
        ));
  }

  // child: ListView.builder(
  // itemCount: Meal.meals[trayNum].mealType.length,
  // itemBuilder: (context, index) {
  // return Center(
  // child: Container(
  // width: 50,
  // height: 50,
  // margin: EdgeInsets.all(5),
  // decoration: BoxDecoration(
  // // color: getAddonColorBox(Meal.meals[trayNum].mealType, index),
  // ),
  // child: GestureDetector(
  // onTap: () {
  // if (Meal.meals[trayNum].mealType[
  // '${Meal.meals[trayNum].mealType.keys.toList()[index]}'] !=
  // 0) {
  // Meal.meals[trayNum].mealType[
  // '${Meal.meals[trayNum].mealType.keys.toList()[index]}'] = 0;
  // } else {
  // if (Meal.meals[trayNum].quantity == 1) {
  // Meal.meals[trayNum].mealType[
  // '${Meal.meals[trayNum].mealType.keys.toList()[index]}'] = 3;
  // } else {
  // Meal.meals[trayNum].mealType[
  // '${Meal.meals[trayNum].mealType.keys.toList()[index]}'] = 1;
  // }
  // }
  // setState(() {});
  // },
  // child: Image.asset(
  // 'img/olive.jpg',
  // fit: BoxFit.contain,
  // ),
  // // child: Text(
  // //     '${Meal.meals[trayNum].mealType.keys.toList()[index]}'),
  // ),
  // ),
  // );
  // }),

  @override
  void initState() {
    _isFlipped = false;
    super.initState();
  }

  build(BuildContext context) {
    return Center(
      child: GestureDetector(
        onTap: () => setState(() => _isFlipped = !_isFlipped),
        child: FlippableBox(
          front: _frontPanel(context, widget.trayNum),
          back: _backPanel(context, widget.trayNum),
          isFlipped: _isFlipped,
        ),
      ),
    );
  }
}

class FlippableBox extends StatelessWidget {
  final Widget front;
  final Widget back;

  final bool isFlipped;

  const FlippableBox({
    Key key,
    this.isFlipped = false,
    this.front,
    this.back,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder(
      duration: Duration(milliseconds: 700),
      curve: Curves.easeOut,
      tween: Tween(begin: 0.0, end: isFlipped ? 180.0 : 0.0),
      builder: (context, value, child) {
        var content = value >= 90 ? back : front;
        return RotationY(
          rotationY: value,
          child: RotationY(
              rotationY: value > 90 ? 180 : 0,
              child: AnimatedBackground(child: content)),
        );
      },
    );
  }
}

class AnimatedBackground extends StatelessWidget {
  final Container child;
  const AnimatedBackground({Key key, this.child}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
        width: child.constraints.maxWidth,
        height: child.constraints.maxHeight,
        duration: Duration(milliseconds: 700),
        curve: Curves.easeOut,
        child: child);
  }
}

class RotationY extends StatelessWidget {
  //Degrees to rads constant
  static const double degrees2Radians = pi / 180;

  final Widget child;
  final double rotationY;

  const RotationY({Key key, @required this.child, this.rotationY = 0})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Transform(
        alignment: FractionalOffset.center,
        transform: Matrix4.identity()
          ..setEntry(3, 2, 0.001) //These are magic numbers, just use them :)
          ..rotateY(rotationY * degrees2Radians),
        child: child);
  }
}
