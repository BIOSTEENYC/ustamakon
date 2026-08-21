// =============================================================================
// FILE START: lib/features/remote/presentation/screens/remote_main_shell.dart
// =============================================================================

import 'package:kompyuter_sirlari/imports.dart';

/// 4-bosqich: asosiy qobiq — 3 tab (Xizmatlar / Pult / Sozlamalar).
class RemoteMainShell extends StatelessWidget {
  const RemoteMainShell({
    super.key,
    required this.lang,
    required this.activeTab,
    required this.onTabChanged,
    required this.engineUrl,
    required this.cpu,
    required this.ram,
    required this.scripts,
    required this.isLoadingScripts,
    required this.activeScriptTitle,
    required this.activeScriptCode,
    required this.onRefreshScripts,
    required this.onRefreshStats,
    required this.onGoToConnection,
    required this.onOpenTerminal,
    required this.onLoadToRemote,
    required this.onRunScript,
    required this.onLanguage,
  });

  final String lang;
  final int activeTab;
  final ValueChanged<int> onTabChanged;
  final String? engineUrl;
  final String cpu;
  final String ram;
  final List<AppScript> scripts;
  final bool isLoadingScripts;
  final String activeScriptTitle;
  final String activeScriptCode;
  final Future<void> Function() onRefreshScripts;
  final VoidCallback onRefreshStats;
  final VoidCallback onGoToConnection;
  final VoidCallback onOpenTerminal;
  final ValueChanged<AppScript> onLoadToRemote;
  final ValueChanged<String> onRunScript;
  final VoidCallback onLanguage;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: scheme.surface,
      body: SafeArea(
        child: IndexedStack(
          index: activeTab,
          children: [
            ServicesTab(
              lang: lang,
              scripts: scripts,
              isLoading: isLoadingScripts,
              onRefresh: onRefreshScripts,
              onLoadToRemote: onLoadToRemote,
            ),
            RemoteTab(
              lang: lang,
              engineUrl: engineUrl,
              cpu: cpu,
              ram: ram,
              activeTitle: activeScriptTitle,
              activeCode: activeScriptCode,
              onRun: onRunScript,
              onGoToConnection: onGoToConnection,
              onRefreshStats: onRefreshStats,
              onOpenTerminal: onOpenTerminal,
            ),
            SettingsTab(lang: lang, onLanguage: onLanguage),
          ],
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: activeTab,
        onDestinationSelected: onTabChanged,
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.grid_view_rounded),
            label: tr(lang, 'tab_services'),
          ),
          NavigationDestination(
            icon: const Icon(Icons.settings_remote_rounded),
            label: tr(lang, 'tab_remote'),
          ),
          NavigationDestination(
            icon: const Icon(Icons.tune_rounded),
            label: tr(lang, 'tab_settings'),
          ),
        ],
      ),
    );
  }
}
// =============================================================================
// FILE END: lib/features/remote/presentation/screens/remote_main_shell.dart
// =============================================================================