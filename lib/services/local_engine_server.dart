// =============================================================================
// FILE START: lib/services/local_engine_server.dart
// =============================================================================
import 'package:kompyuter_sirlari/imports.dart';

/// Desktop Engine: mahalliy HTTP server (CORS + /stats + /run).
class LocalEngineServer {
  LocalEngineServer({required this.onLog});

  final void Function(String) onLog;

  HttpServer? _server;
  String? _localAddress;

  /// `ip:port` — QR kod va pult ulanishi uchun.
  String? get localAddress => _localAddress;

  Future<void> start() async {
    try {
      _server = await HttpServer.bind(InternetAddress.anyIPv4, 0);
      _localAddress = '${await _detectLocalIp()}:${_server!.port}';
      onLog('Engine Ishga tushdi: http://$_localAddress');
      _server!.listen(_handleRequest);
    } catch (e) {
      onLog('Xatolik: $e');
    }
  }

  Future<String> _detectLocalIp() async {
    try {
      final interfaces = await NetworkInterface.list(type: InternetAddressType.IPv4);
      for (final interface in interfaces) {
        for (final addr in interface.addresses) {
          if (!addr.isLoopback) return addr.address;
        }
      }
    } catch (_) {}
    return '127.0.0.1';
  }

  Future<void> _handleRequest(HttpRequest request) async {
    request.response.headers
      ..add('Access-Control-Allow-Origin', '*')
      ..add('Access-Control-Allow-Methods', 'GET, POST, OPTIONS')
      ..add('Access-Control-Allow-Headers', 'Content-Type');

    if (request.method == 'OPTIONS') {
      request.response.statusCode = HttpStatus.ok;
      await request.response.close();
      return;
    }

    // 1. HARDWARE MONITORING ENDPOINT (/stats)
    if (request.method == 'GET' && request.uri.path == '/stats') {
      final stats = await SystemStatsService.instance.read();
      request.response
        ..headers.contentType = ContentType.json
        ..write(jsonEncode({'cpu': stats.cpu, 'ram': stats.ram}))
        ..close();
      return;
    }

    // 2. SKRIPT BAJARISH ENDPOINT (/run)
    if (request.method == 'POST' && request.uri.path == '/run') {
      final content = await utf8.decoder.bind(request).join();
      final data = jsonDecode(content) as Map<String, dynamic>;
      final code = data['code']?.toString() ?? '';

      onLog('Buyruq qabul qilindi. Ishlov berilmoqda...');

      if (Platform.isWindows) {
        ScriptExecutor.instance.runPowerShellElevated(code, onLog);
      } else if (Platform.isLinux) {
        ScriptExecutor.instance.runBashElevated(code, onLog);
      } else {
        onLog("Xatolik: Qo'llab-quvvatlanmaydigan operatsion tizim.");
      }

      request.response
        ..headers.contentType = ContentType.json
        ..write(jsonEncode({'status': 'ok'}))
        ..close();
      return;
    }

    // Noma'lum request
    request.response.statusCode = HttpStatus.notFound;
    await request.response.close();
  }

  void stop() => _server?.close();
}
// =============================================================================
// FILE END: lib/services/local_engine_server.dart
// =============================================================================