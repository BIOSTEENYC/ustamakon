// =============================================================================
// FILE START: lib/core/utils/snack.dart
// =============================================================================
/// M3 Expressive uslubidagi yagona floating SnackBar.
library;


import 'package:kompyuter_sirlari/imports.dart';

void showAppSnack(
  BuildContext context,
  String message, {
  bool isError = false,
  IconData? icon,
  Duration duration = const Duration(seconds: 4),
}) {
  final scheme = Theme.of(context).colorScheme;
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      behavior: SnackBarBehavior.floating,
      duration: duration,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: isError ? scheme.error : scheme.primaryContainer,
      content: Row(
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              color: isError ? scheme.onError : scheme.onPrimaryContainer,
            ),
            const SizedBox(width: 8),
          ],
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: isError ? scheme.onError : scheme.onPrimaryContainer,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
// =============================================================================
// FILE END: lib/core/utils/snack.dart
// =============================================================================
