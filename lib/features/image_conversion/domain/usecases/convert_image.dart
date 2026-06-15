import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:funswap/core/errors/failures.dart';
import 'package:funswap/features/image_conversion/domain/repositories/image_conversion_repository.dart';

class ConvertImage {
  final ImageConversionRepository repository;

  ConvertImage(this.repository);

  Future<Either<Failure, File>> call({
    required File inputFile,
    required String outputFormat,
  }) async {
    return await repository.convertImage(
      inputFile: inputFile,
      outputFormat: outputFormat,
    );
  }
}
