import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class OrderHistoryFile {
  String _path;
  File _file;

  orderStatus() async {
    File file = await _localFile;
    bool fileFound = await file.exists();
    if (fileFound == false) {
      file.create();
    }
  }

  Future<String> get _localPath async {
    final path = await getApplicationDocumentsDirectory();
    return path.path;
  }

  Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/orderHistory.txt');
  }

  Future<void> writeToFile(String order) async {
    final file = await _localFile;
    try {
      await file.writeAsString('$order\n', mode: FileMode.append);
    } catch (e) {
      print('Could not save file');
      print(e.toString());
    }
  }

  Future<List<Map<String, dynamic>>> readOrderHistoryFile() async {
    List<Map<String, dynamic>> orderList = [];
    final file = await _localFile;
    await file.readAsLines().then((value) {
      for (String str in value) {
        var json = jsonDecode(str);
        Map<String, dynamic> map = {
          'orderDate': DateTime.parse(json['orderDate']),
          'quantity': json['quantity'],
          'mealType': json['mealType']
        };
        orderList.add(map);
      }
    });
    return orderList;
  }
}
