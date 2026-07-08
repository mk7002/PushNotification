import 'package:flutter/material.dart';

/// A TextFormField styled like a code editor with dark theme,
/// monospace font, and syntax-like appearance.
class CodeEditorField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final int minLines;
  final String? Function(String?)? validator;

  const CodeEditorField({
    super.key,
    required this.controller,
    required this.label,
    this.hint = '',
    this.minLines = 6,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label
        Padding(
          padding: const EdgeInsets.only(bottom: 6, left: 2),
          child: Row(
            children: [
              Icon(Icons.code_rounded, size: 14, color: Colors.grey[500]),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[600],
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
        ),
        // Code field
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFF1E1E2E),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFF313244)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: TextFormField(
              controller: controller,
              keyboardType: TextInputType.multiline,
              maxLines: null,
              minLines: minLines,
              style: const TextStyle(
                fontFamily: 'monospace',
                fontSize: 13,
                color: Color(0xFFCDD6F4),
                height: 1.5,
              ),
              cursorColor: const Color(0xFF89B4FA),
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 13,
                  color: const Color(0xFF6C7086),
                ),
                filled: true,
                fillColor: const Color(0xFF1E1E2E),
                contentPadding: const EdgeInsets.all(14),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Color(0xFFF38BA8)),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Color(0xFFF38BA8)),
                ),
                errorStyle: const TextStyle(
                  color: Color(0xFFF38BA8),
                  fontSize: 11,
                ),
              ),
              validator: validator,
            ),
          ),
        ),
      ],
    );
  }
}
