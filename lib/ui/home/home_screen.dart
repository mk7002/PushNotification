import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pushapp/ui/components/Utils.dart';
import 'package:pushapp/ui/res/colors.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _hoveredIndex = -1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 900),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // App Title
                const Icon(
                  Icons.notifications_active_rounded,
                  size: 56,
                  color: COLOR_ANDROID_GREEN,
                ),
                const SizedBox(height: 16),
                Text(
                  "Notify Now",
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Send test push notifications to your devices",
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Colors.grey[600],
                      ),
                ),
                const SizedBox(height: 48),

                // Platform Cards
                Row(
                  children: [
                    Expanded(
                      child: _PlatformCard(
                        index: 0,
                        isHovered: _hoveredIndex == 0,
                        onHover: (hovered) =>
                            setState(() => _hoveredIndex = hovered ? 0 : -1),
                        onTap: () {
                          if (kIsWeb)
                            context.go("/android/profiles");
                          else
                            context.push("/android/profiles");
                        },
                        icon: Icons.android_rounded,
                        title: "Android",
                        subtitle: "Firebase Cloud Messaging",
                        color: COLOR_ANDROID_GREEN,
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Color(0xFF3DDC84), Color(0xFF2BC46A)],
                        ),
                      ),
                    ),
                    const SizedBox(width: 24),
                    Expanded(
                      child: _PlatformCard(
                        index: 1,
                        isHovered: _hoveredIndex == 1,
                        onHover: (hovered) =>
                            setState(() => _hoveredIndex = hovered ? 1 : -1),
                        onTap: () {
                          if (kIsWeb)
                            context.go("/ios/profiles");
                          else
                            context.push("/ios/profiles");
                        },
                        icon: Icons.apple_rounded,
                        title: "iOS",
                        subtitle: "Apple Push Notification Service",
                        color: const Color(0xFF007AFF),
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Color(0xFF007AFF), Color(0xFF5856D6)],
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 40),
                Text(
                  "Version ${Utils.versionCode}",
                  style: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PlatformCard extends StatelessWidget {
  final int index;
  final bool isHovered;
  final ValueChanged<bool> onHover;
  final VoidCallback onTap;
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final Gradient gradient;

  const _PlatformCard({
    required this.index,
    required this.isHovered,
    required this.onHover,
    required this.onTap,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => onHover(true),
      onExit: (_) => onHover(false),
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          transform: Matrix4.identity()..scale(isHovered ? 1.03 : 1.0),
          transformAlignment: Alignment.center,
          height: 220,
          decoration: BoxDecoration(
            gradient: gradient,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(isHovered ? 0.4 : 0.2),
                blurRadius: isHovered ? 24 : 12,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Stack(
            children: [
              // Background decoration
              Positioned(
                right: -20,
                bottom: -20,
                child: Icon(
                  icon,
                  size: 140,
                  color: Colors.white.withOpacity(0.1),
                ),
              ),
              // Content
              Padding(
                padding: const EdgeInsets.all(28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Icon(icon, size: 44, color: Colors.white),
                    const SizedBox(height: 16),
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
