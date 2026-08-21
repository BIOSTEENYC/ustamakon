// =============================================================================
// FILE START: lib/data/models/hardware_stats.dart
// =============================================================================
/// Desktop monitoring natijasi.
class HardwareStats {
  const HardwareStats({required this.cpu, required this.ram});

  const HardwareStats.offline() : cpu = 'Offline', ram = 'Offline';

  final String cpu;
  final String ram;
}
// =============================================================================
// FILE END: lib/data/models/hardware_stats.dart
// =============================================================================