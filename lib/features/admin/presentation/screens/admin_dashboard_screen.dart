// =============================================================================
// FILE START: lib/features/admin/presentation/screens/admin_dashboard_screen.dart
// =============================================================================

import 'package:kompyuter_sirlari/imports.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  final GlobalKey<ScriptListCardState> _listKey = GlobalKey<ScriptListCardState>();

  Future<void> _saveScript(ScriptDraft draft) async {
    await ScriptRepository.instance.add(draft);
    _listKey.currentState?.refresh();
    if (!mounted) return;
    showAppSnack(context, "✨ Muvaffaqiyatli saqlandi!");
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isMobile = MediaQuery.of(context).size.width < 900;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        scrolledUnderElevation: 0,
        backgroundColor: colorScheme.surface,
        centerTitle: false,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                Icons.auto_awesome_rounded,
                color: colorScheme.onPrimaryContainer,
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'UstaMakon Expressive',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w900,
                letterSpacing: -0.5,
              ),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: IconButton.filledTonal(
              icon: const Icon(Icons.refresh_rounded),
              onPressed: () => _listKey.currentState?.refresh(),
              tooltip: 'Yangilash',
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(isMobile ? 12.0 : 20.0),
          child: isMobile
              ? SingleChildScrollView(
                  child: Column(
                    children: [
                      ScriptFormCard(onSaved: _saveScript),
                      const SizedBox(height: 20),
                      SizedBox(
                        height: 650,
                        child: ScriptListCard(key: _listKey),
                      ),
                    ],
                  ),
                )
              : Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 5,
                      child: SingleChildScrollView(
                        child: ScriptFormCard(onSaved: _saveScript),
                      ),
                    ),
                    const SizedBox(width: 24),
                    Expanded(
                      flex: 6,
                      child: ScriptListCard(key: _listKey),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
// =============================================================================
// FILE END: lib/features/admin/presentation/screens/admin_dashboard_screen.dart
// =============================================================================