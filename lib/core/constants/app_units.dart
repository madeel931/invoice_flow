class AppUnit {
  final String value;
  final String label;

  const AppUnit({
    required this.value,
    required this.label,
  });
}

class AppUnits {
  AppUnits._();

  static const String defaultUnit = 'piece';

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
}
