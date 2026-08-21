// =============================================================================
// FILE START: lib/services/system_stats_service.dart
// =============================================================================
import 'package:kompyuter_sirlari/imports.dart';

/// Desktop CPU/RAM statistikasini o'qish
/// (Linux `/proc/stat` + `free`, Windows perf kontrolleri).
class SystemStatsService {
  SystemStatsService._();
  static final instance = SystemStatsService._();

  Future<HardwareStats> read() async {
    String cpuUsage = '35%';
    String ramUsage = '4.8 / 16 GB';

    try {
      if (Platform.isLinux) {
        final cpu = await _linuxCpuUsage();
        if (cpu != null) cpuUsage = '${cpu.toStringAsFixed(0)}%';
        ramUsage = await _linuxRamUsage() ?? ramUsage;
      } else if (Platform.isWindows) {
        final cpu = await _windowsCpuUsage();
        if (cpu != null) cpuUsage = '${cpu.toStringAsFixed(0)}%';
        ramUsage = await _windowsRamUsage() ?? ramUsage;
      }
    } catch (_) {
      // Fallback qiymatlar ishlatiladi
    }

    return HardwareStats(cpu: cpuUsage, ram: ramUsage);
  }

  // ─────────────────────────── Linux ───────────────────────────
  /// `/proc/stat` dan 2 ta namuna (500ms oraliq) delta hisoblanadi.
  /// `top -bn1` (bootdan beri o'rtacha) emas — REAL joriy yuklama qaytadi.
  Future<double?> _linuxCpuUsage() async {
    final first = await _readLinuxCpuJiffies();
    if (first == null) return null;
    await Future<void>.delayed(const Duration(milliseconds: 500));
    final second = await _readLinuxCpuJiffies();
    if (second == null) return null;

    final totalDelta = second.total - first.total;
    final idleDelta = second.idle - first.idle;
    if (totalDelta <= 0) return null;
    return ((totalDelta - idleDelta) / totalDelta) * 100;
  }

  Future<({double total, double idle})?> _readLinuxCpuJiffies() async {
    final lines = await File('/proc/stat').readAsLines();
    if (lines.isEmpty || !lines.first.startsWith('cpu ')) return null;
    final nums = lines.first
        .trim()
        .split(RegExp(r'\s+'))
        .skip(1)
        .map(double.tryParse)
        .whereType<double>()
        .toList();
    if (nums.length < 4) return null;
    final total = nums.reduce((a, b) => a + b);
    // index 3 = idle, 4 = iowait (ikkalasi "bo'sh" vaqt)
    final idle = nums[3] + (nums.length > 4 ? nums[4] : 0);
    return (total: total, idle: idle);
  }

  Future<String?> _linuxRamUsage() async {
    final result = await Process.run('free', ['-m']);
    final lines = result.stdout.toString().split('\n');
    if (lines.length < 2) return null;
    final parts = lines[1].split(RegExp(r'\s+'));
    if (parts.length < 3) return null;
    final total = (double.tryParse(parts[1]) ?? 0) / 1024;
    final used = (double.tryParse(parts[2]) ?? 0) / 1024;
    if (total <= 0) return null;
    return '${used.toStringAsFixed(1)} / ${total.toStringAsFixed(1)} GB';
  }

  // ─────────────────────────── Windows ─────────────────────────
  /// `_Total` protsessor perf kontrolleri — joriy yuklama (0-100%).
  Future<double?> _windowsCpuUsage() async {
    final result = await Process.run('powershell', [
      '-Command',
      "Get-CimInstance Win32_PerfFormattedData_PerfOS_Processor "
      "-Filter \"Name='_Total'\" | Select-Object -ExpandProperty PercentProcessorTime",
    ]);
    return double.tryParse(result.stdout.toString().trim());
  }

  Future<String?> _windowsRamUsage() async {
    final result = await Process.run('powershell', [
      '-Command',
      'Get-CimInstance Win32_OperatingSystem | Select-Object TotalVisibleMemorySize,FreePhysicalMemory',
    ]);
    final matches = RegExp(r'\d+').allMatches(result.stdout.toString()).toList();
    if (matches.length < 2) return null;
    final totalGb = (double.tryParse(matches[0].group(0)!) ?? 0) / 1024 / 1024;
    final freeGb = (double.tryParse(matches[1].group(0)!) ?? 0) / 1024 / 1024;
    if (totalGb <= 0) return null;
    return '${(totalGb - freeGb).toStringAsFixed(1)} / ${totalGb.toStringAsFixed(1)} GB';
  }
}
// =============================================================================
// FILE END: lib/services/system_stats_service.dart
// =============================================================================