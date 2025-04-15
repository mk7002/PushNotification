import 'package:provider/provider.dart';
import 'package:pushapp/provider/android_provider.dart';

class Singleton {
  Singleton._internal();

  static final Singleton _instance = Singleton._internal();

  factory Singleton() {
    return _instance;
  }

  late AndroidProvider _provider;

  AndroidProvider get provider => _provider;

  void setProvider(context) {
    _provider = Provider.of<AndroidProvider>(context, listen: false);
  }
}
