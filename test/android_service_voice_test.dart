import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:neostation/services/android_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const channel = MethodChannel('com.neogamelab.neostation/game');

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  test('voice recognition receives the active interface language', () async {
    MethodCall? received;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
          received = call;
          return 'open settings';
        });

    final phrase = await AndroidService.startVoiceRecognition(
      languageTag: 'pt-BR',
    );

    expect(phrase, 'open settings');
    expect(received?.method, 'startVoiceRecognition');
    expect(received?.arguments, {'languageTag': 'pt-BR'});
  });

  test('voice recognition omits an unavailable language tag', () async {
    MethodCall? received;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
          received = call;
          return null;
        });

    await AndroidService.startVoiceRecognition();

    expect(received?.arguments, isEmpty);
  });
}
