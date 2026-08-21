// =============================================================================
// FILE START: lib/core/theme/app_theme.dart
// =============================================================================
/// Material 3 (M3 Expressive) yorug' mavzu — deepPurple seed.
library;


import 'package:kompyuter_sirlari/imports.dart';

class AppTheme {
  AppTheme._();
  static ThemeData light({String? fontFamily}) => ThemeData(
    useMaterial3: true,
    colorSchemeSeed: Colors.deepPurple,
    brightness: Brightness.light,
    fontFamily: fontFamily,
  );
}
// =============================================================================
// FILE END: lib/core/theme/app_theme.dart
// =============================================================================
