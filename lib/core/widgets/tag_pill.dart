// =============================================================================
// FILE START: lib/core/widgets/tag_pill.dart
// =============================================================================
/// Kichik yorliq (OS / kategoriya) kapsulasi.
library;

import 'package:kompyuter_sirlari/imports.dart';

class TagPill extends StatelessWidget {
  const TagPill({super.key, required this.label, this.color});

  final String label;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: color ?? Theme.of(context).colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }
}
// =============================================================================
// FILE END: lib/core/widgets/tag_pill.dart
// =============================================================================