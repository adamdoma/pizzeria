import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user.dart';

class FireBase {
  static User user;
  static QuerySnapshot addons;
  static QuerySnapshot ordersHistory;

  //=--------------------------------------שאילתות--------------------------------------//

  static Future<User> getCurrentUserInfo() async {
    if (user != null) return user;
    try {
      final tempUser = await FirebaseAuth.instance.currentUser();
      await Firestore.instance
          .collection('user')
          .where('email', isEqualTo: tempUser.email)
          .getDocuments()
          .then((value) {
        DocumentSnapshot ds = value.documents.first;
        user = new User(
            email: ds.data['email'],
            lastName: ds.data['last_name'],
            firstName: ds.data['first_name']);
      });
      return user;
    } catch (e) {
      print('error in getCurrentUserInfo in services/firebase\n $e');
    }
    return null;
  }

  static Stream getActiveOrders(String userEmail) {
    return Firestore.instance.collection('active_orders').snapshots();
  }

  static Future<QuerySnapshot> getUserHistoryOrders() async {
    if (ordersHistory != null) return ordersHistory;
    ordersHistory = await Firestore.instance
        .collection('orders')
        .where('user_email', isEqualTo: user.email)
        .getDocuments();
    return ordersHistory;
  }

  static Future<QuerySnapshot> getAddons() async {
    if (addons != null) return addons;
    addons = await Firestore.instance.collection('add_on').getDocuments();
    return addons;
  }

  static void clearForLogout() {
    ordersHistory = null;
    user = null;
    addons = null;
  }

  static Stream onlineServess() {
    return Firestore.instance.collection('store').snapshots();
  }

  static void addNewOrder(double count, List<Map> addons) async {
    await Firestore.instance.collection('active_orders').add({
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
    bool isOk = false;
    try {
      await Firestore.instance
          .collection('user')
          .where('email', isEqualTo: '${user.email}')
          .getDocuments()
          .then((value) async {
        await Firestore.instance
            .document("user/${value.documents[0].documentID}")
            .updateData({"first_name": newName, "last_name": newLastName});
      });
      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }

  static void refresh() async {
    clearForLogout();
    await getCurrentUserInfo();
  }
}
