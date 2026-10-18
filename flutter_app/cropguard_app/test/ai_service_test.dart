import 'dart:convert';
import 'dart:typed_data';

import 'package:cropguard_app/services/ai_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  const fakeKey = 'sk-test-key';

  String chatBody(String content) => jsonEncode({
        'choices': [
          {
            'message': {'content': content}
          }
        ]
      });

  group('AIService.diagnose', () {
    test('returns a real diagnosis mapped to the disease database', () async {
      late http.Request captured;
      final client = MockClient((request) async {
        captured = request;
        return http.Response(
          chatBody(jsonEncode({
            'is_plant': true,
            'disease_id': 'potato_late_blight',
            'confidence': 0.91,
            'alternatives': [
              {'disease_id': 'potato_early_blight', 'confidence': 0.4}
            ],
            'notes': 'Dark lesions with white fungal growth.',
          })),
          200,
          headers: {'content-type': 'application/json'},
        );
      });

      final ai = AIService(client: client, apiKey: fakeKey);
      final result = await ai.diagnose(
        imageBytes: Uint8List.fromList([1, 2, 3, 4]),
        mimeType: 'image/jpeg',
        languageCode: 'en',
      );

      expect(result.isPlant, isTrue);
      expect(result.disease?.id, 'potato_late_blight');
      expect(result.confidence, closeTo(0.91, 1e-9));
      expect(result.alternatives.map((d) => d.id), ['potato_early_blight']);
      expect(result.notes, isNotEmpty);

      // The photo really travels to the API as a data URL
      final authHeaders = captured.headers.entries
          .where((e) => e.key.toLowerCase() == 'authorization')
          .toList();
      expect(authHeaders, isNotEmpty);
      expect(authHeaders.first.value, 'Bearer $fakeKey');

      final body = jsonDecode(captured.body) as Map<String, dynamic>;
      final messages = body['messages'] as List;
      final userContent = messages.last['content'] as List;
      final imageUrl =
          (userContent.last['image_url'] as Map)['url'] as String;
      expect(imageUrl, startsWith('data:image/jpeg;base64,'));
      expect(userContent.first['text'], contains('potato_late_blight'));
    });

    test('flags non-plant photos instead of guessing', () async {
      final client = MockClient((_) async => http.Response(
            chatBody(jsonEncode({
              'is_plant': false,
              'disease_id': '',
              'confidence': 0.99,
              'alternatives': <dynamic>[],
              'notes': 'This looks like a document, not a leaf.',
            })),
            200,
            headers: {'content-type': 'application/json'},
          ));
      final ai = AIService(client: client, apiKey: fakeKey);
      final result = await ai.diagnose(
        imageBytes: Uint8List.fromList([9]),
        mimeType: 'image/jpeg',
        languageCode: 'en',
      );
      expect(result.isPlant, isFalse);
      expect(result.disease, isNull);
    });

    test('uncovered crop returns no disease (never force-matches)', () async {
      final client = MockClient((_) async => http.Response(
            chatBody(jsonEncode({
              'is_plant': true,
              'crop_seen': 'avocado seedling',
              'crop_covered': false,
              'disease_id': 'crop_not_covered',
              'confidence': 0,
              'alternatives': <dynamic>[],
              'notes': 'I see an avocado seedling, not covered yet.',
            })),
            200,
            headers: {'content-type': 'application/json'},
          ));
      final ai = AIService(client: client, apiKey: fakeKey);
      final result = await ai.diagnose(
        imageBytes: Uint8List.fromList([1]),
        mimeType: 'image/jpeg',
        languageCode: 'en',
      );
      expect(result.isPlant, isTrue);
      expect(result.cropCovered, isFalse);
      expect(result.cropSeen, 'avocado seedling');
      expect(result.disease, isNull);
      expect(result.alternatives, isEmpty);
    });

    test('rejects unknown disease ids instead of guessing', () async {
      final client = MockClient((_) async => http.Response(
            chatBody(jsonEncode({
              'is_plant': true,
              'disease_id': 'made_up_disease',
              'confidence': 0.8,
              'alternatives': <dynamic>[],
              'notes': '',
            })),
            200,
            headers: {'content-type': 'application/json'},
          ));
      final ai = AIService(client: client, apiKey: fakeKey);
      await expectLater(
        ai.diagnose(
          imageBytes: Uint8List.fromList([1]),
          mimeType: 'image/jpeg',
          languageCode: 'en',
        ),
        throwsA(isA<AIServiceException>().having(
          (e) => e.kind,
          'kind',
          AIServiceErrorKind.invalidResponse,
        )),
      );
    });

    test('maps HTTP 401 to an auth error', () async {      final client = MockClient(
          (_) async => http.Response('{"error":"invalid key"}', 401));
      final ai = AIService(client: client, apiKey: fakeKey);
      await expectLater(
        ai.diagnose(
          imageBytes: Uint8List.fromList([1]),
          mimeType: 'image/jpeg',
          languageCode: 'en',
        ),
        throwsA(isA<AIServiceException>()
            .having((e) => e.kind, 'kind', AIServiceErrorKind.auth)),
      );
    });

    test('maps HTTP 429 to a quota error', () async {
      final client =
          MockClient((_) async => http.Response('{"error":"limit"}', 429));
      final ai = AIService(client: client, apiKey: fakeKey);
      await expectLater(
        ai.diagnose(
          imageBytes: Uint8List.fromList([1]),
          mimeType: 'image/jpeg',
          languageCode: 'en',
        ),
        throwsA(isA<AIServiceException>()
            .having((e) => e.kind, 'kind', AIServiceErrorKind.quota)),
      );
    });

    test('fails honestly when no API key is configured', () async {
      final ai = AIService(apiKey: '');
      expect(ai.isConfigured, isFalse);
      await expectLater(
        ai.diagnose(
          imageBytes: Uint8List.fromList([1]),
          mimeType: 'image/jpeg',
          languageCode: 'en',
        ),
        throwsA(isA<AIServiceException>().having(
          (e) => e.kind,
          'kind',
          AIServiceErrorKind.notConfigured,
        )),
      );
    });

    test('tolerates json fences around the diagnosis', () async {
      final client = MockClient((_) async => http.Response(
            chatBody('```json\n${jsonEncode({
                  'is_plant': true,
                  'disease_id': 'healthy_plant',
                  'confidence': 0.95,
                  'alternatives': <dynamic>[],
                  'notes': 'Healthy green leaf.',
                })}\n```'),
            200,
            headers: {'content-type': 'application/json'},
          ));
      final ai = AIService(client: client, apiKey: fakeKey);
      final result = await ai.diagnose(
        imageBytes: Uint8List.fromList([1]),
        mimeType: 'image/jpeg',
        languageCode: 'en',
      );
      expect(result.disease?.id, 'healthy_plant');
    });
  });

  group('AIService.ask', () {
    test('returns the model answer', () async {
      final client = MockClient((_) async => http.Response(
            chatBody('Musanze is at 81/100 - red risk.'),
            200,
            headers: {'content-type': 'application/json'},
          ));
      final ai = AIService(client: client, apiKey: fakeKey);
      final answer = await ai.ask(
        question: 'Which district is red?',
        languageCode: 'en',
        dataContext: 'National: 30 districts',
      );
      expect(answer, contains('Musanze'));
    });

    test('fails honestly without a key', () async {
      final ai = AIService(apiKey: '');
      await expectLater(
        ai.ask(question: 'hi', languageCode: 'en', dataContext: ''),
        throwsA(isA<AIServiceException>().having(
          (e) => e.kind,
          'kind',
          AIServiceErrorKind.notConfigured,
        )),
      );
    });
  });

  group('AIService.buildDataContext', () {
    test('summarizes districts, ranking and facilities', () {
      final risk = jsonEncode({
        'generated_at': '2026-10-15T00:00:00Z',
        'districts': [
          {
            'district_name': 'Musanze',
            'province': 'Northern',
            'risk': {
              'risk_score': 81,
              'level': 'red',
              'rainfall_index': 100,
              'humidity_index': 90,
              'advisory': 'Emergency storage needed',
            },
            'risk_trend': 'rising',
          },
          {
            'district_name': 'Huye',
            'province': 'Southern',
            'risk': {
              'risk_score': 32,
              'level': 'green',
              'rainfall_index': 20,
              'humidity_index': 40,
              'advisory': 'Safe to harvest',
            },
            'risk_trend': 'stable',
          },
        ],
      });
      final facilities = jsonEncode([
        {'available_capacity_tons': 180},
        {'available_capacity_tons': 70},
      ]);

      final ctx = AIService.buildDataContext(
        riskJson: risk,
        facilitiesJson: facilities,
      );
      expect(ctx, contains('2 districts — 1 green, 0 yellow, 1 red'));
      expect(ctx, contains('Musanze'));
      expect(ctx, contains('Emergency storage needed'));
      // Highest risk listed first
      expect(ctx.indexOf('Musanze'), lessThan(ctx.indexOf('Huye')));
      expect(ctx, contains('2 total, 250 tons free capacity'));
    });

    test('survives a risk file without districts', () {
      final ctx =
          AIService.buildDataContext(riskJson: jsonEncode({'districts': []}));
      expect(ctx, contains('0 districts'));
    });
  });

  group('AIService Cloudflare provider', () {
    test('diagnose uses the Workers AI vision endpoint', () async {
      late http.Request captured;
      final client = MockClient((request) async {
        captured = request;
        return http.Response(
          jsonEncode({
            'result': {
              'response': jsonEncode({
                'is_plant': true,
                'disease_id': 'coffee_leaf_rust',
                'confidence': 0.77,
                'alternatives': <dynamic>[],
                'notes': 'Orange powdery spots on the leaf.',
              }),
            },
            'success': true,
            'errors': <dynamic>[],
          }),
          200,
          headers: {'content-type': 'application/json'},
        );
      });

      final ai = AIService(
        client: client,
        provider: 'cloudflare',
        cloudflareAccountId: 'acct123',
        cloudflareToken: 'cf-token',
      );
      expect(ai.provider, AIProvider.cloudflare);
      expect(ai.isConfigured, isTrue);

      final result = await ai.diagnose(
        imageBytes: Uint8List.fromList([5, 6]),
        mimeType: 'image/jpeg',
        languageCode: 'en',
      );
      expect(result.disease?.id, 'coffee_leaf_rust');

      expect(
        captured.url.toString(),
        contains(
            '/accounts/acct123/ai/run/@cf/meta/llama-3.2-11b-vision-instruct'),
      );
      final auth = captured.headers.entries
          .where((e) => e.key.toLowerCase() == 'authorization')
          .toList();
      expect(auth.first.value, 'Bearer cf-token');
      final body = jsonDecode(captured.body) as Map<String, dynamic>;
      expect(body['image'], isA<Map>());
      expect((body['image'] as Map)['base64'], isNotEmpty);
      expect(body['prompt'], contains('coffee_leaf_rust'));
    });

    test('ask uses the Workers AI chat endpoint', () async {
      final client = MockClient((_) async => http.Response(
            jsonEncode({
              'result': {'response': 'Musanze is the highest risk district.'},
              'success': true,
              'errors': <dynamic>[],
            }),
            200,
            headers: {'content-type': 'application/json'},
          ));
      final ai = AIService(
        client: client,
        provider: 'cloudflare',
        cloudflareAccountId: 'acct123',
        cloudflareToken: 'cf-token',
      );
      final answer = await ai.ask(
        question: 'Which district is highest risk?',
        languageCode: 'en',
        dataContext: 'ctx',
      );
      expect(answer, contains('Musanze'));
    });

    test('maps 401 to auth and 429 to quota', () async {
      final ai401 = AIService(
        client: MockClient((_) async => http.Response('{"success":false}', 401)),
        provider: 'cloudflare',
        cloudflareAccountId: 'a',
        cloudflareToken: 't',
      );
      await expectLater(
        ai401.ask(question: 'q', languageCode: 'en', dataContext: 'x'),
        throwsA(isA<AIServiceException>()
            .having((e) => e.kind, 'kind', AIServiceErrorKind.auth)),
      );

      final ai429 = AIService(
        client:
            MockClient((_) async => http.Response('{"success":false}', 429)),
        provider: 'cloudflare',
        cloudflareAccountId: 'a',
        cloudflareToken: 't',
      );
      await expectLater(
        ai429.ask(question: 'q', languageCode: 'en', dataContext: 'x'),
        throwsA(isA<AIServiceException>()
            .having((e) => e.kind, 'kind', AIServiceErrorKind.quota)),
      );
    });

    test('fails honestly without cloudflare credentials', () async {
      final ai = AIService(provider: 'cloudflare');
      expect(ai.isConfigured, isFalse);
      await expectLater(
        ai.diagnose(
          imageBytes: Uint8List.fromList([1]),
          mimeType: 'image/jpeg',
          languageCode: 'en',
        ),
        throwsA(isA<AIServiceException>().having(
          (e) => e.kind,
          'kind',
          AIServiceErrorKind.notConfigured,
        )),
      );
    });

    test('diagnose tolerates chatty llama vision output', () async {
      // Reproduces real Llama output: dummy blocks, markdown noise, python.
      const messy = '  {\n    "photo": "https://example.com/image.jpg"\n  }\n'
          '```\n'
          '{\n    "is_plant": true,\n'
          '    "disease_id": "maize_gray_leaf_spot",\n'
          '    "confidence": 0.8,\n'
          '    "alternatives": [\n'
          '      {"disease_id": "maize_northern_blight", "confidence": 0.1}\n'
          '    ],\n'
          '    "notes": "Grayish lesions with yellow halo."\n'
          '} \n```python\nimport json\n```';
      Future<void> runMessy(String messyBody) async {
        final client = MockClient((_) async => http.Response(
              jsonEncode({
                'result': {'response': messyBody},
                'success': true,
                'errors': <dynamic>[],
              }),
              200,
              headers: {'content-type': 'application/json'},
            ));
        final ai = AIService(
          client: client,
          provider: 'cloudflare',
          cloudflareAccountId: 'acct123',
          cloudflareToken: 'cf-token',
        );
        final result = await ai.diagnose(
          imageBytes: Uint8List.fromList([5, 6]),
          mimeType: 'image/jpeg',
          languageCode: 'en',
        );
        expect(result.isPlant, isTrue);
        expect(result.disease?.id, 'maize_gray_leaf_spot');
        expect(result.alternatives.map((d) => d.id),
            contains('maize_northern_blight'));
      }

      await runMessy(messy);

      // Exact live failure: dummy {"image": ...} fence FIRST, real answer
      // in a second fence — the parser must prefer the diagnosis block.
      const multiFence = '```\n'
          '{\n    "image": "https://example.com/image.jpg"\n  }\n'
          '```\n```\n'
          '{\n    "is_plant": true,\n'
          '    "disease_id": "maize_gray_leaf_spot",\n'
          '    "confidence": 0.8,\n'
          '    "alternatives": [\n'
          '      {"disease_id": "maize_northern_blight", "confidence": 0.2}\n'
          '    ],\n'
          '    "notes": "Grayish-brown lesions with yellow halo."\n'
          '}\n```';
      await runMessy(multiFence);
    });

    test('proxy configured: isConfigured true without a token', () {
      final ai = AIService(
        provider: 'cloudflare',
        cloudflareProxyUrl: 'https://cropguard-ai.example.workers.dev',
      );
      expect(ai.isConfigured, isTrue);
      expect(ai.usesProxy, isTrue);
    });

    test('proxy chat hits /v1/chat with no Authorization header', () async {
      Uri? seen;
      Map<String, String>? seenHeaders;
      final client = MockClient((req) async {
        seen = req.url;
        seenHeaders = req.headers;
        return http.Response(
          jsonEncode({
            'result': {'response': 'High risk in Burera.'},
            'success': true,
            'errors': <dynamic>[],
          }),
          200,
          headers: {'content-type': 'application/json'},
        );
      });
      final ai = AIService(
        client: client,
        provider: 'cloudflare',
        cloudflareProxyUrl: 'https://cropguard-ai.example.workers.dev/',
      );
      final answer = await ai.ask(
        question: 'Which districts?',
        languageCode: 'en',
        dataContext: 'ctx',
      );
      expect(answer, contains('Burera'));
      expect(seen.toString(),
          'https://cropguard-ai.example.workers.dev/v1/chat');
      expect(seenHeaders!.keys.map((k) => k.toLowerCase()),
          isNot(contains('authorization')));
    });
  });
}
