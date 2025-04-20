import 'package:flutter/material.dart';

import '../ui/res/strings.dart';

class AndroidProvider with ChangeNotifier {
  Map<String, dynamic> _result = {
    Strings.TYPE: ResultType.neutral,
    Strings.MESSAGE: "No Result"
  };

  Map<String, dynamic> _selectedPayloadData = {};

  List<Map<String, dynamic>> _payloadList = [];
  List<Map<String, dynamic>> get payloadList => _payloadList;

  Map<String, dynamic> get selectedPayloadData => _selectedPayloadData;

  Map<String, dynamic> get result => _result;

  List<void Function(Map<String, dynamic>)> callbacks = [];

  bool isConfigFileLoaded = false;

  void setResult(ResultType type, String message) {
    _result = {Strings.TYPE: type, Strings.MESSAGE: message};
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
      Strings.URL: url,
      Strings.HEADERS: headers,
      Strings.BODY: body,
      Strings.TOKEN: token
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

  @override
  void dispose() {
    _result.clear();
    _selectedPayloadData.clear();
    _payloadList.clear();
    callbacks.clear();
    super.dispose();
  }
}

enum ResultType { neutral, success, error, inProgress }
