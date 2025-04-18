import 'package:flutter/material.dart';

import 'Utils.dart';

class HeaderNameWidget extends StatelessWidget {
  String label;
  Widget child;

  HeaderNameWidget({super.key, required this.label, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: Utils().shadow(),
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Utils.textStyleBold(size: 18),
          ),
          const SizedBox(
            height: 10,
          ),
          child
        ],
      ),
    );
  }
}
