# Notify Now

A Flutter-based push notification testing tool for developers. Send test push notifications to Android (FCM) and iOS (APNs) devices from a single interface.

**Live:** https://notifynow.web.app/

## Features

- **Android FCM Push** — Send notifications via Firebase Cloud Messaging v1 API using service account credentials
- **iOS APNs Push** — Send notifications via Apple Push Notification service using JWT tokens (.p8 keys), supports sandbox and production
- **Template Payloads** — Create, save, select, and delete reusable notification payload templates
- **Multi-platform** — Runs as a web app (Firebase Hosting) and as a mobile app
- **Responsive UI** — Adapts layout for tablet and desktop screens
- **Persistent Config** — Saves service account configs, tokens, and templates locally

## Getting Started

### Prerequisites

- Flutter SDK (Dart ^3.5.3)
- A Firebase project with Cloud Messaging enabled (for Android)
- An Apple Developer account with a .p8 APNs key (for iOS)

### Installation

```bash
git clone <repository-url>
cd pn
flutter pub get
```

### Run

```bash
# Web
flutter run -d chrome

# Android
flutter run -d <android-device>

# iOS
flutter run -d <ios-device>
```

### Deploy (Web)

```bash
flutter build web
cd build/web
firebase deploy --only hosting:notifynow
```

## How It Works

### Android (FCM)

1. Load your Firebase service account JSON file
2. The app obtains an OAuth2 access token using the service account credentials
3. Select or create a notification payload template
4. Enter the target device FCM token
5. Send — the app posts to the FCM v1 API endpoint

### iOS (APNs)

1. Load your .p8 private key file
2. Enter your Team ID, Key ID, and Bundle ID
3. The app generates a JWT (ES256) for APNs authentication
4. Select or create a notification payload template
5. Enter the target device token and choose environment (sandbox/production)
6. Send — on mobile, uses HTTP/2 directly to APNs; on web, uses a proxy server

## Project Structure

```
lib/
├── main.dart                  # App entry point
├── route.dart                 # GoRouter navigation setup
├── Singleton/
│   └── app_provider.dart      # Global singleton for provider access
├── data/
│   └── DataHandler.dart       # Config & payload data management
├── provider/
│   ├── android_provider.dart  # Android state management
│   ├── ios_provider.dart      # iOS state management
│   └── ProviderSetup.dart     # Provider tree setup
├── push/
│   ├── AccessTokenManager.dart # OAuth2 & JWT token generation
│   └── PushHelper.dart         # FCM & APNs send logic
├── storage/
│   └── SharedPrefs.dart       # SharedPreferences wrapper
├── ui/
│   ├── home/                  # Home screen (platform selector)
│   ├── android/               # Android push tool screens & components
│   ├── iOS/                   # iOS push tool screens & components
│   ├── components/            # Shared UI components
│   └── res/                   # Resources (strings, colors)
└── extension/
    └── AppExtension.dart      # Dart extension methods
```

## Architecture

- **State Management:** Provider pattern with ChangeNotifier
- **Navigation:** GoRouter (URL-based, web-friendly)
- **Services:** Singleton pattern for shared services (DataHandler, PushHelper, AccessTokenManager)
- **Storage:** SharedPreferences for local persistence

## Dependencies

| Package | Purpose |
|---------|---------|
| `provider` | State management |
| `go_router` | Declarative navigation/routing |
| `googleapis_auth` | Google OAuth2 for FCM access tokens |
| `http` | HTTP requests to FCM |
| `http2` | HTTP/2 for direct APNs communication |
| `dart_jsonwebtoken` | JWT generation for APNs auth |
| `shared_preferences` | Local persistent storage |
| `file_picker` | Picking service account / .p8 files |
| `fluttertoast` | Toast messages |
| `package_info_plus` | App version info |

## Version

Current: **2.0.1+7**
