import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:google_fonts/google_fonts.dart';

import 'adapters/category_adapter.dart';
import 'adapters/guide_adapter.dart';
import 'adapters/subject_adapter.dart';
import 'services/data_service.dart';
import 'services/pdf_service.dart';
import 'services/preload_manager.dart';
import 'screens/splash_screen.dart';
import 'screens/error_screen.dart';
import 'screens/main_app_screen.dart';
import 'screens/onboarding_screen.dart';
import 'utils/constants.dart';
import 'utils/responsive_utils.dart';

Future<void> initHive() async {
  await Hive.initFlutter();
  Hive.registerAdapter(SubjectAdapter());
  Hive.registerAdapter(CategoryAdapter());
  Hive.registerAdapter(GuideAdapter());

  await Hive.openBox(hiveSettingsBoxName);
  await DataService().init();
  await PdfService().init();
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await initHive();
    runApp(const UstaMakonAppLoader());
  } catch (e) {
    runApp(MaterialApp(
      home: Scaffold(
        body: Center(child: Text('Ilovani ishga tushirishda xatolik: $e')),
      ),
    ));
  }
}

class UstaMakonAppLoader extends StatefulWidget {
  const UstaMakonAppLoader({super.key});

  @override
  State<UstaMakonAppLoader> createState() => _UstaMakonAppLoaderState();
}

class _UstaMakonAppLoaderState extends State<UstaMakonAppLoader> {
  final PreloadManager _preloadManager = PreloadManager();
  bool _isPreloading = true;
  bool _showOnboarding = false;

  @override
  void initState() {
    super.initState();
    _checkOnboardingAndPreload();

    _preloadManager.error.addListener(() {
      if (mounted) setState(() {});
    });
  }

Future<void> _checkOnboardingAndPreload() async {
  if (!Hive.isBoxOpen(hiveSettingsBoxName)) {
    await Hive.openBox(hiveSettingsBoxName);
  }

  final settingsBox = Hive.box(hiveSettingsBoxName);
  final onboardingDoneRaw = settingsBox.get(onboardingDoneKey);
  final onboardingDone = onboardingDoneRaw is bool ? onboardingDoneRaw : false;

  if (!onboardingDone) {
    if (mounted) {
      setState(() {
        _showOnboarding = true;
        _isPreloading = false;
      });
    }
    return;
  }
  _startPreload();
}

Future<void> _startPreload() async {
  if (mounted) {
    setState(() {
      _isPreloading = true;
      _showOnboarding = false;
    });
  }

  if (!Hive.isBoxOpen(hiveSettingsBoxName)) {
    await Hive.openBox(hiveSettingsBoxName);
  }

  final settingsBox = Hive.box(hiveSettingsBoxName);
  bool forceRefresh = false;

  final lastPreloadRaw = settingsBox.get(lastSuccessfulPreloadKey);
  String? lastPreloadString = lastPreloadRaw is String ? lastPreloadRaw : null;

  if (lastPreloadString != null) {
    final lastPreloadTime = DateTime.tryParse(lastPreloadString);
    if (lastPreloadTime != null &&
        DateTime.now().difference(lastPreloadTime).inHours > 24) {
      forceRefresh = true;
    }
  } else {
    forceRefresh = true;
  }

  await _preloadManager.preloadAllData(forceRefresh: forceRefresh);
  if (mounted) {
    setState(() {
      _isPreloading = false;
    });
  }
}


  void _onOnboardingComplete() {
    final settingsBox = Hive.box(hiveSettingsBoxName);
    settingsBox.put(onboardingDoneKey, true);
    _startPreload();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        fontFamily: GoogleFonts.inter().fontFamily,
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF114390),
          iconTheme: IconThemeData(color: Colors.white),
          centerTitle: true,
          elevation: 0,
          titleTextStyle:
              TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
        ),
        cardTheme: CardThemeData(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
          ),
          elevation: 4,
          margin: EdgeInsets.all(8.0), // responsiveSize dan oldin default
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
            textStyle: const TextStyle(fontSize: 16.0),
          ),
        ),
        textTheme: TextTheme(
          headlineSmall: TextStyle(fontSize: responsiveTextSize(context, 24.0)),
          titleLarge: TextStyle(fontSize: responsiveTextSize(context, 20.0)),
          titleMedium: TextStyle(fontSize: responsiveTextSize(context, 18.0)),
          bodyLarge: TextStyle(fontSize: responsiveTextSize(context, 16.0)),
          bodyMedium: TextStyle(fontSize: responsiveTextSize(context, 14.0)),
          bodySmall: TextStyle(fontSize: responsiveTextSize(context, 12.0)),
        ),
      ),
      home: _showOnboarding
          ? OnboardingScreen(onDone: _onOnboardingComplete)
          : (_isPreloading
              ? SplashScreen(preloadManager: _preloadManager, onRetry: _startPreload)
              : (_preloadManager.error.value != null
                  ? ErrorScreen(preloadManager: _preloadManager, onRetry: _startPreload)
                  : const MainAppScreen())),
    );
  }
}