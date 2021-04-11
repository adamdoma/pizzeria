import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pizzeria/models/meal.dart';

class AnmiSwitch extends StatefulWidget {
  int index;
  Function refresh;
  AnmiSwitch({@required this.index, @required this.refresh});
  @override
  _AnmiSwitchState createState() =>
      _AnmiSwitchState(index: index, refresh: refresh);
}

class _AnmiSwitchState extends State<AnmiSwitch>
    with SingleTickerProviderStateMixin {
  int index;
  Function refresh;
  _AnmiSwitchState({this.index, this.refresh});
  Duration _duration = Duration(milliseconds: 370);
  Animation<Alignment> _animation;
  AnimationController _animationController;

  Widget getLetter(String letter) {
    return Text(
      '$letter',
      style: TextStyle(fontWeight: FontWeight.w900),
    );
  }

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
        vsync: this,
        duration: _duration,
        value: Meal.meals[index].quantity == 0.5 ? 0 : 1);
    _animation = (Meal.meals[index].quantity == 0.5
            ? AlignmentTween(
                begin: Alignment.centerLeft, end: Alignment.centerRight)
            : AlignmentTween(
                begin: Alignment.centerRight, end: Alignment.centerLeft))
        .animate(
      CurvedAnimation(
          parent: _animationController,
          curve: Curves.bounceOut,
          reverseCurve: Curves.bounceIn),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Center(
          child: AnimatedContainer(
            duration: Duration(milliseconds: 600),
            margin: EdgeInsets.only(top: 10),
            width: 100,
            height: 40,
            padding: EdgeInsets.fromLTRB(0, 6, 0, 6),
            decoration: BoxDecoration(
                color: Meal.meals[index].quantity == 1
                    ? Colors.green
                    : Colors.green.shade200,
                borderRadius: BorderRadius.all(
                  Radius.circular(40),
                ),
                boxShadow: [
                  BoxShadow(
                      color: Meal.meals[index].quantity == 1
                          ? Colors.green
                          : Colors.green.shade200,
                      blurRadius: 12,
                      offset: Offset(0, 8))
                ]),
            child: Stack(
              children: <Widget>[
                Align(
                  alignment: _animation.value,
                  child: GestureDetector(
                    onTap: () {
                      double pizzaSize;
                      setState(() {
                        if (_animationController.isCompleted) {
                          _animationController.reverse();
                          Meal.meals[index].quantity = 0.5;
                          pizzaSize = 0.37;
                          print(Meal.meals[index].quantity);
                        } else {
                          _animationController.forward();
                          Meal.meals[index].quantity = 1;
                          pizzaSize = 0.45;
                          print(Meal.meals[index].quantity);
                        }
                        refresh(pizzaSize);
                      });
                    },
                    child: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                      ),
                      child: Meal.meals[index].quantity == 1
                          ? Center(
                              child: getLetter('L'),
                            )
                          : Center(
                              child: getLetter("S"),
                            ),
                    ),
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }
}
