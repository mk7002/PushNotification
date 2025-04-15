import 'package:pushapp/extension/AppExtension.dart';
import 'package:pushapp/ui/components/Utils.dart';

import '../Singleton/Singleton.dart';
import '../storage/SharedPrefs.dart';

class DataHandler {
  DataHandler._internal();

  static final DataHandler _instance = DataHandler._internal();

  factory DataHandler() {
    return _instance;
  }

  Map<String, dynamic> appConfig = {};
  List<Map<String, dynamic>> _androidTemplatePayload = [];
  String? _url;

  void init() {
    var data = SharedPrefs().getConfigData();
    if (data != null && data.getProjectId().isNotEmpty) {
      appConfig = data;
      Singleton().provider.setConfigFileLoaded(true);
    } else {
      if (data != null && data.isOldConfig()) {
        Utils().showMessage("Please load new config", error: true);
      } else
        Singleton().provider.setConfigFileLoaded(false);
    }
  }

  List<String> getFirebaseScopes() {
    return [
      "https://www.googleapis.com/auth/userinfo.email",
      "https://www.googleapis.com/auth/firebase.database",
      "https://www.googleapis.com/auth/firebase.messaging"
    ];
  }

  List<Map<String, dynamic>> getAndroidTemplatePayloads() {
    _androidTemplatePayload =
        SharedPrefs().updateOrGetAndroidTemplatePayloads() ??
            _getDefaultAndroidPayload();
    return _androidTemplatePayload;
  }

  void saveAndroidTemplatePayloadList(List<Map<String, dynamic>> _newList) {
    var oldPayload = getAndroidTemplatePayloads();
    oldPayload.addAll(_newList);
    _androidTemplatePayload = oldPayload;
    SharedPrefs()
        .updateOrGetAndroidTemplatePayloads(payloads: _androidTemplatePayload);
    Singleton()
        .provider
        .setPayloadList(DataHandler().getAndroidTemplatePayloads());
  }

  void saveAndroidTemplatePayload(Map<String, dynamic> _newPayload) {
    var oldPayload = getAndroidTemplatePayloads();
    oldPayload.add(_newPayload);
    _androidTemplatePayload = oldPayload;
    SharedPrefs()
        .updateOrGetAndroidTemplatePayloads(payloads: _androidTemplatePayload);
    Singleton()
        .provider
        .setPayloadList(DataHandler().getAndroidTemplatePayloads());
  }

  void deleteAndroidTemplatePayload(
      int index, Map<String, dynamic> payloadToDelete) {
    bool? isAdmin = payloadToDelete["isDefaultPayload"];
    if (isAdmin != null && isAdmin) return;
    try {
      // Get current list
      final currentPayloads = getAndroidTemplatePayloads();
      currentPayloads.removeAt(index);

      // Update the shared instance and shared preferences
      _androidTemplatePayload = currentPayloads;
      SharedPrefs().updateOrGetAndroidTemplatePayloads(
          payloads: _androidTemplatePayload);

      // Notify provider with updated list
      Singleton().provider.setPayloadList(_androidTemplatePayload);
    } catch (e) {
      print("error $e");
    }
  }

  List<Map<String, dynamic>> _getDefaultAndroidPayload() {
    return [
      {
        "name": "Sample Payload 1",
        "isDefaultPayload": true,
        "headers": {},
        "token": "token",
        "body": {
          "message": {
            "notification": {
              "title": "Portugal vs. Denmark",
              "body": "great match!"
            }
          }
        }
      },
      {
        "name": "Sample Payload 2",
        "isDefaultPayload": true,
        "headers": {},
        "token": "token",
        "body": {
          "message": {
            "data": {"title": "Portugal vs. Denmark", "body": "great match!"}
          }
        }
      }
    ];
  }

  T? getAppConfigData<T>() {
    return appConfig as T;
  }

  void setAppConfig(Map<String, dynamic> data) {
    appConfig = data;
    SharedPrefs().setConfigData(appConfig);
  }

  String getUrl() {
    _url =
        "https://fcm.googleapis.com/v1/projects/${appConfig.getProjectId()}/messages:send";
    return _url!;
  }
}

enum AppConfigType {
  project_id
//  serviceAccountJson, scopes, , payloads
}
