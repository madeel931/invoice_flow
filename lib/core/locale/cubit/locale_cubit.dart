import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleCubit extends Cubit<Locale?> {
  static const _localeKey = 'app_locale_code';

  LocaleCubit() : super(null) {
    _loadLocale();
  }

  Future<void> _loadLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final localeString = prefs.getString(_localeKey);

    if (localeString == 'en') {
      emit(const Locale('en'));
    } else if (localeString == 'ar') {
      emit(const Locale('ar'));
    } else if (localeString == 'ur') {
      emit(const Locale('ur'));
    } else {
      emit(null); // system default
    }
  }

  Future<void> changeLocale(String code) async {
    final prefs = await SharedPreferences.getInstance();
    
    if (code == 'en') {
      emit(const Locale('en'));
      await prefs.setString(_localeKey, 'en');
    } else if (code == 'ar') {
      emit(const Locale('ar'));
      await prefs.setString(_localeKey, 'ar');
    } else if (code == 'ur') {
      emit(const Locale('ur'));
      await prefs.setString(_localeKey, 'ur');
    } else {
      emit(null);
      await prefs.setString(_localeKey, 'system');
    }
  }

  // Helper method to get the current string value for the UI dropdown
  String get currentCode {
    if (state?.languageCode == 'en') return 'en';
    if (state?.languageCode == 'ar') return 'ar';
    if (state?.languageCode == 'ur') return 'ur';
    return 'system';
  }
}
