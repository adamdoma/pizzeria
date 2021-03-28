import 'package:pizzeria/models/user.dart';
import 'package:pizzeria/services/firebaseService.dart';

class Paypal {
  // item name, price and quantity
  String itemName = 'פיצה בכפר';
  // String itemPrice = '1.99';
  // int quantity = 1;
  Users user;

  Paypal() {
    initUser();
  }

  void initUser() async {
    user = await FireBase.getCurrentUserInfo();
  }

  static Map<dynamic, dynamic> _defaultCurrency = {
    "symbol": "ILS",
    "decimalDigits": 2,
    "symbolBeforeTheNumber": true,
    "currency": "ILS"
  };

  bool _isEnableShipping = false;
  bool _isEnableAddress = false;

  String _returnURL = 'return.example.com';
  String _cancelURL = 'cancel.example.com';

  String get returnUrl => _returnURL;
  String get cancelUrl => _cancelURL;

  Map<String, dynamic> getOrderParams(
      {String itemName,
      double quantity,
      double itemPrice,
      String firstName,
      String lastName}) {
    List items = [
      {
        "name": itemName,
        "quantity": 1,
        "price": itemPrice,
        "currency": _defaultCurrency["currency"]
      }
    ];

    // checkout invoice details
    String totalAmount = '$itemPrice';
    String subTotalAmount = '$itemPrice';
    String shippingCost = '0';
    int shippingDiscountCost = 0;
    String userFirstName = '${user.firstName}';
    String userLastName = '${user.lastName}';
    String addressCity = 'kfar kama';
    String addressStreet = '';
    String addressZipCode = '15235';
    String addressCountry = 'Israel';
    String addressState = 'Lower Galilee';
    String addressPhoneNumber = '0538255509';

    Map<String, dynamic> temp = {
      "intent": "sale",
      "payer": {"payment_method": "paypal"},
      "transactions": [
        {
          "amount": {
            "total": totalAmount,
            "currency": _defaultCurrency["currency"],
            "details": {
              "subtotal": subTotalAmount,
              "shipping": shippingCost,
              "shipping_discount": ((-1.0) * shippingDiscountCost).toString()
            }
          },
          "description": "The payment transaction description.",
          "payment_options": {
            "allowed_payment_method": "INSTANT_FUNDING_SOURCE"
          },
          "item_list": {
            "items": items,
            if (_isEnableShipping && _isEnableAddress)
              "shipping_address": {
                "recipient_name": userFirstName + " " + userLastName,
                "line1": addressStreet,
                "line2": "",
                "city": addressCity,
                "country_code": addressCountry,
                "postal_code": addressZipCode,
                "phone": addressPhoneNumber,
                "state": addressState
              },
          }
        }
      ],
      "note_to_payer": "Contact us for any questions on your order.",
      "redirect_urls": {"return_url": _returnURL, "cancel_url": _cancelURL}
    };
    return temp;
  }
}
