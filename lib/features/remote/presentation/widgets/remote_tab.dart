// =============================================================================
// FILE START: lib/features/remote/presentation/widgets/remote_tab.dart
// =============================================================================
import 'package:kompyuter_sirlari/imports.dart';

/// TAB 1 — Pult (ulanish holati + monitoring + aktiv skript ijrochisi).
class RemoteTab extends StatelessWidget {
  const RemoteTab({
    super.key,
    required this.lang,
    required this.engineUrl,
    required this.cpu,
    required this.ram,
    required this.activeTitle,
    required this.activeCode,
    required this.onRun,
    required this.onGoToConnection,
    required this.onRefreshStats,
    required this.onOpenTerminal,
  });

  final String lang;
  final String? engineUrl;
  final String cpu;
  final String ram;
  final String activeTitle;
  final String activeCode;
  final ValueChanged<String> onRun;
  final VoidCallback onGoToConnection;
  final VoidCallback onRefreshStats;
  final VoidCallback onOpenTerminal;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final connected = engineUrl != null;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Ulanish holati kapsulasi
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: connected
                  ? colorScheme.primaryContainer
                  : colorScheme.errorContainer,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Row(
              children: [
                Icon(
                  connected
                      ? Icons.check_circle_rounded
                      : Icons.error_outline_rounded,
                  color: connected
                      ? colorScheme.onPrimaryContainer
                      : colorScheme.onErrorContainer,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    connected
                        ? '${tr(lang, 'status_connected')}$engineUrl'
                        : tr(lang, 'status_disconnected'),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: connected
                          ? colorScheme.onPrimaryContainer
                          : colorScheme.onErrorContainer,
                    ),
                  ),
                ),
                IconButton(
                  tooltip: tr(lang, 'qr_scan_title'),
                  icon: const Icon(Icons.qr_code_scanner_rounded),
                  onPressed: onGoToConnection,
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                tr(lang, 'monitoring_title'),
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
              ),
              IconButton(
                tooltip: tr(lang, 'monitoring_title'),
                icon: const Icon(Icons.refresh_rounded, size: 20),
                onPressed: onRefreshStats,
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Live ko'rsatkichlar
          Row(
            children: [
              Expanded(
                child: GaugeCard(
                  label: 'CPU',
                  value: cpu,
                  icon: Icons.memory_rounded,
                  accent: colorScheme.tertiary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: GaugeCard(
                  label: 'RAM',
                  value: ram,
                  icon: Icons.developer_board_rounded,
                  accent: colorScheme.secondary,
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),
          Text(
            tr(lang, 'active_executor'),
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 12),

          // Aktiv skript ijrochisi
          ExpressiveCard(
            radius: 28,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.bolt_rounded, color: colorScheme.primary),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        activeTitle,
                        style: const TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    activeCode,
                    maxLines: 4,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: FilledButton.icon(
                    onPressed: () => onRun(activeCode),
                    icon: const Icon(Icons.play_arrow_rounded),
                    label: Text(tr(lang, 'run_on_pc')),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: OutlinedButton.icon(
              onPressed: onOpenTerminal,
              icon: const Icon(Icons.terminal_rounded),
              label: Text(
                tr(lang, 'manual_terminal'),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
// =============================================================================
// FILE END: lib/features/remote/presentation/widgets/remote_tab.dart
// =============================================================================