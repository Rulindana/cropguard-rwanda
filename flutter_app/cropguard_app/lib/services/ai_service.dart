/// CropGuard AI — Real AI service (OpenAI vision + chat).
///
/// Replaces the old deterministic `mockAnalyze` disease picker and the
/// keyword-only chatbot with genuine model calls:
///
///  * [AIService.diagnose] sends the farmer's photo (base64) together with the
///    local disease database to a vision-capable model and gets back a
///    structured JSON diagnosis (disease id, real confidence, alternatives).
///  * [AIService.ask] answers chatbot questions grounded in live CropGuard
///    risk/facility data (see [AIService.loadDataContext]).
///
/// The API key is NEVER hard-coded. It is injected at build/run time:
///
/// ```sh
/// flutter run  --dart-define=AI_API_KEY=sk-...
/// flutter build apk --dart-define=AI_API_KEY=sk-...
/// ```
///
/// Everything degrades honestly when the key or network is missing:
/// callers receive an [AIServiceException] and show a real error message —
/// no fabricated results.
library;

import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart' show Uint8List, visibleForTesting;
import 'package:flutter/services.dart' show rootBundle;
import 'package:http/http.dart' as http;

import '../models/disease_model.dart';

/// Why an AI call failed. Used by the UI to pick an honest, localized message.
enum AIServiceErrorKind {
  /// No API key was provided via --dart-define.
  notConfigured,

  /// No connectivity / timeout / DNS failure.
  network,

  /// 401/403 — invalid or expired API key.
  auth,

  /// 429 — rate limit or out of quota.
  quota,

  /// The model responded with something we cannot trust (bad JSON, unknown id).
  invalidResponse,

  /// Anything else (5xx, unexpected payload, ...).
  unknown,
}

class AIServiceException implements Exception {
  AIServiceException(this.kind, this.message);

  final AIServiceErrorKind kind;
  final String message;

  @override
  String toString() => 'AIServiceException(${kind.name}: $message)';
}

/// Structured result of a real image diagnosis.
class AIDiagnosis {
  const AIDiagnosis({
    required this.isPlant,
    required this.disease,
    required this.confidence,
    required this.alternatives,
    required this.notes,
    this.cropSeen = '',
    this.cropCovered = true,
  });

  /// False when the photo does not show a plant/leaf at all.
  final bool isPlant;

  /// Matched entry from [DiseaseDatabase.all]. Null when the model says the
  /// photo is a plant but the crop is NOT covered by our database
  /// ([cropCovered] == false) — callers must show an honest "not covered"
  /// card instead of a fabricated disease.
  final PlantDisease? disease;

  /// Model-reported confidence, 0.0–1.0.
  final double confidence;

  /// Runner-up matches, best first.
  final List<PlantDisease> alternatives;

  /// Short observation written by the model in the user's language.
  final String notes;

  /// Open-world crop name the model saw (e.g. "avocado seedling").
  /// Empty when [isPlant] is false.
  final String cropSeen;

  /// False when [cropSeen] is outside our database crops — no disease may be
  /// shown in that case.
  final bool cropCovered;
}

/// Which cloud AI backend to use. Selected via
/// `--dart-define=AI_PROVIDER=openai|cloudflare`.
enum AIProvider { openai, cloudflare }

class AIService {
  AIService({
    http.Client? client,
    String? apiKey,
    String? model,
    String? provider,
    String? cloudflareAccountId,
    String? cloudflareToken,
    String? cloudflareProxyUrl,
  })  : _client = client ?? http.Client(),
        _provider = (provider ??
                    const String.fromEnvironment('AI_PROVIDER',
                        defaultValue: 'openai')) ==
                'cloudflare'
            ? AIProvider.cloudflare
            : AIProvider.openai,
        _apiKey = apiKey ?? const String.fromEnvironment('AI_API_KEY'),
        _explicitModel = model,
        _cfAccountId = cloudflareAccountId ??
            const String.fromEnvironment('CLOUDFLARE_ACCOUNT_ID'),
        _cfToken = cloudflareToken ??
            const String.fromEnvironment('CLOUDFLARE_API_TOKEN'),
        _cfProxyUrl = cloudflareProxyUrl ??
            const String.fromEnvironment('CLOUDFLARE_PROXY_URL');

