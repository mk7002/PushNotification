import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

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
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: _statusColor, width: 1.2),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.all(12),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _isServerRunning
                  ? Icons.check_circle_outline
                  : Icons.cloud_off_outlined,
              color: _statusColor,
              size: 22,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                _statusMessage ?? "Checking...",
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: _statusColor,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            _isChecking
                ? const SizedBox(
                    height: 16,
                    width: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : IconButton(
                    icon: const Icon(Icons.refresh, size: 18),
                    onPressed: _checkServerStatus,
                    tooltip: "Refresh",
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
          ],
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
