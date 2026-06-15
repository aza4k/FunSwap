import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:funswap/core/conversion/conversion_progress.dart';
import 'package:funswap/core/errors/failures.dart';
import 'package:funswap/features/media_conversion/domain/repositories/media_conversion_repository.dart';

class ConvertMedia {
  final MediaConversionRepository repository;

  ConvertMedia(this.repository);

  Future<Either<Failure, File>> call({
    required File inputFile,
    required String outputFormat,
    ConversionProgressCallback? onProgress,
  }) async {
    return await repository.convertMedia(
      inputFile: inputFile,
      outputFormat: outputFormat,
      onProgress: onProgress,
    );
  }

  Future<void> cancel() {
    return repository.cancelActiveConversion();
  }
}
