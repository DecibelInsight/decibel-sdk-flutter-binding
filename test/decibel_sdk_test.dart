import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:decibel_sdk/decibel_sdk.dart';

void main() {
  const MethodChannel channel = MethodChannel('decibel_sdk');

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return '42';
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  test('getPlatformVersion', () async {
    expect(await DecibelSdk.platformVersion, '42');
  });
}
