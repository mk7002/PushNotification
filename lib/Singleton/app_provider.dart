import 'package:provider/provider.dart';
import 'package:pushapp/provider/android_provider.dart';
import 'package:pushapp/provider/ios_provider.dart';

class AppProvider {
  AppProvider._internal();

  static final AppProvider _instance = AppProvider._internal();

  factory AppProvider() {
    return _instance;
  }

  late AndroidProvider _androidProvider;

  AndroidProvider get androidProvider => _androidProvider;

  void setAndroidProvider(context) {
    _androidProvider = Provider.of<AndroidProvider>(context, listen: false);
  }

  late IosPlatformProvider _iosProvider;

  IosPlatformProvider get iosProvider => _iosProvider;

  void setIosProvider(context) {
    _iosProvider = Provider.of<IosPlatformProvider>(context, listen: false);
  }
}
