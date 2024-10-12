import 'dart:convert';

import 'package:pushapp/Singleton/Singleton.dart';
import 'package:pushapp/extension/AppExtension.dart';

import '../storage/SharedPrefs.dart';

class DataHandler {
  DataHandler._internal();

  static final DataHandler _instance = DataHandler._internal();

  factory DataHandler() {
    return _instance;
  }

  Map<String, dynamic> appConfig = {};
  String? _url;
  String? _headers;
  String? _body;

  void init() {
    var data = SharedPrefs().getConfigData();
    if (data != null) {
      appConfig = data;
    }
  }

  T? getAppConfigData<T>(AppConfigType type) {
    var data = appConfig[type.name];
    if (data != null) {
      if (T == List<Map<String, dynamic>>) {
        // Handle list of maps, e.g., List<Map<String, dynamic>>
        return (data as List<dynamic>)
            .map((item) => item as Map<String, dynamic>)
            .toList() as T;
      } else if (T == List<String>) {
        // Handle list of strings
        return data.cast<String>() as T;
      } else if (data is Map<String, dynamic>) {
        // Handle map data types
        return data as T?;
      } else if (T == Map<String, String>) {
        // Handle map data types

        return (data as Map<String, dynamic>)
                .map((key, value) => MapEntry(key as String, value.toString()))
            as T;
      } else {
        // Handle other types
        return data as T?;
      }
    }
    return null;
  }

  void setAppConfig(Map<String, dynamic> data) {
    appConfig = data;
    SharedPrefs().setConfigData(appConfig);
  }

  void setUrl(String url) {
    _url = url;
  }

  String getUrl() {
    _url =
        "https://fcm.googleapis.com/v1/projects/${appConfig.getProjectId()}/messages:send";
    return _url!;
  }

  void setHeaders(headers) {
    _headers = jsonEncode(headers);
  }

  dynamic getHeaders() {
    if (_headers == null) return {};
    return jsonDecode(_headers!);
  }

  void setBody(body) {
    _body = jsonEncode(body);
  }

  dynamic getBody() {
    if (_body == null) return {};
    return jsonDecode(_body!);
  }

  void passDataToUi() {
    Singleton().provider.setSelectedPayloadData(_url, _headers, _body);
  }
}

enum AppConfigType { serviceAccountJson, scopes, project_id, payloads }
