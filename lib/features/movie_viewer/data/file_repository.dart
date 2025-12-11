import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:movie_catalog/services/logger_service.dart';

class FileRepository {
  Future<File?> pickFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['epub', 'fb2'],
      );

      if (result != null && result.files.single.path != null) {
        return File(result.files.single.path!);
      }
      return null;
    } catch (e) {
      LoggerService.error('FileRepository: Error picking file: $e');
      return null;
    }
  }

  Future<File> saveFileToAppStorage(File file) async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final fileName = path.basename(file.path);
      final savedFile = await file.copy('${appDir.path}/$fileName');
      LoggerService.info('FileRepository: File saved to ${savedFile.path}');
      return savedFile;
    } catch (e) {
      LoggerService.error('FileRepository: Error saving file: $e');
      rethrow;
    }
  }

  String getFileFormat(String filePath) {
    final extension = path.extension(filePath).toLowerCase();
    return extension.replaceAll('.', '');
  }
}

