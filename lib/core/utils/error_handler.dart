import 'package:flutter/material.dart';

import '../errors/failures.dart';
import '../constants/app_strings.dart';

class ErrorHandler {
  static void showSnackBar(BuildContext context, String message, {bool isError = true}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Theme.of(context).colorScheme.error : null,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  static void handleFailure(BuildContext context, Failure failure) {
    String message = AppStrings.unknownError;
    
    if (failure is DatabaseFailure) {
      message = failure.message;
    }
    // Handle other types of failures here
    
    showSnackBar(context, message);
  }
}
