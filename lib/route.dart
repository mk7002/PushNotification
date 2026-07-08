import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pushapp/storage/SharedPrefs.dart';
import 'package:pushapp/ui/android/android_screen.dart';
import 'package:pushapp/ui/home/home_screen.dart';
import 'package:pushapp/ui/iOS/ios_screen.dart';
import 'package:pushapp/ui/profile/profile_screen.dart';
import 'package:pushapp/ui/profile/profile_loader_screen.dart';

final GoRouter globalRouter = GoRouter(
  initialLocation: '/',
  redirect: (context, state) {
    final path = state.uri.path;

    // If navigating to /android or /ios directly without an active profile,
    // redirect to the profile selection screen.
    if (path == '/android' && SharedPrefs.activeProfileId == null) {
      return '/android/profiles';
    }
    if (path == '/ios' && SharedPrefs.activeProfileId == null) {
      return '/ios/profiles';
    }

    return null;
  },
  routes: <RouteBase>[
    GoRoute(
      name: "home",
      path: '/',
      builder: (BuildContext context, GoRouterState state) {
        return const HomeScreen();
      },
    ),
    GoRoute(
      name: 'android-profiles',
      path: '/android/profiles',
      builder: (context, state) =>
          const ProfileScreen(platform: 'android'),
    ),
    GoRoute(
      name: 'android-profile-direct',
      path: '/android/profiles/:profileId',
      builder: (context, state) {
        final profileId = state.pathParameters['profileId']!;
        return ProfileLoaderScreen(
          profileId: profileId,
          platform: 'android',
        );
      },
    ),
    GoRoute(
      name: 'ios-profiles',
      path: '/ios/profiles',
      builder: (context, state) =>
          const ProfileScreen(platform: 'ios'),
    ),
    GoRoute(
      name: 'ios-profile-direct',
      path: '/ios/profiles/:profileId',
      builder: (context, state) {
        final profileId = state.pathParameters['profileId']!;
        return ProfileLoaderScreen(
          profileId: profileId,
          platform: 'ios',
        );
      },
    ),
    GoRoute(
      name: 'android',
      path: '/android',
      builder: (context, state) => const AndroidScreen(),
    ),
    GoRoute(
      name: 'ios',
      path: '/ios',
      builder: (context, state) => const iOSScreen(),
    ),
  ],
);
