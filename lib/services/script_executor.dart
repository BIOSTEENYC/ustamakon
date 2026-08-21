// =============================================================================
// FILE START: lib/services/script_executor.dart
// =============================================================================
import 'package:kompyuter_sirlari/imports.dart';

/// Desktop-da skriptlarni Administrator/Root huquqida ijro etuvchi.
class ScriptExecutor {
  ScriptExecutor._();
  static final instance = ScriptExecutor._();

  /// Windows: bitta UAC oynasi orqali (Start-Process -Verb RunAs -Wait).
  Future<void> runPowerShellElevated(String code, void Function(String) onLog) async {
    try {
      onLog("Windows: Administrator tasdiq'i (UAC) kutilmoqda...");
      final result = await Process.run('powershell', [
        '-Command',
        'Start-Process powershell -ArgumentList "-NoProfile -ExecutionPolicy Bypass -Command `"$code`"" -Verb RunAs -Wait',
      ]);
      onLog('Windows: Buyruq bajarildi.');
      if (result.stdout.toString().isNotEmpty) onLog('Natija: ${result.stdout}');
      if (result.stderr.toString().isNotEmpty) onLog('Xato: ${result.stderr}');
    } catch (e) {
      onLog('Windowsda bajarishda xatolik: $e');
    }
  }

  /// Linux: sudo'larni tozalab, pkexec orqali bir marta GUI parol so'raydi.
  Future<void> runBashElevated(String code, void Function(String) onLog) async {
    try {
      final cleanCode = code.replaceAll(RegExp(r'\bsudo\s+'), '');
      onLog("Linux: Root parol so'rovi (pkexec) kutilmoqda...");
      final result = await Process.run('pkexec', ['bash', '-c', cleanCode]);
      if (result.stdout.toString().isNotEmpty) onLog('Linux Natija:\n${result.stdout}');
      if (result.stderr.toString().isNotEmpty) onLog('Linux Xato:\n${result.stderr}');
      onLog("Linux: Barcha buyruqlar bajarib bo'ldi.");
    } catch (e) {
      onLog('Linuxda bajarishda xatolik: $e');
    }
  }
}
// =============================================================================
// FILE END: lib/services/script_executor.dart
// =============================================================================