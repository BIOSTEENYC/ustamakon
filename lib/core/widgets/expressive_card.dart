// =============================================================================
// FILE START: lib/core/widgets/expressive_card.dart
// =============================================================================
/// M3 Expressive — qayta ishlatiladigan yumaloq kontent konteyneri.
library;


import 'package:kompyuter_sirlari/imports.dart';

class ExpressiveCard extends StatelessWidget {
  const ExpressiveCard({
    super.key,
    required this.child,
    this.color,
    this.radius = 24,
    this.padding = const EdgeInsets.all(16),
    this.border,
  });

  final Widget child;
  final Color? color;
  final double radius;
  final EdgeInsetsGeometry padding;
  final Border? border;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: color ?? Theme.of(context).colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(radius),
        border: border,
      ),
      child: child,
    );
  }
}
// =============================================================================
// FILE END: lib/core/widgets/expressive_card.dart
// =============================================================================
