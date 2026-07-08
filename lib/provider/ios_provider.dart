import 'package:flutter/material.dart';
import 'package:pushapp/push/AccessTokenManager.dart';
import 'package:pushapp/push/PushHelper.dart';
import 'package:pushapp/storage/SharedPrefs.dart';

import '../ui/res/strings.dart';
import 'android_provider.dart';

class IosPlatformProvider with ChangeNotifier {
  List<Map<String, dynamic>> _payloadList = [];

  List<Map<String, dynamic>> get payloadList => _payloadList;

  Map<String, dynamic> get result => _result;
  Map<String, dynamic> _result = {
    Strings.TYPE: ResultType.neutral,
    Strings.MESSAGE: "No Result"
  };

  String? privateKeyContent;
  String teamId = "";
  String keyId = "";
  String fileName = "";
  String bundleId = "";

  List<void Function(Map<String, dynamic>)> callbacks = [];

  void setResult(ResultType type, String message) {
    _result = {Strings.TYPE: type, Strings.MESSAGE: message};
    notifyListeners();
  }

  Future<void> loadData() async {
    var p8 = await SharedPrefs().configData(isAndroid: false);
    if (p8 != null) {
      setP8FileData(p8, isLoad: true);
      saveTemplatePayload(p8, isLoad: true);
      saveTeamData(p8, isLoad: true);
    } else {
      setPayloadList(_getDefaultIosPayload());
    }
    var payloadList = SharedPrefs().templatePayloads(isAndroid: false);

    setPayloadList(payloadList);
  }

  Future<void> saveTeamData(Map<String, dynamic> teamData,
      {bool isLoad = false}) async {
    var data = await SharedPrefs().configData(isAndroid: false);
    teamId = teamData["teamId"] ?? "";
    keyId = teamData["keyId"] ?? "";
    bundleId = teamData["bundleId"] ?? "";
    data ??= {};
    data.addAll(teamData);
    if (!isLoad) SharedPrefs().configData(data: data, isAndroid: false);
    notifyListeners();
  }

  Future<void> setP8FileData(Map<String, dynamic> data,
      {bool isLoad = false}) async {
    var oldData = await SharedPrefs().configData(isAndroid: false);
    privateKeyContent = data["content"];
    fileName = data["fileName"];
    oldData ??= {};
    oldData.addAll(data);
    if (!isLoad) SharedPrefs().configData(data: oldData, isAndroid: false);
    notifyListeners();
  }

  Future<void> sendPush(Map<String, dynamic> data) async {
    var token = await AccessTokenManager().generateJwtToken();
    print("data $bundleId $data");

    if (token != null) {
      final rawHeaders = data["headers"];
      final Map<String, String> castedHeaders = {};
      castedHeaders["apns-push-type"] = data["push_type"];
      if (rawHeaders is Map) {
        rawHeaders.forEach((key, value) {
          if (key is String && value is String) {
            castedHeaders[key] = value;
          } else if (key is String && value != null) {
            castedHeaders[key] = value.toString(); // fallback
          }
        });
      }

      await PushHelper().sendApnsNotification(
        jwtToken: token,
        deviceToken: data["token"],
        bundleId: bundleId,
        headers: castedHeaders.isNotEmpty ? castedHeaders : null,
        environment: data["environment"],
        payload: data["body"],
      );
    }
  }

  void setPayloadList(List<Map<String, dynamic>>? list) {
    try {
      if (list != null) {
        _payloadList = list;
        SharedPrefs().templatePayloads(payloads: list, isAndroid: false);
        notifyListeners();
      }
    } catch (e) {
      print(e);
    }
  }

  void saveTemplatePayload(Map<String, dynamic> _newPayload,
      {bool isLoad = false}) {
    var oldPayload = _payloadList;
    oldPayload.add(_newPayload);
    _payloadList = oldPayload;
    if (!isLoad)
      SharedPrefs().templatePayloads(payloads: _payloadList, isAndroid: false);
    notifyListeners();
  }

  List<Map<String, dynamic>> _getDefaultIosPayload() {
    return [
      {
        "name": "Sample Payload 1",
        "isDefaultPayload": true,
        "headers": {},
        "token": "token123",
        "apn_server": "sandbox",
        "push_type": "alert",
        "body": {
          "aps": {
            "alert": {"title": "Custom Title 11", "body": "Custom Body"},
            "sound": "ping.aiff"
          },
          "customKey": "customValue"
        }
      },
      {
        "name": "Sample Payload 2",
        "isDefaultPayload": true,
        "apn_server": "production",
        "push_type": "alert",
        "headers": {},
        "token": "token",
        "body": {
          "aps": {
            "alert": {"title": "Custom Title 22", "body": "Custom Body"},
          }
        }
      }
    ];
  }

  void deleteTemplatePayload(int index, Map<String, dynamic> payloadToDelete) {
    bool? isAdmin = payloadToDelete["isDefaultPayload"];
    if (isAdmin != null && isAdmin) return;
    try {
      // Get current list
      final currentPayloads = _payloadList;
      currentPayloads.removeAt(index);

      // Update the shared instance and shared preferences
      _payloadList = currentPayloads;
      SharedPrefs().templatePayloads(payloads: _payloadList, isAndroid: false);
      notifyListeners();
    } catch (e) {
      print("error $e");
    }
  }

  void onPayloadSelected(Map<String, dynamic> selectedPayload) {
    var selectedPayloadData = {
      Strings.HEADERS: selectedPayload[Strings.HEADERS],
      Strings.BODY: selectedPayload[Strings.BODY],
      Strings.TOKEN: selectedPayload[Strings.TOKEN],
      Strings.APN_SERVER: selectedPayload[Strings.APN_SERVER],
      Strings.PUSH_TYPE: selectedPayload[Strings.PUSH_TYPE],
    };
    if (callbacks.isNotEmpty) {
      for (var callback in callbacks) {
        callback(selectedPayloadData);
      }
    }
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

  @override
  void dispose() {
    callbacks.clear();
    super.dispose();
  }
}
