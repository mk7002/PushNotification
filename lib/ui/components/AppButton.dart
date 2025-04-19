import 'package:flutter/material.dart';
import 'package:pushapp/ui/res/colors.dart';

class Appbutton extends StatelessWidget {
  const Appbutton({super.key});

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}

class ConfigButton extends StatelessWidget {
  final String label;
  VoidCallback? onPressed;
  VoidCallback? onInfoPressed;

  ConfigButton(
      {super.key,
      this.label = "Import Configuration",
      this.onPressed,
      this.onInfoPressed});

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      style: OutlinedButton.styleFrom(
        backgroundColor: COLOR_BORDER_INNER,
        side: const BorderSide(
          color: COLOR_BORDER,
          width: 1,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8), // or 8.br if using extension
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      ),
      onPressed: onPressed,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        mainAxisSize: MainAxisSize.max,
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          GestureDetector(
            onTap: onInfoPressed,
            child: const Icon(
              Icons.info_outline,
              size: 20,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}
