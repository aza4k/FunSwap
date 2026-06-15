import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:funswap/core/errors/exceptions.dart';

class FileService {
  static Future<Directory> getFunSwapDirectory() async {
    final baseDirectory = await _getWritableBaseDirectory();
    final funSwapDir = Directory(p.join(baseDirectory.path, 'FunSwap'));

    try {
      if (!await funSwapDir.exists()) {
        await funSwapDir.create(recursive: true);
      }
      await _verifyWritable(funSwapDir);
    } catch (e) {
      throw PermissionException('Could not create FunSwap directory: $e');
    }
    return funSwapDir;
  }

  static String generateFileName(String outputFormat) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final uniqueId = timestamp.toString().substring(timestamp.toString().length - 6);
    return 'FunSwap_$uniqueId.$outputFormat';
  }

  static Future<File> saveFile({
    required File file,
    required String fileName,
  }) async {
    final funSwapDir = await getFunSwapDirectory();
    final outputFile = File(p.join(funSwapDir.path, fileName));
    
    if (await file.exists()) {
      return await file.copy(outputFile.path);
    }
    throw const FilePickerException('Source file does not exist');
  }

  static Future<String> getFunSwapPath() async {
    final dir = await getFunSwapDirectory();
    return dir.path;
  }

  static Future<Directory> _getWritableBaseDirectory() async {
    if (Platform.isAndroid) {
      try {
        // Request storage permissions before attempting to write
        if (await Permission.manageExternalStorage.request().isGranted) {
          // Permission granted
        } else {
          await Permission.storage.request();
        }
      } catch (_) {}

      final externalDirectory = await getExternalStorageDirectory();
      if (externalDirectory != null) {
        final path = externalDirectory.path;
        final androidIndex = path.indexOf('/Android');
        if (androidIndex != -1) {
          final rootPath = path.substring(0, androidIndex);
          
          // 1. Try primary storage root folder /storage/emulated/0
          final rootDir = Directory(rootPath);
          try {
            final testDir = Directory(p.join(rootDir.path, 'FunSwap'));
            if (!await testDir.exists()) {
              await testDir.create(recursive: true);
            }
            await _verifyWritable(testDir);
            return rootDir;
          } catch (_) {
            // 2. Try Download folder /storage/emulated/0/Download
            final downloadDir = Directory(p.join(rootPath, 'Download'));
            try {
              final testDir = Directory(p.join(downloadDir.path, 'FunSwap'));
              if (!await testDir.exists()) {
                await testDir.create(recursive: true);
              }
              await _verifyWritable(testDir);
              return downloadDir;
            } catch (_) {
              // 3. Fallback to Documents
              final documentsDir = Directory(p.join(rootPath, 'Documents'));
              try {
                final testDir = Directory(p.join(documentsDir.path, 'FunSwap'));
                if (!await testDir.exists()) {
                  await testDir.create(recursive: true);
                }
                return documentsDir;
              } catch (_) {}
            }
          }
        }
        return externalDirectory;
      }
    }

    final documentsDirectory = await getApplicationDocumentsDirectory();
    return documentsDirectory;
  }

  static Future<void> _verifyWritable(Directory directory) async {
    final probe = File(
      p.join(
        directory.path,
        '.write_probe_${DateTime.now().microsecondsSinceEpoch}',
      ),
    );
    await probe.writeAsString('ok', flush: true);
    await probe.delete();
  }
}
