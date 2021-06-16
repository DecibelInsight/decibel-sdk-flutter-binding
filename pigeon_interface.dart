import 'package:pigeon/pigeon.dart';

class Parameter {
  String? screenName;
}

@HostApi()
abstract class DecibelSdkApi {
  void initialize();
  void setScreen(Parameter screenName);
}