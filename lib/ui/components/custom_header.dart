import 'package:flutter/material.dart';
import 'package:pushapp/ui/res/colors.dart';
import 'package:pushapp/ui/res/style_extensions.dart';

class CustomHeader extends StatelessWidget implements PreferredSizeWidget {
  String title;
  String desc;
  bool showIcon;

  CustomHeader(
      {super.key,
      required this.title,
      required this.desc,
      this.showIcon = true});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(10),
      decoration:
          BoxDecoration(color: COLOR_ANDROID_GREEN, borderRadius: 20.br),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              showIcon
                  ? const Icon(
                      Icons.android_sharp,
                      color: Colors.white,
                      size: 40,
                    )
                  : SizedBox(),
              const SizedBox(
                width: 15,
              ),
              Text(
                title,
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          Text(desc)
        ],
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(100);
}
