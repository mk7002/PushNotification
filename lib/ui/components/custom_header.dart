import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:pushapp/provider/profile_provider.dart';
import 'package:pushapp/ui/res/colors.dart';

class CustomHeader extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final String desc;
  final bool showIcon;
  final IconData? icon;
  final Gradient? gradient;
  final Color? shadowColor;

  const CustomHeader({
    super.key,
    required this.title,
    required this.desc,
    this.showIcon = true,
    this.icon,
    this.gradient,
    this.shadowColor,
  });

  @override
  Widget build(BuildContext context) {
    final profileProvider = context.watch<ProfileProvider>();
    final activeProfile = profileProvider.activeProfile;

    final effectiveGradient = gradient ??
        const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF3DDC84), Color(0xFF2BC46A)],
        );

    final effectiveShadowColor =
        shadowColor ?? COLOR_ANDROID_GREEN.withOpacity(0.3);

    return Container(
      margin: const EdgeInsets.fromLTRB(12, 8, 12, 4),
      decoration: BoxDecoration(
        gradient: effectiveGradient,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: effectiveShadowColor,
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          if (!kIsWeb)
            InkWell(
              onTap: () => context.pop(),
              borderRadius: BorderRadius.circular(12),
              child: const Padding(
                padding: EdgeInsets.all(16.0),
                child: Icon(
                  Icons.arrow_back_rounded,
                  color: Colors.white,
                ),
              ),
            ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(
                vertical: 10,
                horizontal: kIsWeb ? 20 : 0,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (showIcon)
                        Padding(
                          padding: const EdgeInsets.only(right: 10),
                          child: Icon(
                            icon ?? Icons.android_rounded,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                      Flexible(
                        child: Text(
                          title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            letterSpacing: -0.3,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  if (activeProfile != null) ...[
                    const SizedBox(height: 2),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        activeProfile.name,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Colors.white.withOpacity(0.95),
                        ),
                      ),
                    ),
                  ] else ...[
                    const SizedBox(height: 2),
                    Text(
                      desc,
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.white.withOpacity(0.85),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(80);
}
