import 'dart:ffi';

import 'package:cloud_firestore/cloud_firestore.dart';

class Meal {
  String userEmail;
  Map<String, dynamic> mealType;
  bool completed;
  DateTime orderDate;
  int quantity;
  int status;

  Meal({
    this.userEmail,
    this.quantity,
    this.orderDate,
    this.status,
    this.mealType,
    this.completed,
  });
}
