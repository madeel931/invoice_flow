import 'dart:io';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

class ImageCompressor {
  /// Compresses and resizes an image file optimally for PDF generation.
  /// Target: Width ~500px, JPEG format, ~85% quality.
  static Future<File?> compressForLogo(File originalFile) async {
    try {
      final tempDir = await getTemporaryDirectory();

      // Generate a unique temporary path for the compressed output
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final targetPath = p.join(tempDir.path, 'logo_compressed_$timestamp.jpg');

      // Compress and resize the image
      // XFile is returned in newer versions of flutter_image_compress
      final compressedXFile = await FlutterImageCompress.compressAndGetFile(
        originalFile.absolute.path,
        targetPath,
        quality: 85, // 85% is the sweet spot for visual fidelity vs size
        minWidth: 500, // Resizes large photos down to a max width of 500px
        minHeight: 500, // Maintains aspect ratio, caps height at 500px
        format:
            CompressFormat.jpeg, // Enforce JPEG to drop transparent PNG bloat
      );

      if (compressedXFile != null) {
        return File(compressedXFile.path);
      }

      return null; // Compression failed, return null
    } catch (e) {
      // If compression fails due to an unsupported format (like raw), return the original
      return originalFile;
    }
  }
}
