import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:funswap/core/conversion/conversion_progress.dart';
import 'package:funswap/core/errors/failures.dart';

abstract class MediaConversionRepository {
  Future<Either<Failure, File>> convertWavToMp3({
    required File inputFile,
    required String outputDirectory,
  });

  Future<Either<Failure, File>> convertMedia({
    required File inputFile,
    required String outputFormat,
    ConversionProgressCallback? onProgress,
  });

  Future<void> cancelActiveConversion();
}
