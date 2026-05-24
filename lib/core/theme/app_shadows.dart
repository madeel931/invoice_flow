import 'package:flutter/material.dart';

class AppShadows {
  static final List<BoxShadow> light = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.05),
      blurRadius: 10,
      offset: const Offset(0, 4),
    ),
  ];

  static final List<BoxShadow> medium = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.1),
      blurRadius: 15,
      offset: const Offset(0, 8),
    ),
  ];

  static final List<BoxShadow> dark = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.2),
      blurRadius: 10,
      offset: const Offset(0, 4),
    ),
  ];
}
