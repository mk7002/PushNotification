import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pushapp/ui/components/header_name_widget.dart';
import 'package:pushapp/ui/res/colors.dart';
import 'package:pushapp/ui/res/style_extensions.dart';

class ApnsServiceStatusWidget extends StatefulWidget {
  const ApnsServiceStatusWidget({Key? key}) : super(key: key);

  @override
  State<ApnsServiceStatusWidget> createState() =>
      _ApnsServiceStatusWidgetState();
}

class _ApnsServiceStatusWidgetState extends State<ApnsServiceStatusWidget> {
  String? _statusMessage;
  Color _statusColor = Colors.grey;
  bool _isChecking = false;
  bool _isServerRunning = false;

  @override
  void initState() {
    _checkServerStatus();
    super.initState();
  }

  Future<void> _checkServerStatus() async {
    setState(() {
      _isChecking = true;
      _statusMessage = null;
      _isServerRunning = false;
    });

    try {
      final response = await http
          .get(Uri.parse('https://apns-server-yunz.onrender.com/'))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        setState(() {
          _statusMessage = '✅ APNs Server is running!';
          _statusColor = Colors.green;
          _isServerRunning = true;
        });
      } else {
        setState(() {
          _statusMessage =
              '⚠️ Server responded with status ${response.statusCode}';
          _statusColor = Colors.orange;
          _isServerRunning = false;
        });
      }
    } catch (e) {
      setState(() {
        _statusMessage = '❌ Server is not reachable.\nError: $e';
        _statusColor = Colors.red;
        _isServerRunning = false;
      });
    } finally {
      setState(() => _isChecking = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return HeaderNameWidget(
      label: 'APNs Server Check',
      child: Container(
        child: Card(
          elevation: 6,
          shape: RoundedRectangleBorder(borderRadius: 10.br),
          margin: const EdgeInsets.all(10),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                const Icon(Icons.cloud_outlined,
                    size: 20, color: Colors.blueAccent),
                const SizedBox(width: 10),
                Text(
                  "APNs Server Status",
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(width: 10),

                // Show loading indicator
                if (_isChecking)
                  const CircularProgressIndicator()

                // Show retry button only if server is not running
                else if (!_isServerRunning)
                  ElevatedButton.icon(
                    onPressed: _checkServerStatus,
                    icon: const Icon(Icons.refresh),
                    label: const Text("Check Now"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: COLOR_ANDROID_GREEN,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 10),
                      textStyle: const TextStyle(fontSize: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),

                if (_statusMessage != null) ...[
                  const SizedBox(height: 20),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: _statusColor.withOpacity(0.1),
                      border: Border.all(color: _statusColor),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _statusMessage!,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: _statusColor,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/*
{
  "jwtToken": "YOUR_JWT_TOKEN",
  "deviceToken": "TARGET_DEVICE_TOKEN",
  "bundleId": "com.example.app",
  "environment": "sandbox", // or "production"
  "title": "Notification Title",
  "body": "Notification Body",
  "sound": "default",
  "headers": {
    "apns-push-type": "alert"
  }
}


{
  "jwtToken": "YOUR_JWT_TOKEN",
  "deviceToken": "TARGET_DEVICE_TOKEN",
  "bundleId": "com.example.app",
  "environment": "production",
  "payload": {
    "aps": {
      "alert": {
        "title": "Custom Title",
        "body": "Custom Body"
      },
      "sound": "ping.aiff"
    },
    "customKey": "customValue"
  }
}


 */
