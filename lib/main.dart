import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:pushapp/provider/ProviderSetup.dart';
import 'package:pushapp/route.dart';
import 'package:pushapp/ui/components/Utils.dart';

import 'storage/SharedPrefs.dart';

Future<void> main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  usePathUrlStrategy();
  await SharedPrefs.init();
  await Utils().getAppVersionInfo();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ProviderSetup(
      child: MaterialApp.router(
        routerConfig: globalRouter,
        debugShowCheckedModeBanner: false,
        title: 'Notify Now v${Utils.versionCode}',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF3DDC84),
            brightness: Brightness.light,
          ),
          useMaterial3: true,
          scaffoldBackgroundColor: const Color(0xFFF8F9FA),
          fontFamily: 'Inter',
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: const Color(0xFFF8F9FA),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFF3DDC84), width: 1.5),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            labelStyle: TextStyle(
              fontSize: 13,
              color: Colors.grey[600],
            ),
          ),
        ),
      ),
    );
  }
}

//https://notifynow.web.app/
// flutter build web
// cd build/web
// firebase login - kenimilind864
//firebase deploy --only hosting:notifynow
//firebase:json - {
//   "hosting": {
//     "public": ".",
//     "site": "notifynow",
//     "ignore": [
//       "firebase.json",
//       "**/.*",
//       "**/node_modules/**"
//     ],
//     "rewrites": [
//       {
//         "source": "**",
//         "destination": "/index.html"
//       }
//     ]
//   }
// }
