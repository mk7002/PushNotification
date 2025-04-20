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

    return InkWell(
      onTap: () {
        onSelected(index);
      },
      child: Container(
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : COLOR_BORDER_INNER,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            width: isSelected ? 2 : 1,
            color: isSelected ? COLOR_ANDROID_GREEN : COLOR_BORDER,
          ),
        ),
        padding: const EdgeInsets.all(10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Text(
                data["name"] ?? "",
                style: const TextStyle(
                  fontWeight: FontWeight.w400,
                  color: Colors.black,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (!isDefaultPayload)
              IconButton(
                icon: const Icon(Icons.delete,
                    size: 16, color: Color(0xff757473)),
                onPressed: () {
                  onDeleted(index);
                },
              ),
          ],
        ),
      ),
    );
  }
}
