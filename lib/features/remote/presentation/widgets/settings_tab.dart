// =============================================================================
// FILE START: lib/features/remote/presentation/widgets/settings_tab.dart
// =============================================================================
import 'package:kompyuter_sirlari/imports.dart';

/// TAB 2 — Sozlamalar (til, yuklab olish, maxfiylik, dasturchi).
class SettingsTab extends StatelessWidget {
  const SettingsTab({super.key, required this.lang, required this.onLanguage});

  final String lang;
  final VoidCallback onLanguage;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final currentLang =
        supportedLanguages.firstWhere((l) => l.code == lang);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            tr(lang, 'tab_settings'),
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 20),

          // Til sozlamasi
          ListTile(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            tileColor: colorScheme.surfaceContainerHigh,
            leading: const Icon(Icons.language_rounded),
            title: Text(tr(lang, 'app_lang')),
            subtitle: Text(currentLang.label),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: onLanguage,
          ),
          const SizedBox(height: 12),

          // Desktop yuklab olish
          ListTile(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            tileColor: colorScheme.surfaceContainerHigh,
            leading: const Icon(Icons.download_rounded),
            title: Text(tr(lang, 'download_desktop_tile')),
            subtitle: const Text('Telegram / Veb-Sayt'),
            trailing: const Icon(Icons.open_in_new_rounded),
            onTap: () => _showDownloadDialog(context),
          ),
          const SizedBox(height: 24),

          Text(
            'Hujjatlar & Maxfiylik',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),

          // Maxfiylik siyosati
          ListTile(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            tileColor: colorScheme.surfaceContainerHigh,
            leading: const Icon(Icons.privacy_tip_rounded),
            title: Text(tr(lang, 'privacy_policy')),
            subtitle: const Text('tap to open external browser'),
            onTap: () => launchUrl(Uri.parse(AppLinks.privacyPolicy)),
          ),
          const SizedBox(height: 24),

          // Dasturchi kartasi
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(28),
            ),
            child: Column(
              children: [
                const CircleAvatar(
                  radius: 30,
                  child: Icon(Icons.person_rounded, size: 36),
                ),
                const SizedBox(height: 12),
                Text(
                  AppMeta.brandName,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: colorScheme.onPrimaryContainer,
                  ),
                ),
                Text(
                  tr(lang, 'developer_title'),
                  style: TextStyle(
                    color: colorScheme.onPrimaryContainer.withValues(alpha: 0.8),
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  tr(lang, 'brand_desc'),
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showDownloadDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(tr(lang, 'download_desktop_tile')),
        content: const Text('Qaysi manbadan yuklab olishni xohlaysiz?'),
        actions: [
          TextButton.icon(
            onPressed: () {
              Navigator.pop(context);
              launchUrl(Uri.parse(AppLinks.telegramDownload));
            },
            icon: const Icon(Icons.telegram),
            label: const Text('Telegram'),
          ),
          TextButton.icon(
            onPressed: () {
              Navigator.pop(context);
              launchUrl(Uri.parse(AppLinks.websiteDownload));
            },
            icon: const Icon(Icons.public),
            label: const Text('Veb Sayt'),
          ),
        ],
      ),
    );
  }
}
// =============================================================================
// FILE END: lib/features/remote/presentation/widgets/settings_tab.dart
// =============================================================================