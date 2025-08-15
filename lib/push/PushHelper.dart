import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:http2/http2.dart';
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

    if (kIsWeb) {
      handleForWeb(url, bodyData);
    } else {
      handleForApp(bodyData);
    }
  }

  Future<void> handleForWeb(url, bodyData) async {
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

  Future<void> handleForApp(Map<String, dynamic> json) async {
    final jwtToken = json['jwtToken'] as String?;
    final deviceToken = json['deviceToken'] as String?;
    final bundleId = json['bundleId'] as String?;
    final environment =
        (json['environment'] as String?)?.toLowerCase() ?? 'sandbox';
    final payload = json['payload'] as Map<String, dynamic>?;
    final customHeaders = (json['headers'] as Map?)?.map(
      (key, value) => MapEntry(key.toString(), value.toString()),
    );

    if (jwtToken == null || deviceToken == null || bundleId == null) {
      debugPrint('❌ Missing required fields: jwtToken, deviceToken, bundleId');
      AppProvider()
          .iosProvider
          .setResult(ResultType.error, "Missing required fields");
      return;
    }

    final host = environment == 'production'
        ? 'api.push.apple.com'
        : 'api.sandbox.push.apple.com';

    final notificationPayload = payload ??
        {
          'aps': {
            'alert': {'title': 'Hello!', 'body': 'This is a test notification'},
            'sound': 'default',
          },
        };

    final headers = <Header>[
      Header.ascii(':method', 'POST'),
      Header.ascii(':path', '/3/device/$deviceToken'),
      Header.ascii('content-type', 'application/json'),
      Header.ascii('authorization', 'bearer $jwtToken'),
      Header.ascii('apns-topic', bundleId),
    ];

    if (customHeaders != null && customHeaders.isNotEmpty) {
      customHeaders.forEach((key, value) {
        headers.add(Header.ascii(key, value));
      });
    }

    final hasPushType = headers.any(
      (h) => utf8.decode(h.name).toLowerCase() == 'apns-push-type',
    );
    if (!hasPushType) {
      headers.add(Header.ascii('apns-push-type', 'alert'));
    }

    SecureSocket? secureSocket;
    ClientTransportConnection? connection;
    bool sendFailed = false;

    try {
      secureSocket = await SecureSocket.connect(
        host,
        443,
        supportedProtocols: ['h2'],
      );

      connection = ClientTransportConnection.viaSocket(secureSocket);

      final stream = connection.makeRequest(headers, endStream: false);
      stream.outgoingMessages.add(
        DataStreamMessage(utf8.encode(jsonEncode(notificationPayload))),
      );
      stream.outgoingMessages.add(DataStreamMessage([], endStream: true));

      stream.incomingMessages.listen(
        (message) {
          if (message is HeadersStreamMessage) {
            for (final header in message.headers) {
              debugPrint(
                  '${utf8.decode(header.name)}: ${utf8.decode(header.value)}');
            }
          } else if (message is DataStreamMessage) {
            final body = utf8.decode(message.bytes);
            debugPrint("📩 APNs Response Body: $body");

            try {
              final decoded = jsonDecode(body);
              if (decoded is Map && decoded.containsKey("reason")) {
                final reason = decoded["reason"].toString();
                sendFailed = true;
                AppProvider().iosProvider.setResult(ResultType.error, reason);
              } else {
                AppProvider().iosProvider.setResult(ResultType.success, body);
              }
            } catch (_) {
              // Non-JSON or empty response
              AppProvider().iosProvider.setResult(ResultType.success, body);
            }
          }
        },
        onDone: () {
          if (!sendFailed) {
            debugPrint("✅ Push sent successfully");
            AppProvider().iosProvider.setResult(ResultType.success, "Send");
          }
        },
        onError: (err) {
          debugPrint("❌ Stream Error: $err");
          sendFailed = true;
          AppProvider().iosProvider.setResult(ResultType.error, err.toString());
        },
      );
    } catch (e, st) {
      debugPrint("❌ Exception: $e");
      debugPrint(st.toString());
      sendFailed = true;
      AppProvider().iosProvider.setResult(ResultType.error, e.toString());
    } finally {
      connection?.finish();
      secureSocket?.destroy();
    }
  }
}
