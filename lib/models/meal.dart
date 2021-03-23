import 'dart:ffi';
import '../services/firebaseService.dart';

class Meal {
  static Map<String, dynamic> addOns;
  // static List addOnsKeyNames;
  static List<Meal> meals = [];

  String userEmail;
  Map<String, dynamic> mealType;
  bool completed;
  DateTime orderDate;
  double quantity;
  int status;

  Meal({
    this.userEmail,
    this.quantity,
    this.orderDate,
    this.status,
    this.mealType,
    this.completed,
  });

  static List<Meal> get mealList {
    return meals == null ? meals = [] : meals;
  }

  // static Future<Map<String, dynamic>> getaddOns() async {
  //   if (addOns == null) {
  //     await _initAddons();
  //     return addOns;
  //   }
  //   return addOns;
  // }
  //
  static Future<Map<String, dynamic>> initAddons() async {
    Map<String, dynamic> toNewMeal = new Map();
    if (addOns == null || addOns.isEmpty) {
      var t = await FireBase.getAddons();
      for (var i in t.docs) {
        addOns = i.data();
      }
    }
    toNewMeal = new Map.from(addOns);
    return toNewMeal;
  }
}
