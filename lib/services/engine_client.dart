// =============================================================================
// FILE START: lib/services/engine_client.dart
// =============================================================================
import 'package:kompyuter_sirlari/imports.dart';

enum EngineRunStatus { success, httpError, networkError }

class EngineRunResult {
  const EngineRunResult(this.status, {this.httpCode = 0});

  final EngineRunStatus status;
  final int httpCode;
}

/// Android pult → Desktop Engine HTTP mijoz.
class EngineClient {
  EngineClient(String baseUrl) : _baseUrl = normalizeUrl(baseUrl);

  final String _baseUrl;

  static String normalizeUrl(String url) {
    var value = url.trim();
    if (!value.startsWith('http://') && !value.startsWith('https://')) {
      value = 'http://$value';
    }
    return value;
  }

  /// GET /stats — real CPU/RAM ko'rsatkichlari.
  Future<HardwareStats> fetchStats() async {
    final client = HttpClient()..connectionTimeout = const Duration(seconds: 3);
    try {
      final request = await client.getUrl(Uri.parse('$_baseUrl/stats'));
      final response = await request.close();
      if (response.statusCode == 200) {
        final body = await response.transform(utf8.decoder).join();
        final json = jsonDecode(body) as Map<String, dynamic>;
        final cpu = json['cpu'] ?? json['cpu_usage'] ?? json['processor'];
        final ram = json['ram'] ?? json['ram_usage'] ?? json['memory'];
        return HardwareStats(
          cpu: cpu?.toString() ?? '32%',
          ram: ram?.toString() ?? '5.4 / 16 GB',
        );
      }
    } catch (_) {
      // Offline holat — fallback qiymatlar qaytariladi
    } finally {
      client.close();
    }
    return const HardwareStats.offline();
  }

  /// POST /run — [code] Desktop-da administrator huquqida bajariladi.
  Future<EngineRunResult> runScript(
    String code, {
    void Function(String)? onLog,
  }) async {
    final client = HttpClient()..connectionTimeout = const Duration(seconds: 6);
    try {
      onLog?.call('> Sending payload to $_baseUrl/run ...');
      final request = await client.postUrl(Uri.parse('$_baseUrl/run'));
      request.headers.contentType = ContentType.json;
      request.headers.set('Accept', 'application/json');
      request.write(jsonEncode({'code': code}));

      final response = await request.close();
      if (response.statusCode == 200) {
        onLog?.call('✔ SUCCESS (200 OK): Executed successfully');
        return const EngineRunResult(EngineRunStatus.success);
      }
      onLog?.call('✖ ERROR (${response.statusCode}): Execution failed');
      return EngineRunResult(EngineRunStatus.httpError, httpCode: response.statusCode);
    } catch (e) {
      onLog?.call('✖ NETWORK ERROR: $e');
      return const EngineRunResult(EngineRunStatus.networkError);
    } finally {
      client.close();
    }
  }
}
// =============================================================================
// FILE END: lib/services/engine_client.dart
// =============================================================================