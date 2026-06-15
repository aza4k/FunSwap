import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:funswap/core/errors/failures.dart';
import 'package:funswap/features/document_conversion/domain/repositories/document_conversion_repository.dart';

class ConvertImageToPdf {
  final DocumentConversionRepository repository;

  ConvertImageToPdf(this.repository);

  Future<Either<Failure, File>> call({
    required List<File> imageFiles,
    required String outputDirectory,
    required String outputFileName,
  }) async {
    return await repository.convertImageToPdf(
      imageFiles: imageFiles,
      outputDirectory: outputDirectory,
      outputFileName: outputFileName,
    );
  }
}
