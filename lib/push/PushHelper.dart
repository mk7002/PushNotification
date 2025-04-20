import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:pushapp/Singleton/app_provider.dart';
import 'package:pushapp/provider/android_provider.dart';
import 'package:pushapp/push/AccessTokenManager.dart';

class PushHelper {
  PushHelper._internal();

  static final PushHelper _instance = PushHelper._internal();

  factory PushHelper() {
    return _instance;
  }

  Future<String> getAccessToken() async {
    return await AccessTokenManager().getAndroidAccessToken();
  }

  Future<void> sendFCMMessage(
    String? accessToken,
    String url,
    String fcmToken,
    Map<String, dynamic> messageBody,
    Map<String, dynamic> headers,
  ) async {
    AppProvider()
        .androidProvider
        .setResult(ResultType.inProgress, "Sending...");

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
        AppProvider()
            .androidProvider
            .setResult(ResultType.success, response.body);
      } else {
        AppProvider()
            .androidProvider
            .setResult(ResultType.error, response.body);
      }
    } catch (e) {
      AppProvider().androidProvider.setResult(ResultType.error, e.toString());
      print("❌ Exception while sending: $e");
    }
  }

  /// Sends a push notification via your Render APNs proxy
  Future<void> sendApnsNotification({
    required String jwtToken,
    required String deviceToken,
    required String bundleId,
    String environment = 'sandbox',

    // Optional simple payload
    String? title,
    String? body,
    String? sound,

    // Full custom payload (overrides title/body/sound)
    Map<String, dynamic>? payload,

    // Optional extra APNs headers
    Map<String, String>? headers,
  }) async {
    AppProvider().iosProvider.setResult(ResultType.inProgress, "Sending...");

    final url = Uri.parse('https://apns-server-yunz.onrender.com/send');

    // If a full payload is not provided, build a basic one
    final effectivePayload = payload ??
        {
          "aps": {
            "alert": {
              "title": title ?? "Hello!",
              "body": body ?? "This is a test notification",
            },
            "sound": sound ?? "default"
          }
        };

    // Build request body
    final bodyData = {
      'jwtToken': jwtToken,
      'deviceToken': deviceToken,
      'bundleId': bundleId,
      'environment': environment,
      'payload': effectivePayload,
    };

    // Only include headers if provided
    if (headers != null && headers.isNotEmpty) {
      bodyData['headers'] = headers;
    }

    AppProvider().iosProvider.setResult(ResultType.inProgress, "Loading...");

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(bodyData),
      );

      if (response.statusCode == 200) {
        AppProvider().iosProvider.setResult(ResultType.success, response.body);
        print('✅ Notification sent successfully!');
        print(response.body);
      } else {
        AppProvider().iosProvider.setResult(ResultType.error, response.body);
        print('❌ Failed to send notification: ${response.statusCode}');
        print(response.body);
      }
    } catch (e) {
      print('❌ Error sending request: $e');
      AppProvider().iosProvider.setResult(ResultType.error, "catch : $e");
    }
  }
}
