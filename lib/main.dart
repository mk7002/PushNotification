import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:pushapp/provider/ProviderSetup.dart';
import 'package:pushapp/route.dart';

import 'storage/SharedPrefs.dart';

Future<void> main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  usePathUrlStrategy();
  await SharedPrefs.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ProviderSetup(
      child: MaterialApp.router(
        routerConfig: globalRouter,
        title: 'Notify Now v1.0.4',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
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
