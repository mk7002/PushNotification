import 'package:flutter/material.dart';

/// A modern collapsible/expandable section widget with smooth animations.
class CollapsibleSection extends StatefulWidget {
  final String title;
  final String? subtitle;
  final Widget child;
  final bool initiallyExpanded;
  final IconData? leadingIcon;
  final Color? accentColor;
  final EdgeInsetsGeometry? contentPadding;

  const CollapsibleSection({
    super.key,
    required this.title,
    this.subtitle,
    required this.child,
    this.initiallyExpanded = true,
    this.leadingIcon,
    this.accentColor,
    this.contentPadding,
  });

  @override
  State<CollapsibleSection> createState() => _CollapsibleSectionState();
}

class _CollapsibleSectionState extends State<CollapsibleSection>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _expandAnimation;
  late Animation<double> _rotateAnimation;
  late bool _isExpanded;

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.initiallyExpanded;
    _controller = AnimationController(
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );
    _expandAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
    _rotateAnimation = Tween<double>(begin: 0, end: 0.5).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    if (_isExpanded) {
      _controller.value = 1.0;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final accentColor =
        widget.accentColor ?? Theme.of(context).colorScheme.primary;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: _isExpanded
              ? accentColor.withOpacity(0.2)
              : const Color(0xFFE8E8E8),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          InkWell(
            onTap: _toggle,
            borderRadius: BorderRadius.circular(14),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
              child: Row(
                children: [
                  if (widget.leadingIcon != null) ...[
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: accentColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        widget.leadingIcon,
                        size: 18,
                        color: accentColor,
                      ),
                    ),
                    const SizedBox(width: 12),
                  ],
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.title,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            letterSpacing: -0.2,
                          ),
                        ),
                        if (widget.subtitle != null) ...[
                          const SizedBox(height: 2),
                          Text(
                            widget.subtitle!,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  RotationTransition(
                    turns: _rotateAnimation,
                    child: Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Content
          SizeTransition(
            sizeFactor: _expandAnimation,
            child: Padding(
              padding: widget.contentPadding ??
                  const EdgeInsets.fromLTRB(18, 0, 18, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Divider(color: Colors.grey[200], height: 1),
                  const SizedBox(height: 14),
                  widget.child,
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
