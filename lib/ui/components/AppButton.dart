import 'package:flutter/material.dart';
import 'package:pushapp/ui/res/colors.dart';
import 'package:pushapp/ui/res/style_extensions.dart';

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

  ConfigButton({
    super.key,
    this.label = "Import Configuration",
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      style: OutlinedButton.styleFrom(
        backgroundColor: COLOR_BORDER_INNER,
        side: const BorderSide(
          color: COLOR_BORDER,
          // border color
          width: 1, // border width
        ),
        shape: RoundedRectangleBorder(
          borderRadius: 8.br, // rounded corners
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      ),
      onPressed: onPressed,
      child: Text(
        label,
        style: TextStyle(fontWeight: FontWeight.w500),
      ),
    );
  }
}