  static const String _endpoint =
      'https://api.openai.com/v1/chat/completions';
  static const String _cfVisionModel =
      '@cf/meta/llama-3.2-11b-vision-instruct';
  static const Duration _timeout = Duration(seconds: 60);
  static const Duration _cfVisionTimeout = Duration(seconds: 180);

  final http.Client _client;
  final AIProvider _provider;
  final String _apiKey;
  final String? _explicitModel;
  final String _cfAccountId;
  final String _cfToken;

  /// Optional Cloudflare Worker proxy (required on web: browsers are blocked
  /// by CORS from calling api.cloudflare.com directly; the proxy also keeps
  /// the token server-side). Set via --dart-define=CLOUDFLARE_PROXY_URL=...
  /// When set, Cloudflare calls go through the proxy (no token header sent).
  final String _cfProxyUrl;

  /// Chat/text model — provider-specific default, overridable via AI_MODEL.
  String get _chatModel {
    if (_explicitModel != null) return _explicitModel;
    if (_provider == AIProvider.cloudflare) {
      return const String.fromEnvironment(
        'AI_MODEL',
        defaultValue: '@cf/meta/llama-3.3-70b-instruct-fp8-fast',
      );
    }
    return const String.fromEnvironment('AI_MODEL',
        defaultValue: 'gpt-4o-mini');
  }

  /// True when credentials for the selected provider are available.
  /// (Cloudflare web builds only need the proxy URL — the token stays
  /// server-side inside the Worker.)
  bool get isConfigured => _provider == AIProvider.cloudflare
      ? (_cfProxyUrl.isNotEmpty ||
          (_cfAccountId.isNotEmpty && _cfToken.isNotEmpty))
      : _apiKey.isNotEmpty;

  /// Public: whether web builds must route through the proxy.
  bool get usesProxy => _cfProxyUrl.isNotEmpty;

  /// Which provider is active (tests + UI status labels).
  AIProvider get provider => _provider;

  // ── Disease diagnosis ───────────────────────────────────────────────────────

