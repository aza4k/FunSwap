import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:funswap/core/errors/failures.dart';

abstract class ImageConversionRepository {
  Future<Either<Failure, File>> convertImageToWebP({
    required File inputFile,
    required String outputDirectory,
  });

  Future<Either<Failure, File>> convertImage({
    required File inputFile,
    required String outputFormat,
  });
}
