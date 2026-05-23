import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

class AppDirectories {
  static late final String documentsDir;

  static Future<void> init() async {
    final dir = await getApplicationDocumentsDirectory();
    documentsDir = dir.path;
  }

  /// Constructs an absolute, update-safe path for the current app session.
  static String constructImagePath(String fileName) {
    return p.join(documentsDir, fileName);
  }
}