  /// Sends [imageBytes] to the vision model and returns a real diagnosis.
  ///
  /// Throws [AIServiceException] on any failure — callers must surface the
  /// error instead of inventing a result.
  Future<AIDiagnosis> diagnose({
    required Uint8List imageBytes,
    required String mimeType,
    required String languageCode,
    List<PlantDisease> database = DiseaseDatabase.all,
  }) async {
    if (!isConfigured) {
      throw AIServiceException(
        AIServiceErrorKind.notConfigured,
        _provider == AIProvider.cloudflare
            ? 'CLOUDFLARE_ACCOUNT_ID / CLOUDFLARE_API_TOKEN not set'
            : 'AI_API_KEY not set (run with --dart-define=AI_API_KEY=...)',
      );
    }

    final languageName = switch (languageCode) {
      'rw' => 'Kinyarwanda',
      'fr' => 'French',
      _ => 'English',
    };

    final diseaseVocabulary = database
        .map((d) => {
              'id': d.id,
              'name': d.name,
              'crop': d.cropAffected,
              'description': d.description,
              'symptoms': d.symptoms,
            })
        .toList();

    final coveredCrops = database
        .map((d) => d.cropAffected)
        .toSet()
        .toList(growable: false);

    final systemPrompt = [
      'You are a plant pathologist embedded in the CropGuard app for Rwanda.',
      'You examine ONE photo and answer in TWO stages.',
      'STAGE 1 — identify the crop (open world): look at the photo and name',
      'the crop you actually see (e.g. "maize", "avocado seedling",',
      '"tomato", "unknown tree"). Put it in "crop_seen".',
      'The app currently covers ONLY these crops: ${coveredCrops.join(', ')}.',
      'STAGE 2 — disease match:',
      '- If the photo does not clearly show a plant, set is_plant to false.',
      '- If the crop_seen is NOT one of the covered crops, set',
      '  "crop_covered" to false, "disease_id" to "crop_not_covered",',
      '  confidence to 0, alternatives to [], and explain in "notes" (in',
      '  $languageName) what crop you see and that it is not covered yet.',
      '  NEVER force-match an uncovered crop to a covered disease.',
      '- If the plant is healthy with no disease, use disease_id "healthy_plant".',
      '- Otherwise disease_id MUST be one of the ids from the database list.',
      '- confidence is your calibrated probability between 0 and 1.',
      '- alternatives: up to 2 other database ids (never the primary one), each with a confidence.',
      '- notes: 1-2 plain sentences in $languageName describing what you observe in the photo.',
      'Answer ONLY with a JSON object of the shape:',
      '{"is_plant": bool, "crop_seen": string, "crop_covered": bool, '
          '"disease_id": string, "confidence": number, '
          '"alternatives": [{"disease_id": string, "confidence": number}], "notes": string}',
    ].join('\n');

    final userText =
        'Disease database:\n${jsonEncode(diseaseVocabulary)}\n\n'
        'Diagnose the attached photo. Answer ONLY with the JSON object.';

    final String raw;
    if (_provider == AIProvider.cloudflare) {
      // Native Workers AI vision endpoint (llama-3.2-11b-vision), or the
      // same-model Worker proxy on web (CORS-safe, token stays server-side).
      final envelope = await _postCloudflare(
        _cfVisionUri(),
        _cfProxyUrl.isNotEmpty
            ? {
                'prompt': '$systemPrompt\n\n$userText',
                'image_base64': base64Encode(imageBytes),
                'max_tokens': 700,
                'temperature': 0.2,
              }
            : {
                'prompt': '$systemPrompt\n\n$userText',
                'image': {'base64': base64Encode(imageBytes)},
                'max_tokens': 700,
                'temperature': 0.2,
              },
        timeout: _cfVisionTimeout,
      );
      raw = _extractCloudflare(envelope);
    } else {
      final body = {
        'model': _chatModel,
        'temperature': 0.2,
        'max_tokens': 700,
        'response_format': {'type': 'json_object'},
        'messages': [
          {'role': 'system', 'content': systemPrompt},
          {
            'role': 'user',
            'content': [
              {'type': 'text', 'text': userText},
              {
                'type': 'image_url',
                'image_url': {
                  'url': 'data:$mimeType;base64,${base64Encode(imageBytes)}'
                },
              },
            ],
          },
        ],
      };
      raw = _extractContent(await _post(body));
    }

    Map<String, dynamic> parsed;
    try {
      parsed = _decodeJsonObject(raw);
    } on Exception {
      throw AIServiceException(
        AIServiceErrorKind.invalidResponse,
        'Model returned unparseable diagnosis: $raw',
      );
    }

    final isPlant = parsed['is_plant'] == true;
    final diseaseId = (parsed['disease_id'] ?? '').toString();
    final confidence =
        ((parsed['confidence'] as num?) ?? 0).toDouble().clamp(0.0, 1.0);
    final cropSeen = (parsed['crop_seen'] ?? '').toString();
    // Default: covered unless the model explicitly says otherwise or uses
    // the escape-hatch id.
    var cropCovered = parsed['crop_covered'] != false;
    if (diseaseId == 'crop_not_covered') cropCovered = false;

    PlantDisease? disease;
    if (isPlant && cropCovered && diseaseId.isNotEmpty) {
      disease = _lookupById(database, diseaseId);
      if (disease == null) {
        throw AIServiceException(
          AIServiceErrorKind.invalidResponse,
          'Model returned unknown disease id "$diseaseId"',
        );
      }
    }

    final alternatives = <PlantDisease>[];
    if (cropCovered) {
      final rawAlts = parsed['alternatives'];
      if (rawAlts is List) {
        for (final entry in rawAlts.take(2)) {
          if (entry is Map && entry['disease_id'] != null) {
            final alt = _lookupById(database, entry['disease_id'].toString());
            if (alt != null && alt.id != diseaseId) alternatives.add(alt);
          }
        }
      }
    }

    return AIDiagnosis(
      isPlant: isPlant,
      disease: disease,
      confidence: confidence.toDouble(),
      alternatives: alternatives,
      notes: (parsed['notes'] ?? '').toString(),
      cropSeen: cropSeen,
      cropCovered: cropCovered,
    );
  }

