// =============================================================================
// FILE START: lib/features/remote/presentation/remote_flow.dart
// =============================================================================

import 'package:kompyuter_sirlari/imports.dart';

enum AppStage { splash, language, connection, main }

/// Android pult — sahna mashinasi (splash → til → ulanish → asosiy).
class RemoteFlow extends StatefulWidget {
  const RemoteFlow({super.key});

  @override
  State<RemoteFlow> createState() => RemoteFlowState();
}

class RemoteFlowState extends State<RemoteFlow> {
  AppStage _currentStage = AppStage.splash;
  String _selectedLang = defaultLanguageCode;
  String? _engineUrl;
  int _activeTab = 1;

  bool _isFirstRun = true;
  VideoPlayerController? _videoController;

  String _cpuUsage = 'N/A';
  String _ramUsage = 'N/A';
  Timer? _monitoringTimer;

  List<AppScript> _scripts = [];
  bool _isLoadingScripts = false;

  String _activeScriptTitle = 'Skript tanlanmagan';
  String _activeScriptCode =
      "# Pult oynasidan yoki Xizmatlar bo'limidan skript tanlang";
  final List<String> _terminalLogs = [
    '> System initialized...',
    '> Ready for remote commands.',
  ];

  @override
  void initState() {
    super.initState();
    _loadPreferencesAndInit();

    // Monitoring har 3 soniyada yangilanadi
    _monitoringTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (_engineUrl != null && _currentStage == AppStage.main) {
        _fetchHardwareStats();
      }
    });
  }

  @override
  void dispose() {
    _monitoringTimer?.cancel();
    _videoController?.dispose();
    super.dispose();
  }

  String _t(String key) => tr(_selectedLang, key);

  // ───────────────────────── 1. Boshlang'ich yuklash ─────────────────────────
  Future<void> _loadPreferencesAndInit() async {
    _selectedLang = await SettingsRepository.instance.getLanguage();
    _isFirstRun = await SettingsRepository.instance.isFirstRun();
    AppLocaleController.instance.setLanguage(_selectedLang);
    if (mounted) setState(() {});

    if (_isFirstRun) {
      _videoController = VideoPlayerController.asset('assets/intro.mp4');
      _videoController?.initialize().then((_) {
        if (mounted) {
          setState(() {});
          _videoController?.play();
        }
      }).catchError((_) {
        // Video yuklanishidagi xatolik ilovani to'xtatmaydi
      });

      // Video tugagach yoki 9 sekunddan keyin til oynasiga o'tiladi
      Future.delayed(const Duration(seconds: 9), () async {
        await SettingsRepository.instance.setFirstRun(false);
        if (mounted) {
          _videoController?.pause();
          setState(() => _currentStage = AppStage.language);
        }
      });
    } else {
      Future.delayed(const Duration(milliseconds: 2000), () {
        if (mounted) setState(() => _currentStage = AppStage.connection);
      });
    }
  }

  Future<void> _saveLanguage(String langCode) async {
    await SettingsRepository.instance.setLanguage(langCode);
    AppLocaleController.instance.setLanguage(langCode);
    if (mounted) setState(() => _selectedLang = langCode);
  }

  // ───────────────────────── 2. Real monitoring ─────────────────────────────
  Future<void> _fetchHardwareStats() async {
    final url = _engineUrl;
    if (url == null || url.trim().isEmpty) return;
    final stats = await EngineClient(url).fetchStats();
    if (mounted) {
      setState(() {
        _cpuUsage = stats.cpu;
        _ramUsage = stats.ram;
      });
    }
  }

  // ───────────────────────── 3. Bulut skriptlari ────────────────────────────
  Future<void> _fetchCloudScripts() async {
    setState(() => _isLoadingScripts = true);
    try {
      final scripts = await ScriptRepository.instance.fetchAll();
      if (mounted) {
        setState(() {
          _scripts = scripts;
          _isLoadingScripts = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingScripts = false);
        showAppSnack(context, "Skriptlarni yuklashda xatolik: $e", isError: true);
      }
    }
  }

  // ───────────────────────── 4. Engine-ga buyruq ────────────────────────────
  Future<void> _sendScriptToEngine(String code) async {
    final url = _engineUrl;
    if (url == null || url.trim().isEmpty) {
      showAppSnack(context, _t('status_disconnected'), isError: true);
      return;
    }

    final result = await EngineClient(url).runScript(code, onLog: _addTerminalLog);
    if (!mounted) return;

    switch (result.status) {
      case EngineRunStatus.success:
        showAppSnack(context, "✨ Buyruq kompyuterda muvaffaqiyatli bajarildi!");
        _fetchHardwareStats();
      case EngineRunStatus.httpError:
        showAppSnack(context, "Xatolik: HTTP ${result.httpCode}", isError: true);
      case EngineRunStatus.networkError:
        showAppSnack(context, _t('error_conn'), isError: true);
    }
  }

  void _addTerminalLog(String log) {
    setState(() {
      _terminalLogs.add(
        '[${DateTime.now().toString().substring(11, 19)}] $log',
      );
    });
  }

  // ───────────────────────── 5. Ulanish ─────────────────────────────────────
  void _connect(String url) {
    setState(() {
      _engineUrl = url;
      _currentStage = AppStage.main;
    });
    _fetchCloudScripts();
    _fetchHardwareStats();
  }

  void _goOffline() {
    setState(() => _currentStage = AppStage.main);
    _fetchCloudScripts();
  }

  // ───────────────────────── 6. QR skaner ───────────────────────────────────
  void _openQRScanner() {
    bool isScanned = false;
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => Scaffold(
          appBar: AppBar(title: Text(_t('qr_scan_title'))),
          body: MobileScanner(
            onDetect: (capture) {
              if (isScanned) return;
              for (final barcode in capture.barcodes) {
                final raw = barcode.rawValue;
                if (raw == null) continue;
                isScanned = true;
                Navigator.of(context).pop();
                _connect(raw);
                showAppSnack(context, "✨ Engine'ga muvaffaqiyatli ulanildi!");
                break;
              }
            },
          ),
        ),
      ),
    );
  }

  // ───────────────────────── 7. Terminal ────────────────────────────────────
  void _openTerminal() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.black,
      builder: (_) => TerminalSheet(
        logs: _terminalLogs,
        lang: _selectedLang,
        onSend: _sendScriptToEngine,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    switch (_currentStage) {
      case AppStage.splash:
        return RemoteSplashScreen(
          isFirstRun: _isFirstRun,
          videoController: _videoController,
          lang: _selectedLang,
        );
      case AppStage.language:
        return RemoteLanguageScreen(
          lang: _selectedLang,
          onSelect: _saveLanguage,
          onContinue: () => setState(() => _currentStage = AppStage.connection),
        );
      case AppStage.connection:
        return RemoteConnectionScreen(
          lang: _selectedLang,
          onConnect: _connect,
          onScanQr: _openQRScanner,
          onOffline: _goOffline,
          onLanguage: () => setState(() => _currentStage = AppStage.language),
        );
      case AppStage.main:
        return RemoteMainShell(
          lang: _selectedLang,
          activeTab: _activeTab,
          onTabChanged: (i) => setState(() => _activeTab = i),
          engineUrl: _engineUrl,
          cpu: _cpuUsage,
          ram: _ramUsage,
          scripts: _scripts,
          isLoadingScripts: _isLoadingScripts,
          activeScriptTitle: _activeScriptTitle,
          activeScriptCode: _activeScriptCode,
          onRefreshScripts: _fetchCloudScripts,
          onRefreshStats: _fetchHardwareStats,
          onGoToConnection: () => setState(() => _currentStage = AppStage.connection),
          onOpenTerminal: _openTerminal,
          onLanguage: () => setState(() => _currentStage = AppStage.language),
          onLoadToRemote: (script) {
            setState(() {
              _activeScriptTitle = script.titleFor(_selectedLang);
              _activeScriptCode = script.code;
              _activeTab = 1;
            });
            showAppSnack(context, "Xizmat Pultga yuklandi!");
          },
          onRunScript: _sendScriptToEngine,
        );
    }
  }
}
// =============================================================================
// FILE END: lib/features/remote/presentation/remote_flow.dart
// =============================================================================