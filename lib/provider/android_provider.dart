import 'package:flutter/cupertino.dart';

class AndroidProvider with ChangeNotifier {
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

  List<void Function(Map<String, dynamic>)> callbacks = [];

  bool isConfigFileLoaded = false;

  void setResult(ResultType type, String message) {
    _result = {TYPE: type, MESSAGE: message};
    notifyListeners();
  }

  void addListeners(Function(Map<String, dynamic>) listener,
      {bool remove = false}) {
    if (remove) {
      callbacks.remove(listener);
    } else if (!callbacks.contains(listener)) {
      callbacks.add(listener);
    }
  }

  void setSelectedPayloadData(url, headers, body, token) {
    _selectedPayloadData = {
      URL: url,
      HEADERS: headers,
      BODY: body,
      TOKEN: token
    };
    if (callbacks.isNotEmpty) {
      for (var callback in callbacks) {
        callback(_selectedPayloadData);
      }
    }
    notifyListeners();
  }

  void setConfigFileLoaded(bool isLoaded) {
    isConfigFileLoaded = isLoaded;
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
