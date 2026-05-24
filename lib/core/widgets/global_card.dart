import 'package:flutter/material.dart';

class GlobalCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;

  const GlobalCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16.0),
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final card = Card(
      // Relying on AppTheme for color, shape, and elevation
      child: Padding(
        padding: padding,
        child: child,
      ),
    );

    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius:
            BorderRadius.circular(16), // Must match AppTheme CardTheme
        child: card,
      );
    }

    return card;
  }
}
