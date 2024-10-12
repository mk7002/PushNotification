import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:pushapp/Singleton/Singleton.dart';
import 'package:pushapp/provider/AppProvider.dart';
import 'package:pushapp/push/AccessTokenManager.dart';

class PushHelper {
  PushHelper._internal();

  static final PushHelper _instance = PushHelper._internal();

  factory PushHelper() {
    return _instance;
  }

  Future<String> getAccessToken() async {
    return await AccessTokenManager().getAccessToken();
  }

  Future<void> sendFCMMessage(String? accessToken, String url, String fcmToken,
      Map<String, dynamic> messageBody, Map<String, String> headers) async {
    Singleton().provider.setResult(ResultType.inProgress, "Sending...");
    accessToken ??= await PushHelper().getAccessToken();
    print("Access Token $accessToken");
    final String serverKey = accessToken; // Your FCM server key
    String fcmEndpoint = url;

    final currentFCMToken = fcmToken;

    final Map<String, dynamic> message = messageBody;

    if (!headers.containsKey("Content-Type")) {
      headers["Content-Type"] = "application/json";
    }
    if (!headers.containsKey("Authorization")) {
      headers["Authorization"] = "Bearer $serverKey";
    }
    if (messageBody.containsKey("message") &&
        !(messageBody["message"] as Map<String, dynamic>)
            .containsKey("token")) {
      messageBody["message"]["token"] = currentFCMToken;
    }

    final http.Response response = await http.post(
      Uri.parse(fcmEndpoint),
      headers: headers,
      body: jsonEncode(message),
    );

    if (response.statusCode == 200) {
      Singleton().provider.setResult(ResultType.success, response.body);
    } else {
      Singleton().provider.setResult(ResultType.error, response.body);
    }
  }
}
