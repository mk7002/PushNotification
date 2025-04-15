import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:pushapp/Singleton/Singleton.dart';
import 'package:pushapp/provider/android_provider.dart';
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

  Future<void> sendFCMMessage(
    String? accessToken,
    String url,
    String fcmToken,
    Map<String, dynamic> messageBody,
    Map<String, dynamic> headers,
  ) async {
    Singleton().provider.setResult(ResultType.inProgress, "Sending...");

    accessToken ??= await PushHelper().getAccessToken();
    print("Access Token $accessToken");

    final String serverKey = accessToken;
    final String fcmEndpoint = url;
    final String currentFCMToken = fcmToken;

    // Safely build headers
    final Map<String, String> safeHeaders = {};
    headers.forEach((key, value) {
      final trimmedKey = key.trim();
      final trimmedValue = value.trim();

      final bool isValidKey =
          RegExp(r"^[\w!#$%&\'*+\-.^`|~]+$").hasMatch(trimmedKey);
      if (isValidKey) {
        safeHeaders[trimmedKey] = trimmedValue;
      } else {
        print("⚠️ Invalid header key ignored: $trimmedKey");
      }
    });

    // Ensure required headers
    safeHeaders.putIfAbsent("Content-Type", () => "application/json");
    safeHeaders.putIfAbsent("Authorization", () => "Bearer $serverKey");

    // Add the token to message
    messageBody["message"]["token"] = currentFCMToken;

    try {
      final http.Response response = await http.post(
        Uri.parse(fcmEndpoint),
        headers: safeHeaders,
        body: jsonEncode(messageBody),
      );

      if (response.statusCode == 200) {
        Singleton().provider.setResult(ResultType.success, response.body);
      } else {
        Singleton().provider.setResult(ResultType.error, response.body);
      }
    } catch (e) {
      Singleton().provider.setResult(ResultType.error, e.toString());
      print("❌ Exception while sending: $e");
    }
  }
}