  // ── Grounded chatbot ────────────────────────────────────────────────────────

  /// Answers [question] in [languageCode], grounded in [dataContext]
  /// (live risk/facility data built by [loadDataContext]).
  Future<String> ask({
    required String question,
    required String languageCode,
    required String dataContext,
  }) async {
    if (!isConfigured) {
      throw AIServiceException(
        AIServiceErrorKind.notConfigured,
        _provider == AIProvider.cloudflare
            ? 'CLOUDFLARE_ACCOUNT_ID / CLOUDFLARE_API_TOKEN not set'
            : 'AI_API_KEY not set (run with --dart-define=AI_API_KEY=...)',
      );
    }

    final languageName = switch (languageCode) {
      'rw' => 'Kinyarwanda',
      'fr' => 'French',
      _ => 'English',
    };

    final systemPrompt = [
      'You are the CropGuard assistant for Rwanda farmers and district planners.',
      'Answer ONLY from the LIVE DATA below plus general agronomy knowledge.',
      'Write in $languageName. Keep it short (max ~120 words), plain text,',
      'friendly, no markdown symbols. If the data does not cover the question,',
      'say so honestly instead of inventing numbers.',
      'You are a planning assistant, not an emergency service.',
      '',
      'LIVE DATA:',
      dataContext,
    ].join('\n');

    final messages = [
      {'role': 'system', 'content': systemPrompt},
      {'role': 'user', 'content': question},
    ];

    if (_provider == AIProvider.cloudflare) {
      final envelope = await _postCloudflare(
        _cfChatUri(),
        _cfProxyUrl.isNotEmpty
            ? {
                'messages': messages,
                'max_tokens': 500,
                'temperature': 0.4,
              }
            : {
                'messages': messages,
                'max_tokens': 500,
                'temperature': 0.4,
              },
      );
      return _extractCloudflare(envelope).trim();
    }

    final body = {
      'model': _chatModel,
      'temperature': 0.4,
      'max_tokens': 500,
      'messages': messages,
    };
    return _extractContent(await _post(body)).trim();
  }

  // ── Live data context for the chatbot ───────────────────────────────────────

  /// Loads bundled risk + facility data and compresses it into a prompt-size
  /// summary (national counts, worst districts, advisories, facility totals).
  Future<String> loadDataContext() async {
    try {
      final riskRaw =
          await rootBundle.loadString('assets/data/risk_scores.json');
      String? facilitiesRaw;
      try {
        facilitiesRaw =
            await rootBundle.loadString('assets/data/facilities.json');
      } on Exception {
        facilitiesRaw = null;
      }
      return buildDataContext(riskJson: riskRaw, facilitiesJson: facilitiesRaw);
    } on Exception catch (e) {
      return 'Live CropGuard data unavailable right now ($e).';
    }
  }

