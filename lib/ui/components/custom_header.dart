import 'package:flutter/material.dart';
import 'package:pushapp/ui/res/colors.dart';
import 'package:pushapp/ui/res/style_extensions.dart';

class CustomHeader extends StatelessWidget implements PreferredSizeWidget {
  const CustomHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(10),
      decoration:
          BoxDecoration(color: COLOR_ANDROID_GREEN, borderRadius: 20.br),
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.android_sharp,
                color: Colors.white,
                size: 40,
              ),
              SizedBox(
                width: 15,
              ),
              Text(
                "Android Push Tool",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          Text("send test push notificaitons using FCM")
        ],
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(100);
}
