import 'package:provider/provider.dart';
import 'package:pushapp/provider/AppProvider.dart';

class Singleton {
  Singleton._internal();

  static final Singleton _instance = Singleton._internal();

  factory Singleton() {
    return _instance;
  }

  late AppProvider _provider;

  AppProvider get provider => _provider;

  void setProvider(context) {
    _provider = Provider.of<AppProvider>(context, listen: false);
  }
}
