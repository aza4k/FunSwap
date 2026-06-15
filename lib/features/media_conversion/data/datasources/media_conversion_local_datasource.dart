import 'dart:async';
import 'dart:io';
import 'package:ffmpeg_kit_flutter_new/ffprobe_kit.dart';
import 'package:ffmpeg_kit_flutter_new/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter_new/return_code.dart';
import 'package:path/path.dart' as p;
import 'package:funswap/core/conversion/conversion_progress.dart';
import 'package:funswap/core/conversion/conversion_registry.dart';
import 'package:funswap/core/errors/exceptions.dart';
import 'package:funswap/core/errors/file_system_exception_mapper.dart';
import 'package:funswap/core/services/file_service.dart';

abstract class MediaConversionLocalDataSource {
  Future<File> convertMedia({
    required File inputFile,
    required String outputFormat,
    ConversionProgressCallback? onProgress,
  });

  Future<void> cancelActiveConversion();

  @Deprecated('Use convertMedia instead')
  Future<File> convertWavToMp3({
    required File inputFile,
    required String outputDirectory,
  });
}

class MediaConversionLocalDataSourceImpl implements MediaConversionLocalDataSource {
  int? _activeSessionId;

  @override
  Future<File> convertMedia({
    required File inputFile,
    required String outputFormat,
    ConversionProgressCallback? onProgress,
  }) async {
    try {
      final normalizedOutput = outputFormat.toLowerCase();
      if (!ConversionRegistry.isSupportedOutput(
        category: ConversionCategory.media,
        inputPath: inputFile.path,
        outputFormat: normalizedOutput,
      )) {
        throw UnsupportedFormatException(
          'Unsupported media conversion to $outputFormat',
        );
      }

      final funSwapPath = await FileService.getFunSwapPath();
      final fileName = FileService.generateFileName(normalizedOutput);
      final outputFile = File(p.join(funSwapPath, fileName));

      final durationMs = await _probeDurationMs(inputFile.path);
      final ffmpegArguments = _buildFfmpegArguments(
        inputPath: inputFile.path,
        outputPath: outputFile.path,
        outputFormat: normalizedOutput,
      );

      final completer = Completer<void>();
      final session = await FFmpegKit.executeWithArgumentsAsync(
        ffmpegArguments,
        (completedSession) {
          _activeSessionId = null;
          if (!completer.isCompleted) {
            completer.complete();
          }
        },
        null,
        (statistics) {
          if (durationMs == null || durationMs <= 0) {
            return;
          }
          final progress = statistics.getTime() / durationMs;
          onProgress?.call(progress.clamp(0, 0.99).toDouble());
        },
      );
      _activeSessionId = session.getSessionId();

      await completer.future;
      final returnCode = await session.getReturnCode();

      if (ReturnCode.isSuccess(returnCode)) {
        if (await outputFile.exists()) {
          onProgress?.call(1);
          return outputFile;
        } else {
          throw const ConversionException('FFmpeg completed successfully, but output file not found.');
        }
      } else if (ReturnCode.isCancel(returnCode)) {
        throw const ConversionException('FFmpeg process was cancelled.');
      } else {
        final error = await session.getAllLogsAsString();
        throw ConversionException('FFmpeg conversion failed: ${error ?? "Unknown error"}');
      }
    } on ConversionException {
      rethrow;
    } on UnsupportedFormatException {
      rethrow;
    } on PermissionException {
      rethrow;
    } on LowStorageException {
      rethrow;
    } on FileSystemException catch (e) {
      throwMappedFileSystemException(e, 'Could not write converted media file');
    } catch (e) {
      throw ConversionException('Error during media conversion: $e');
    }
  }

  @override
  Future<void> cancelActiveConversion() async {
    final sessionId = _activeSessionId;
    if (sessionId != null) {
      await FFmpegKit.cancel(sessionId);
      _activeSessionId = null;
    }
  }

  List<String> _buildFfmpegArguments({
    required String inputPath,
    required String outputPath,
    required String outputFormat,
  }) {
    switch (outputFormat) {
      // Audio formats
      case 'mp3':
        return ['-y', '-i', inputPath, '-vn', '-ar', '44100', '-ac', '2', '-b:a', '192k', outputPath];
      case 'wav':
        return ['-y', '-i', inputPath, '-vn', '-acodec', 'pcm_s16le', '-ar', '44100', '-ac', '2', outputPath];
      case 'aac':
        return ['-y', '-i', inputPath, '-vn', '-acodec', 'aac', '-ar', '44100', '-ac', '2', '-b:a', '128k', outputPath];
      case 'ogg':
      case 'oga':
        return ['-y', '-i', inputPath, '-vn', '-acodec', 'libvorbis', '-ar', '44100', '-ac', '2', '-b:a', '128k', outputPath];
      case 'flac':
        return ['-y', '-i', inputPath, '-vn', '-acodec', 'flac', '-ar', '44100', '-ac', '2', outputPath];
      case 'wma':
        return ['-y', '-i', inputPath, '-vn', '-acodec', 'wmav2', '-ar', '44100', '-ac', '2', '-b:a', '192k', outputPath];
      case 'opus':
        return ['-y', '-i', inputPath, '-vn', '-acodec', 'libopus', '-ar', '48000', '-ac', '2', '-b:a', '128k', outputPath];
      
      // Video formats
      case 'mp4':
        return ['-y', '-i', inputPath, '-vcodec', 'h264', '-acodec', 'aac', '-b:v', '1000k', '-b:a', '128k', outputPath];
      case 'avi':
        return ['-y', '-i', inputPath, '-vcodec', 'mpeg4', '-acodec', 'libmp3lame', '-b:v', '1000k', '-b:a', '192k', outputPath];
      case 'mkv':
        return ['-y', '-i', inputPath, '-vcodec', 'libx264', '-acodec', 'aac', '-b:v', '1000k', '-b:a', '128k', '-preset', 'medium', outputPath];
      case 'webm':
        return ['-y', '-i', inputPath, '-vcodec', 'libvpx', '-acodec', 'libvorbis', '-b:v', '1000k', '-b:a', '128k', outputPath];
      case 'mov':
        return ['-y', '-i', inputPath, '-vcodec', 'h264', '-acodec', 'aac', '-b:v', '1000k', '-b:a', '128k', outputPath];
      case 'flv':
        return ['-y', '-i', inputPath, '-vcodec', 'flv1', '-acodec', 'libmp3lame', '-b:v', '1000k', '-b:a', '192k', outputPath];
      case '3gp':
        return ['-y', '-i', inputPath, '-vcodec', 'h263', '-acodec', 'aac', '-b:v', '500k', '-b:a', '128k', '-s', '176x144', outputPath];
      case 'wmv':
        return ['-y', '-i', inputPath, '-vcodec', 'wmv2', '-acodec', 'wmav2', '-b:v', '1000k', '-b:a', '192k', outputPath];
      
      default:
        throw UnsupportedFormatException('Unsupported output format: $outputFormat');
    }
  }

  Future<int?> _probeDurationMs(String inputPath) async {
    final session = await FFprobeKit.getMediaInformation(inputPath);
    final duration = session.getMediaInformation()?.getDuration();
    if (duration == null) {
      return null;
    }

    final seconds = double.tryParse(duration);
    if (seconds == null || seconds <= 0) {
      return null;
    }
    return (seconds * 1000).round();
  }

  @Deprecated('Use convertMedia instead')
  @override
  Future<File> convertWavToMp3({
    required File inputFile,
    required String outputDirectory,
  }) async {
    return await convertMedia(
      inputFile: inputFile,
      outputFormat: 'mp3',
    );
  }
}
