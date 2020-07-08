import 'dart:ffi';

class Meal {
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
}