  /// Pure, testable summarizer for [loadDataContext].
  @visibleForTesting
  static String buildDataContext({
    required String riskJson,
    String? facilitiesJson,
  }) {
    final lines = <String>[];
    final Map<String, dynamic> root =
        jsonDecode(riskJson) as Map<String, dynamic>;
    final districts = (root['districts'] as List? ?? [])
        .whereType<Map<String, dynamic>>()
        .toList();

    var green = 0, yellow = 0, red = 0, sumScore = 0.0;
    for (final d in districts) {
      final risk = d['risk'] as Map<String, dynamic>? ?? {};
      final level = (risk['level'] ?? 'green').toString();
      if (level == 'red') {
        red++;
      } else if (level == 'yellow') {
        yellow++;
      } else {
        green++;
      }
      sumScore += (risk['risk_score'] as num?)?.toDouble() ?? 0;
    }

    lines.add('Generated at: ${root['generated_at'] ?? 'unknown'}');
    lines.add(
        'National: ${districts.length} districts — $green green, $yellow yellow, '
        '$red red, avg risk '
        '${districts.isEmpty ? 0 : (sumScore / districts.length).round()}/100.');

    final ranked = [...districts]
      ..sort((a, b) {
        final ra = ((a['risk'] as Map? ?? {})['risk_score'] as num?) ?? 0;
        final rb = ((b['risk'] as Map? ?? {})['risk_score'] as num?) ?? 0;
        return rb.compareTo(ra);
      });

    lines.add('Highest-risk districts (score, trend, advisory):');
    for (final d in ranked.take(8)) {
      final risk = d['risk'] as Map<String, dynamic>? ?? {};
      final trend = d['risk_trend'];
      final trendStr = trend is String
          ? trend
          : ((trend is Map ? trend['trend'] : null) ?? 'baseline');
      lines.add(
        '- ${d['district_name']} (${d['province']}): '
        '${((risk['risk_score'] as num?) ?? 0).round()}/100, $trendStr, '
        'rain ${(risk['rainfall_index'] as num?)?.round() ?? 0}, '
        'hum ${(risk['humidity_index'] as num?)?.round() ?? 0} — '
        '${risk['advisory'] ?? d['advisory'] ?? ''}',
      );
    }

    if (facilitiesJson != null && facilitiesJson.isNotEmpty) {
      try {
        final facilities = jsonDecode(facilitiesJson);
        if (facilities is List) {
          final totalTons = facilities.fold<double>(0, (sum, f) {
            final map = f as Map<String, dynamic>;
            return sum +
                ((map['available_capacity_tons'] as num?) ?? 0).toDouble();
          });
          lines.add('Storage facilities: ${facilities.length} total, '
              '${totalTons.round()} tons free capacity across Rwanda.');
        }
      } on Exception {
        // Facilities are optional context — ignore parse failures.
      }
    }

    return lines.join('\n');
  }

  // ── HTTP plumbing ───────────────────────────────────────────────────────────

  Future<Map<String, dynamic>> _post(Map<String, dynamic> body) async {
    late http.Response response;
    try {
      response = await _client
          .post(
            Uri.parse(_endpoint),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $_apiKey',
            },
            body: jsonEncode(body),
          )
          .timeout(_timeout);
    } on SocketException {
      throw AIServiceException(
          AIServiceErrorKind.network, 'No internet connection');
    } on http.ClientException {
      throw AIServiceException(
          AIServiceErrorKind.network, 'Could not reach the AI service');
    } on Exception catch (e) {
      if (e.toString().contains('TimeoutException')) {
        throw AIServiceException(
            AIServiceErrorKind.network, 'AI service timed out');
      }
      throw AIServiceException(AIServiceErrorKind.unknown, e.toString());
    }

    if (response.statusCode == 401 || response.statusCode == 403) {
      throw AIServiceException(
          AIServiceErrorKind.auth, 'Invalid or expired AI_API_KEY');
    }
    if (response.statusCode == 429) {
      throw AIServiceException(
          AIServiceErrorKind.quota, 'AI service rate limit / quota exceeded');
    }
    if (response.statusCode >= 500) {
      throw AIServiceException(AIServiceErrorKind.unknown,
          'AI service error ${response.statusCode}');
    }
    if (response.statusCode != 200) {
      throw AIServiceException(
          AIServiceErrorKind.unknown,
          'Unexpected AI service response (${response.statusCode}): '
          '${response.body}');
    }

