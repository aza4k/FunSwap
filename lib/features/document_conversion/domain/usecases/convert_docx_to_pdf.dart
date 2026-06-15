import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:funswap/core/errors/failures.dart';
import 'package:funswap/features/document_conversion/domain/repositories/document_conversion_repository.dart';

class ConvertDocxToPdf {
  final DocumentConversionRepository repository;

  ConvertDocxToPdf(this.repository);

  Future<Either<Failure, File>> call({
    required File docxFile,
    required String outputDirectory,
  }) async {
    return await repository.convertDocxToPdf(
      docxFile: docxFile,
      outputDirectory: outputDirectory,
    );
  }
}
