// =============================================================================
// FILE START: lib/features/remote/presentation/screens/remote_connection_screen.dart
// =============================================================================
import 'package:kompyuter_sirlari/imports.dart';

/// 3-bosqich: Desktop-ga ulanish (QR skaner / qo'lda IP / offline).
class RemoteConnectionScreen extends StatefulWidget {
  const RemoteConnectionScreen({
    super.key,
    required this.lang,
    required this.onConnect,
    required this.onScanQr,
    required this.onOffline,
    required this.onLanguage,
  });

  final String lang;
  final ValueChanged<String> onConnect;
  final VoidCallback onScanQr;
  final VoidCallback onOffline;
  final VoidCallback onLanguage;

  @override
  State<RemoteConnectionScreen> createState() => _RemoteConnectionScreenState();
}

class _RemoteConnectionScreenState extends State<RemoteConnectionScreen> {
  final TextEditingController _ipInputController = TextEditingController();

  @override
  void dispose() {
    _ipInputController.dispose();
    super.dispose();
  }

  void _manualConnect() {
    final ip = _ipInputController.text.trim();
    if (ip.isNotEmpty) {
      widget.onConnect(ip);
    } else {
      showAppSnack(context, "IP manzilni kiriting!", isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final lang = widget.lang;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Text(tr(lang, 'pc_conn_title')),
        actions: [
          IconButton(
            tooltip: tr(lang, 'app_lang'),
            icon: const Icon(Icons.language_rounded),
            onPressed: widget.onLanguage,
          )
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Tavsif banneri
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: colorScheme.tertiaryContainer,
                  borderRadius: BorderRadius.circular(28),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.desktop_windows_rounded,
                      size: 36,
                      color: colorScheme.onTertiaryContainer,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        tr(lang, 'pc_conn_desc'),
                        style: TextStyle(
                          color: colorScheme.onTertiaryContainer,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              Text(
                tr(lang, 'download_desktop'),
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () =>
                          launchUrl(Uri.parse(AppLinks.telegramDownload)),
                      icon: const Icon(Icons.telegram_rounded),
                      label: const Text('Telegram'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () =>
                          launchUrl(Uri.parse(AppLinks.websiteDownload)),
                      icon: const Icon(Icons.public_rounded),
                      label: const Text('Veb Sayt'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 28),

              Text(
                tr(lang, 'choose_conn_method'),
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),

              // QR skaner kartasi
              InkWell(
                onTap: widget.onScanQr,
                borderRadius: BorderRadius.circular(28),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(28),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: colorScheme.primary,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.qr_code_scanner_rounded,
                          color: colorScheme.onPrimary,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              tr(lang, 'qr_scan_title'),
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: colorScheme.onPrimaryContainer,
                              ),
                            ),
                            Text(
                              tr(lang, 'qr_scan_desc'),
                              style: TextStyle(
                                color: colorScheme.onPrimaryContainer
                                    .withValues(alpha: 0.8),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 18,
                        color: colorScheme.onPrimaryContainer,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Qo'lda IP kiritsh
              ExpressiveCard(
                radius: 28,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tr(lang, 'manual_ip_title'),
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _ipInputController,
                      decoration: InputDecoration(
                        hintText: 'Masalan: 192.168.1.5:8080',
                        prefixIcon: const Icon(Icons.lan_rounded),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        filled: true,
                        fillColor: colorScheme.surfaceContainerLowest,
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.tonal(
                        onPressed: _manualConnect,
                        child: Text(tr(lang, 'manual_ip_btn')),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              Center(
                child: TextButton.icon(
                  onPressed: widget.onOffline,
                  icon: const Icon(Icons.play_arrow_rounded),
                  label: Text(tr(lang, 'offline_btn')),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
// =============================================================================
// FILE END: lib/features/remote/presentation/screens/remote_connection_screen.dart
// =============================================================================