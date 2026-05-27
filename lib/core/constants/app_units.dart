import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';

class AppUnit {
  final String value;
  final String label;

  const AppUnit({
    required this.value,
    required this.label,
  });
}

/// Centralized registry for item measurement units.
/// Raw lowercase `value` is stored in the local database.
/// Capitalized `label` is presented in the UI to ensure a professional look.
class AppUnits {
  AppUnits._();

  static const String defaultUnit = 'piece';

  // To add a new unit across the entire app, simply add an AppUnit to this list.
  static const List<AppUnit> all = [
    AppUnit(value: 'piece', label: 'Piece'),
    AppUnit(value: 'hour', label: 'Hour'),
    AppUnit(value: 'day', label: 'Day'),
    AppUnit(value: 'project', label: 'Project'),
    AppUnit(value: 'service', label: 'Service'),
    AppUnit(value: 'kg', label: 'Kilogram'),
    AppUnit(value: 'gram', label: 'Gram'),
    AppUnit(value: 'liter', label: 'Liter'),
    AppUnit(value: 'meter', label: 'Meter'),
    AppUnit(value: 'km', label: 'Kilometer'),
    AppUnit(value: 'box', label: 'Box'),
    AppUnit(value: 'pack', label: 'Pack'),
    AppUnit(value: 'set', label: 'Set'),
  ];

  static bool contains(String? value) {
    if (value == null || value.trim().isEmpty) return false;
    final normalized = value.trim().toLowerCase();
    return all.any((unit) => unit.value == normalized);
  }

  static String normalize(String? value) {
    if (value == null || value.trim().isEmpty) return defaultUnit;
    final normalized = value.trim().toLowerCase();
    return contains(normalized) ? normalized : defaultUnit;
  }

  static String labelOf(String? value) {
    final normalized = normalize(value);
    return all.firstWhere((unit) => unit.value == normalized).label;
  }

  static String localizedLabelOf(BuildContext context, String? value) {
    final normalized = normalize(value);
    final localizations = AppLocalizations.of(context);
    switch (normalized) {
      case 'piece':
        return localizations?.unitPiece ?? 'Piece';
      case 'hour':
        return localizations?.unitHour ?? 'Hour';
      case 'day':
        return localizations?.unitDay ?? 'Day';
      case 'project':
        return localizations?.unitProject ?? 'Project';
      case 'service':
        return localizations?.unitService ?? 'Service';
      case 'kg':
        return localizations?.unitKg ?? 'Kilogram';
      case 'gram':
        return localizations?.unitGram ?? 'Gram';
      case 'liter':
        return localizations?.unitLiter ?? 'Liter';
      case 'meter':
        return localizations?.unitMeter ?? 'Meter';
      case 'km':
        return localizations?.unitKm ?? 'Kilometer';
      case 'box':
        return localizations?.unitBox ?? 'Box';
      case 'pack':
        return localizations?.unitPack ?? 'Pack';
      case 'set':
        return localizations?.unitSet ?? 'Set';
      default:
        return labelOf(value);
    }
  }

  static IconData iconOf(String? value) {
    final normalized = normalize(value);

    switch (normalized) {
      case 'kg':
      case 'gram':
        return Icons.scale_outlined;
      case 'liter':
        return Icons.water_drop_outlined;
      case 'meter':
      case 'km':
        return Icons.straighten_outlined;
      case 'hour':
        return Icons.schedule_outlined;
      case 'day':
        return Icons.calendar_today_outlined;
      case 'project':
        return Icons.assignment_outlined;
      case 'service':
        return Icons.handyman_outlined;
      case 'box':
      case 'pack':
        return Icons.inventory_2_outlined;
      case 'set':
        return Icons.category_outlined;
      case 'piece':
      default:
        return Icons.inventory_outlined;
    }
  }
}
