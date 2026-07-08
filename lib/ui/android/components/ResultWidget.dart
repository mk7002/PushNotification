import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pushapp/extension/AppExtension.dart';
import 'package:pushapp/provider/android_provider.dart';
import 'package:pushapp/provider/ios_provider.dart';

import '../../res/strings.dart';

class ResultWidget extends StatefulWidget {
  final bool isAndroid;

  const ResultWidget({super.key, this.isAndroid = true});

  @override
  State<ResultWidget> createState() => _ResultWidgetState();
}

class _ResultWidgetState extends State<ResultWidget> {
  @override
  Widget build(BuildContext context) {
    return widget.isAndroid
        ? Consumer<AndroidProvider>(builder: (context, appProvider, child) {
            return _buildResultContainer(appProvider.result);
          })
        : Consumer<IosPlatformProvider>(builder: (context, appProvider, child) {
            return _buildResultContainer(appProvider.result);
          });
  }

  Widget _buildResultContainer(Map<String, dynamic> result) {
    final type = result[Strings.TYPE] as ResultType;
    final message = result.showResult();

    Color statusColor;
    IconData icon;
    String statusLabel;

    switch (type) {
      case ResultType.success:
        statusColor = const Color(0xFFA6E3A1);
        icon = Icons.check_circle_outline_rounded;
        statusLabel = "SUCCESS";
        break;
      case ResultType.error:
        statusColor = const Color(0xFFF38BA8);
        icon = Icons.error_outline_rounded;
        statusLabel = "ERROR";
        break;
      case ResultType.inProgress:
        statusColor = const Color(0xFF89B4FA);
        icon = Icons.sync_rounded;
        statusLabel = "SENDING";
        break;
      case ResultType.neutral:
      default:
        statusColor = const Color(0xFF6C7086);
        icon = Icons.terminal_rounded;
        statusLabel = "CONSOLE";
        break;
    }

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E2E),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFF313244)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Terminal header bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: const BoxDecoration(
              color: Color(0xFF181825),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(9),
                topRight: Radius.circular(9),
              ),
            ),
            child: Row(
              children: [
                // Traffic light dots
                Row(
                  children: [
                    _dot(const Color(0xFFF38BA8)),
                    const SizedBox(width: 5),
                    _dot(const Color(0xFFF9E2AF)),
                    const SizedBox(width: 5),
                    _dot(const Color(0xFFA6E3A1)),
                  ],
                ),
                const SizedBox(width: 12),
                Icon(icon, size: 12, color: statusColor),
                const SizedBox(width: 5),
                Text(
                  statusLabel,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: statusColor,
                    letterSpacing: 0.8,
                  ),
                ),
              ],
            ),
          ),
          // Response body
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: SingleChildScrollView(
                child: SelectableText(
                  message,
                  style: TextStyle(
                    fontSize: 12,
                    fontFamily: 'monospace',
                    color: statusColor,
                    height: 1.5,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _dot(Color color) {
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }
}
