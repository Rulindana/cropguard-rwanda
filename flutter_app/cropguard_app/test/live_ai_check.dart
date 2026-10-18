// LIVE check of the real AI integration. Skipped automatically when no key.
// Run with (OpenAI):
//   flutter test --dart-define=AI_API_KEY=sk-... test/live_ai_check.dart
// Run with (Cloudflare Workers AI — free daily quota):
//   flutter test --dart-define=AI_PROVIDER=cloudflare \
//     --dart-define=CLOUDFLARE_ACCOUNT_ID=... \
//     --dart-define=CLOUDFLARE_API_TOKEN=... test/live_ai_check.dart
import 'dart:io';

import 'package:cropguard_app/services/ai_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const key = String.fromEnvironment('AI_API_KEY');
  const provider = String.fromEnvironment('AI_PROVIDER',
      defaultValue: 'openai');
  const cfAccount = String.fromEnvironment('CLOUDFLARE_ACCOUNT_ID');
  const cfToken = String.fromEnvironment('CLOUDFLARE_API_TOKEN');
  final isCf = provider == 'cloudflare';
  final hasCreds = isCf
      ? (cfAccount.isNotEmpty && cfToken.isNotEmpty)
      : key.isNotEmpty;
  final needsCreds = hasCreds
      ? false as Object
      : isCf
          ? 'requires --dart-define=CLOUDFLARE_ACCOUNT_ID / CLOUDFLARE_API_TOKEN'
          : 'requires --dart-define=AI_API_KEY';
  final ai = AIService(
    apiKey: key,
    provider: provider,
    cloudflareAccountId: cfAccount,
    cloudflareToken: cfToken,
  );

  test('live: diagnose a real plant photo', () async {
    final bytes = File('assets/icon/hero_plant.jpg').readAsBytesSync();
    final result = await ai.diagnose(
      imageBytes: bytes,
      mimeType: 'image/jpeg',
      languageCode: 'en',
    );
    // ignore: avoid_print
    print('PLANT TEST -> isPlant=${result.isPlant}, '
        'disease=${result.disease?.id}, conf=${result.confidence}, '
        'alts=${result.alternatives.map((d) => d.id).toList()}, '
        'notes=${result.notes}');
    expect(result.isPlant, isTrue);
    expect(result.disease, isNotNull);
  }, timeout: const Timeout(Duration(minutes: 4)), skip: needsCreds);

  test('live: diagnose a non-plant logo', () async {
    final bytes = File('assets/icon/logo.png').readAsBytesSync();
    final result = await ai.diagnose(
      imageBytes: bytes,
      mimeType: 'image/png',
      languageCode: 'en',
    );
    // ignore: avoid_print
    print('LOGO TEST -> isPlant=${result.isPlant}, '
        'disease=${result.disease?.id}, notes=${result.notes}');
  }, timeout: const Timeout(Duration(minutes: 4)), skip: needsCreds);

  test('live: grounded chat answer', () async {
    final riskJson = File('assets/data/risk_scores.json').readAsStringSync();
    final facilities = File('assets/data/facilities.json').readAsStringSync();
    final ctx = AIService.buildDataContext(
      riskJson: riskJson,
      facilitiesJson: facilities,
    );
    final answer = await ai.ask(
      question:
          'Which districts are highest risk right now and what should farmers do?',
      languageCode: 'en',
      dataContext: ctx,
    );
    // ignore: avoid_print
    print('CHAT ANSWER -> $answer');
    expect(answer, isNotEmpty);
  }, timeout: const Timeout(Duration(minutes: 4)), skip: needsCreds);
}
