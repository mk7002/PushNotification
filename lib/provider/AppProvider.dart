import 'package:flutter/cupertino.dart';

class AppProvider with ChangeNotifier {
  static String TYPE = "type";
  static String MESSAGE = "message";
  static String URL = "url";
  static String HEADERS = "HEADERS";
  static String BODY = "BODY";
  static String TOKEN = "token";

  Map<String, dynamic> _result = {
    TYPE: ResultType.neutral,
    MESSAGE: "No Result"
  };

  Map<String, dynamic> _selectedPayloadData = {};

  List<Map<String, dynamic>> _payloadList = [];

  Map<String, dynamic> get selectedPayloadData => _selectedPayloadData;

  Map<String, dynamic> get result => _result;

  List<Map<String, dynamic>> get payloadList => _payloadList;

  void setResult(ResultType type, String message) {
    _result = {TYPE: type, MESSAGE: message};
    notifyListeners();
  }

  void setSelectedPayloadData(url, headers, body) {
    _selectedPayloadData = {URL: url, HEADERS: headers, BODY: body};
    notifyListeners();
  }

  void setPayloadList(List<Map<String, dynamic>>? list) {
    try {
      if (list != null) {
        _payloadList = list;
        notifyListeners();
      }
    } catch (e) {
      print(e);
    }
  }
}

enum ResultType { neutral, success, error, inProgress }
