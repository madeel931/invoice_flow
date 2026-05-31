import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PdfLanguageCubit extends Cubit<String> {
  static const _pdfLanguageKey = 'pdf_language_preference';

  PdfLanguageCubit(super.initialLanguage);

  Future<void> changePdfLanguage(String code) async {
    final prefs = await SharedPreferences.getInstance();
    emit(code);
    await prefs.setString(_pdfLanguageKey, code);
  }
}