    try {
      return jsonDecode(response.body) as Map<String, dynamic>;
    } on Exception {
      throw AIServiceException(
          AIServiceErrorKind.invalidResponse, 'Non-JSON API response');
    }
  }

  // ── Cloudflare Workers AI plumbing ──────────────────────────────────────────

  Uri _cfRunUri(String model) => Uri.parse(
      'https://api.cloudflare.com/client/v4/accounts/$_cfAccountId/ai/run/$model');

  /// Proxy-aware endpoint for vision. When CLOUDFLARE_PROXY_URL is set
  /// (web builds), calls go to the Worker's /v1/vision (CORS-safe);
  /// otherwise direct to Workers AI (mobile).
  Uri _cfVisionUri() => _cfProxyUrl.isNotEmpty
      ? Uri.parse('${_cfProxyUrl.replaceAll(RegExp(r'/+$'), '')}/v1/vision')
      : _cfRunUri(_cfVisionModel);

  /// Proxy-aware endpoint for chat. Same pattern as [_cfVisionUri].
  Uri _cfChatUri() => _cfProxyUrl.isNotEmpty
      ? Uri.parse('${_cfProxyUrl.replaceAll(RegExp(r'/+$'), '')}/v1/chat')
      : _cfRunUri(_chatModel);

  /// POSTs to a Workers AI model and returns the Cloudflare envelope
  /// (`{result: {...}, success, errors, ...}`).
  Future<Map<String, dynamic>> _postCloudflare(
    Uri uri,
    Map<String, dynamic> body, {
    Duration? timeout,
  }) async {
    late http.Response response;
    // Via the Worker proxy no Authorization header is sent — the token
    // lives server-side inside the Worker. Direct calls need it.
    final headers = <String, String>{'Content-Type': 'application/json'};
    if (_cfProxyUrl.isEmpty && _cfToken.isNotEmpty) {
      headers['Authorization'] = 'Bearer $_cfToken';
    }
    try {
      response = await _client
          .post(
            uri,
            headers: headers,
            body: jsonEncode(body),
          )
          .timeout(timeout ?? _timeout);
    } on SocketException {
      throw AIServiceException(
          AIServiceErrorKind.network, 'No internet connection');
    } on http.ClientException {
      throw AIServiceException(
          AIServiceErrorKind.network, 'Could not reach the AI service');
    } on Exception catch (e) {
      if (e.toString().contains('TimeoutException')) {
        throw AIServiceException(
            AIServiceErrorKind.network, 'AI service timed out');
      }
      throw AIServiceException(AIServiceErrorKind.unknown, e.toString());
    }

    Map<String, dynamic> envelope;
    try {
      envelope = jsonDecode(response.body) as Map<String, dynamic>;
    } on Exception {
      throw AIServiceException(
          AIServiceErrorKind.invalidResponse, 'Non-JSON Cloudflare response');
    }

    if (response.statusCode == 401 || response.statusCode == 403) {
      throw AIServiceException(
          AIServiceErrorKind.auth, 'Invalid Cloudflare token/account id');
    }
    if (response.statusCode == 429) {
      throw AIServiceException(AIServiceErrorKind.quota,
          'Workers AI rate limit exceeded (free tier resets daily 00:00 UTC)');
    }
    if (response.statusCode >= 400 || envelope['success'] == false) {
      final errors = envelope['errors'];
      final message = (errors is List && errors.isNotEmpty)
          ? '${(errors.first as Map)['message'] ?? ''}'
          : 'HTTP ${response.statusCode}';
      throw AIServiceException(
        AIServiceErrorKind.unknown,
        'Cloudflare Workers AI: $message',
      );
    }
    return envelope;
  }

  /// Extracts `result.response` from a Workers AI envelope.
  String _extractCloudflare(Map<String, dynamic> envelope) {
    final result = envelope['result'];
    if (result is Map) {
      final text = result['response'];
      if (text is String && text.trim().isNotEmpty) return text;
    }
    throw AIServiceException(
        AIServiceErrorKind.invalidResponse, 'Empty Cloudflare model response');
  }

  String _extractContent(Map<String, dynamic> json) {
    try {
      final choices = json['choices'] as List;
      final message = choices.first['message'] as Map<String, dynamic>;
      final content = message['content'];
      if (content is! String || content.trim().isEmpty) {
        throw AIServiceException(
            AIServiceErrorKind.invalidResponse, 'Empty model response');
      }
      return content;
    } on AIServiceException {
      rethrow;
    } on Exception catch (e) {
      throw AIServiceException(
          AIServiceErrorKind.invalidResponse, 'Malformed response: $e');
    }
  }

  /// Decodes a JSON object, tolerating ```json fences and chatty preambles
  /// from smaller open models (Llama vision often wraps JSON in markdown,
  /// adds dummy URLs/code, or emits multiple JSON blocks — we pick the best).
  static Map<String, dynamic> _decodeJsonObject(String raw) {
    var text = raw.trim();
    // Strip ```json ... ``` fences. Some models emit several fenced blocks
    // (e.g. a dummy request echo + the real answer), so scan ALL fences and
    // prefer the one holding a diagnosis.
    final fence = RegExp(r'```(?:json)?\s*([\s\S]*?)\s*```');
    final fenceMatches = fence.allMatches(text).toList();
    if (fenceMatches.isNotEmpty) {
      String? diagnosisFence;
      for (final m in fenceMatches) {
        final inner = m.group(1)!.trim();
        if (inner.contains('disease_id') || inner.contains('is_plant')) {
          if (diagnosisFence == null ||
              inner.length > diagnosisFence.length) {
            diagnosisFence = inner;
          }
        }
      }
      text = (diagnosisFence ?? fenceMatches.first.group(1)!).trim();
    }
    // Try direct decode first.
    try {
      final decoded = jsonDecode(text);
      if (decoded is Map<String, dynamic>) return decoded;
    } on FormatException {
      // Fall through to brace scanning.
    }
    // Scan for every {...} candidate containing "disease_id" or "is_plant";
    // return the longest valid one (the real answer, not dummy snippets).
    Map<String, dynamic>? best;
    final braceStart = RegExp(r'\{');
    for (final m in braceStart.allMatches(text)) {
      var depth = 0;
      var inString = false;
      var escaped = false;
      for (var i = m.start; i < text.length; i++) {
        final c = text[i];
        if (inString) {
          if (escaped) {
            escaped = false;
          } else if (c == '\\') {
            escaped = true;
          } else if (c == '"') {
            inString = false;
          }
        } else {
          if (c == '"') {
            inString = true;
          } else if (c == '{') {
            depth++;
          } else if (c == '}') {
            depth--;
            if (depth == 0) {
              final candidate = text.substring(m.start, i + 1);
              if (candidate.contains('disease_id') ||
                  candidate.contains('is_plant')) {
                try {
                  final decoded = jsonDecode(candidate);
                  if (decoded is Map<String, dynamic> &&
                      (best == null ||
                          candidate.length > jsonEncode(best).length)) {
                    best = decoded;
                  }
                } on FormatException {
                  // Not valid JSON — keep scanning.
                }
              }
              break;
            }
          }
        }
      }
    }
    if (best != null) return best;
    throw const FormatException('No JSON object with diagnosis found');
  }

  static PlantDisease? _lookupById(List<PlantDisease> database, String id) {
    for (final d in database) {
      if (d.id == id) return d;
    }
    // Tolerate name-based answers ("Late Blight" instead of the id).
    final lowered = id.toLowerCase().replaceAll('_', ' ');
    for (final d in database) {
      if (d.name.toLowerCase() == lowered) return d;
    }
    return null;
  }
}
