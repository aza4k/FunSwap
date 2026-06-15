import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:funswap/core/errors/failures.dart';
import 'package:funswap/features/image_conversion/domain/repositories/image_conversion_repository.dart';

class ConvertImageToWebP {
  final ImageConversionRepository repository;

  ConvertImageToWebP(this.repository);

  Future<Either<Failure, File>> call({
    required File inputFile,
    required String outputDirectory,
  }) async {
    return await repository.convertImageToWebP(
      inputFile: inputFile,
      outputDirectory: outputDirectory,
    );
  }
}
