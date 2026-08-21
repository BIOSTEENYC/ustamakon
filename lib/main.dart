// =============================================================================
// FILE START: lib/main.dart
// =============================================================================

import 'imports.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: SupabaseConfig.url,
    publishableKey: SupabaseConfig.anonKey,
  );
  runApp(const UstaMakonApp());
}

/// Ildiz widget: platformaga qarab tegishli ekranni ochadi.
class UstaMakonApp extends StatelessWidget {
  const UstaMakonApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: AppLocaleController.instance.languageCode,
      builder: (context, lang, _) => MaterialApp(
        debugShowCheckedModeBanner: false,
        title: AppMeta.appName,
        theme: AppTheme.light(fontFamily: AppFonts.forLanguage(lang)),
        // af (Arab yozuvli o'zbek) tanlanganda butun ilova RTL rejimga o'tadi
        builder: (context, child) => Directionality(
          textDirection: lang == rtlLanguageCode
              ? TextDirection.rtl
              : TextDirection.ltr,
          child: child!,
        ),
        home: _platformHome(),
      ),
    );
  }

  Widget _platformHome() {
    if (kIsWeb) return const AdminLoginScreen();
    if (Platform.isWindows || Platform.isLinux) return const EngineScreen();
    if (Platform.isAndroid) return const RemoteFlow();
    return const Scaffold(
      body: Center(child: Text("Qo'llab-quvvatlanmaydigan platforma")),
    );
  }
}
// =============================================================================
// FILE END: lib/main.dart
// =============================================================================