import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../models/user.dart';
import '../files/order_history_file.dart';

class FireBase {
  static Users user;
  static QuerySnapshot addons;
  static QuerySnapshot ordersHistory;
  static DocumentSnapshot prices;

  //=--------------------------------------שאילתות--------------------------------------//

  static Future<Users> getCurrentUserInfo() async {
    if (user != null) return user;
    try {
      final tempUser = FirebaseAuth.instance.currentUser;
      await FirebaseFirestore.instance
          .collection('user')
          .where('email', isEqualTo: tempUser.email)
          .get()
          .then((value) {
        DocumentSnapshot ds = value.docs.first;
        user = new Users(
            email: ds.data()['email'],
            lastName: ds.data()['last_name'],
            firstName: ds.data()['first_name']);
      });
      return user;
    } catch (e) {
      print('error in getCurrentUserInfo in services/firebase\n $e');
    }
    return null;
  }

  static Stream getActiveOrders(String userEmail) {
    return FirebaseFirestore.instance.collection('active_orders').snapshots();
  }

  static Future<QuerySnapshot> getUserHistoryOrders() async {
    if (ordersHistory != null) return ordersHistory;
    ordersHistory = await FirebaseFirestore.instance
        .collection('orders')
        .where('user_email', isEqualTo: user.email)
        .get();
    return ordersHistory;
  }

  static void _updateUserHistoryOrders() async {
    ordersHistory = await FirebaseFirestore.instance
        .collection('orders')
        .where('user_email', isEqualTo: user.email)
        .get();
  }

  static Future<QuerySnapshot> getAddons() async {
    if (addons != null) return addons;
    addons = await FirebaseFirestore.instance.collection('add_on').get();
    return addons;
  }

  static void clearForLogout() {
    ordersHistory = null;
    user = null;
    addons = null;
  }

  static Stream onlineServices() {
    return FirebaseFirestore.instance.collection('store').snapshots();
  }

  static Future<DocumentSnapshot> getPrices() async {
    if (prices == null) {
      prices = await FirebaseFirestore.instance.doc('store/pizza_price').get();
    }
    return prices;
  }

  static void addNewOrder(double count, List<Map> addons) async {
    OrderHistoryFile orderHistoryFile = new OrderHistoryFile();
    Map<String, dynamic> map = {
      'orderDate': DateTime.now().toString(),
      'quantity': count,
      'mealType': addons
    };
    String json = jsonEncode(map);
    await orderHistoryFile.writeToFile(json);
    await FirebaseFirestore.instance.collection('active_orders').add({
      'completed': false,
      'meal_type': addons,
      'order_date': Timestamp.now(),
      'quantity': count,
      'status': 0,
      'user_email': user.email
    });
  }

  static Future<bool> editUserNameAndLastName(
      String newName, String newLastName) async {
    try {
      await FirebaseFirestore.instance
          .collection('user')
          .where('email', isEqualTo: '${user.email}')
          .get()
          .then((value) async {
        await FirebaseFirestore.instance
            .doc("user/${value.docs[0].id}")
            .update({"first_name": newName, "last_name": newLastName});
      });
      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }

  static void clearHistory() async {
    await FirebaseFirestore.instance
        .collection('orders')
        .where('user_email', isEqualTo: "${user.email}")
        .get()
        .then((value) {
      for (var document in value.docs) {
        FirebaseFirestore.instance
            .doc("orders/${document.id}")
            .update({"user_email": "${user.email}1"});
      }
    });
    _updateUserHistoryOrders();
  }

  static void addNewUser(
      String email, String password, String firstName, String lastName) async {
    try {
      UserCredential newUser = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);
      print(newUser.credential);
      if (newUser != null) {
        User theNewUser = FirebaseAuth.instance.currentUser;
        var tokin = await FirebaseMessaging().getToken();
        FirebaseFirestore.instance.collection('user').add({
          'email': theNewUser.email,
          'first_name': firstName,
          'last_name': lastName,
          'tokin': tokin,
        });
      }
    } catch (e) {
      print(e);
    }
  }
}
