// =============================================================================
// FILE START: lib/core/widgets/gauge_card.dart
// =============================================================================
/// CPU/RAM kabi ko'rsatkichlar uchun kichik monitoring kartasi.
library;

import 'package:kompyuter_sirlari/imports.dart';

class GaugeCard extends StatelessWidget {
  const GaugeCard({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    required this.accent,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return ExpressiveCard(
      radius: 24,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: accent),
          const SizedBox(height: 12),
          Text(
            label,
            style: TextStyle(color: scheme.onSurfaceVariant, fontSize: 12),
          ),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
          ),
        ],
      ),
    );
  }
}
// =============================================================================
// FILE END: lib/core/widgets/gauge_card.dart
// =============================================================================