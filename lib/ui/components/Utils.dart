import 'package:flutter/material.dart';

class Utils {
  InputDecoration getInputDecoration({String? labelText, String? hintText}) {
    return InputDecoration(
      labelText: labelText,
      hintText: hintText,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0), // Rounded corners
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius:
            BorderRadius.circular(12.0), // Rounded corners when not focused
        borderSide: const BorderSide(
          color: Colors.grey, // Border color when not focused
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius:
            BorderRadius.circular(12.0), // Rounded corners when focused
        borderSide: const BorderSide(
          color: Colors.blue, // Border color when focused
        ),
      ),
    );
  }
}
