import 'package:flutter/material.dart';

import '../res/colors.dart';

class PayloadListTile extends StatelessWidget {
  final int index;
  final Map<String, dynamic> data;
  final int selectedIndex;
  final ValueChanged<int> onSelected;
  final ValueChanged<int> onDeleted;

  const PayloadListTile({
    Key? key,
    required this.index,
    required this.data,
    required this.selectedIndex,
    required this.onSelected,
    required this.onDeleted,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool isDefaultPayload = data["isDefaultPayload"] ?? false;
    final bool isSelected = selectedIndex == index;
    final payloadType = _getPayloadType();

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => onSelected(index),
        borderRadius: BorderRadius.circular(10),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          decoration: BoxDecoration(
            color: isSelected
                ? COLOR_ANDROID_GREEN.withOpacity(0.06)
                : const Color(0xFFF8F9FA),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              width: isSelected ? 1.5 : 1,
              color: isSelected ? COLOR_ANDROID_GREEN : const Color(0xFFE8E8E8),
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              // Type icon
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: isSelected
                      ? COLOR_ANDROID_GREEN.withOpacity(0.1)
                      : const Color(0xFFEEEEEE),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(
                  payloadType.icon,
                  size: 14,
                  color: isSelected ? COLOR_ANDROID_GREEN : Colors.grey[500],
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      data["name"] ?? "",
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.w400,
                        color: isSelected ? Colors.black87 : Colors.grey[700],
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      payloadType.label,
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.grey[400],
                      ),
                    ),
                  ],
                ),
              ),
              if (!isDefaultPayload)
                InkWell(
                  onTap: () => onDeleted(index),
                  borderRadius: BorderRadius.circular(6),
                  child: Padding(
                    padding: const EdgeInsets.all(4),
                    child: Icon(
                      Icons.close_rounded,
                      size: 14,
                      color: Colors.grey[400],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  _PayloadTypeInfo _getPayloadType() {
    final body = data["body"];
    if (body is Map) {
      // Android FCM
      if (body.containsKey("message")) {
        final message = body["message"];
        if (message is Map) {
          if (message.containsKey("notification")) {
            return _PayloadTypeInfo(Icons.notifications_rounded, "Notification");
          }
          if (message.containsKey("data")) {
            return _PayloadTypeInfo(Icons.data_object_rounded, "Data Message");
          }
        }
      }
      // iOS APNs
      if (body.containsKey("aps")) {
        final aps = body["aps"];
        if (aps is Map && aps.containsKey("alert")) {
          return _PayloadTypeInfo(Icons.notifications_rounded, "Alert");
        }
        return _PayloadTypeInfo(Icons.sync_rounded, "Background");
      }
    }
    return _PayloadTypeInfo(Icons.code_rounded, "Custom");
  }
}

class _PayloadTypeInfo {
  final IconData icon;
  final String label;

  const _PayloadTypeInfo(this.icon, this.label);
}
