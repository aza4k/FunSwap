import 'dart:io';
import 'dart:isolate';
import 'package:image/image.dart' as img;
import 'package:path/path.dart' as p;
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:funswap/core/conversion/conversion_registry.dart';
import 'package:funswap/core/errors/exceptions.dart';
import 'package:funswap/core/errors/file_system_exception_mapper.dart';
import 'package:funswap/core/services/file_service.dart';

abstract class ImageConversionLocalDataSource {
  Future<File> convertImage({
    required File inputFile,
    required String outputFormat,
  });

  @Deprecated('Use convertImage instead')
  Future<File> convertImageToWebP({
    required File inputFile,
    required String outputDirectory,
  });
}

class ImageConversionLocalDataSourceImpl implements ImageConversionLocalDataSource {
  @override
  Future<File> convertImage({
    required File inputFile,
    required String outputFormat,
  }) async {
    try {
      final formatLower = outputFormat.toLowerCase();
      if (!ConversionRegistry.isSupportedOutput(
        category: ConversionCategory.image,
        inputPath: inputFile.path,
        outputFormat: formatLower,
      )) {
        throw UnsupportedFormatException('Unsupported image conversion to $outputFormat');
      }

      final funSwapPath = await FileService.getFunSwapPath();
      final fileName = FileService.generateFileName(formatLower);
      final outputFile = File(p.join(funSwapPath, fileName));

      final outputBytes = formatLower == 'webp'
          ? await _encodeWebP(inputFile)
          : await Isolate.run(
              () => _encodeImageFile(
                inputFile.path,
                formatLower,
              ),
            );

      await outputFile.writeAsBytes(outputBytes);
      return outputFile;
    } on ConversionException {
      rethrow;
    } on UnsupportedFormatException {
      rethrow;
    } on PermissionException {
      rethrow;
    } on LowStorageException {
      rethrow;
    } on FileSystemException catch (e) {
      throwMappedFileSystemException(e, 'Could not write converted image');
    } catch (e) {
      throw ConversionException('Error during image conversion: $e');
    }
  }

  @Deprecated('Use convertImage instead')
  @override
  Future<File> convertImageToWebP({
    required File inputFile,
    required String outputDirectory,
  }) async {
    return await convertImage(
      inputFile: inputFile,
      outputFormat: 'webp',
    );
  }

  static List<int> _encodeImageFile(String inputPath, String outputFormat) {
    final inputBytes = File(inputPath).readAsBytesSync();
    final image = img.decodeImage(inputBytes);

    if (image == null) {
      throw const ConversionException(
        'Failed to decode image: invalid image format',
      );
    }

    img.Image finalImage = image;
    if (outputFormat == 'ico') {
      if (image.width > 256 || image.height > 256) {
        if (image.width > image.height) {
          finalImage = img.copyResize(image, width: 256);
        } else {
          finalImage = img.copyResize(image, height: 256);
        }
      }
    }

    return switch (outputFormat) {
      'png' => img.encodePng(finalImage),
      'jpg' || 'jpeg' => img.encodeJpg(finalImage, quality: 90),
      'gif' => img.encodeGif(finalImage),
      'bmp' => img.encodeBmp(finalImage),
      'tiff' || 'tif' => img.encodeTiff(finalImage),
      'ico' => img.encodeIco(finalImage),
      _ => throw ConversionException(
          'Unsupported output format: $outputFormat',
        ),
    };
  }

  Future<List<int>> _encodeWebP(File inputFile) async {
    final outputBytes = await FlutterImageCompress.compressWithFile(
      inputFile.path,
      format: CompressFormat.webp,
      quality: 90,
      minWidth: 1,
      minHeight: 1,
    );

    if (outputBytes == null || outputBytes.isEmpty) {
      throw const ConversionException('Failed to encode image as WebP');
    }

    return outputBytes;
  }
}
