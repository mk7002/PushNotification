import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:pushapp/provider/profile_provider.dart';
import 'package:pushapp/storage/SharedPrefs.dart';
import 'package:pushapp/ui/android/android_screen.dart';
import 'package:pushapp/ui/iOS/ios_screen.dart';

/// This screen handles deep links like /android/profiles/:profileId
/// It loads the profile, activates it, and shows the platform tool directly.
/// If the profile doesn't exist, it shows an error with a link to profiles list.
class ProfileLoaderScreen extends StatefulWidget {
  final String profileId;
  final String platform;

  const ProfileLoaderScreen({
    super.key,
    required this.profileId,
    required this.platform,
  });

  @override
  State<ProfileLoaderScreen> createState() => _ProfileLoaderScreenState();
}

class _ProfileLoaderScreenState extends State<ProfileLoaderScreen> {
  bool _loading = true;
  bool _notFound = false;

  @override
  void initState() {
    super.initState();
    _loadAndActivate();
  }

  Future<void> _loadAndActivate() async {
    final provider = context.read<ProfileProvider>();
    final success = await provider.activateProfileById(widget.profileId);

    if (!mounted) return;

    if (success) {
      SharedPrefs.activeProfileId = widget.profileId;
      setState(() {
        _loading = false;
      });
    } else {
      setState(() {
        _loading = false;
        _notFound = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        backgroundColor: Color(0xFFF8F9FA),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text(
                "Loading profile...",
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),
      );
    }

    if (_notFound) {
      return Scaffold(
        backgroundColor: const Color(0xFFF8F9FA),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.person_off_rounded, size: 56, color: Colors.grey[300]),
              const SizedBox(height: 16),
              Text(
                "Profile not found",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "The profile \"${widget.profileId}\" doesn't exist.",
                style: TextStyle(fontSize: 13, color: Colors.grey[500]),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () {
                  context.go('/${widget.platform}/profiles');
                },
                icon: const Icon(Icons.arrow_back_rounded, size: 18),
                label: const Text("Go to Profiles"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: widget.platform == 'android'
                      ? const Color(0xFF3DDC84)
                      : const Color(0xFF007AFF),
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Profile loaded — show the platform tool directly at this URL
    if (widget.platform == 'android') {
      return const AndroidScreen();
    } else {
      return const iOSScreen();
    }
  }
}
