import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:funswap/core/errors/failures.dart';
import 'package:funswap/features/document_conversion/domain/repositories/document_conversion_repository.dart';

class ConvertCsvToExcel {
  final DocumentConversionRepository repository;

  ConvertCsvToExcel(this.repository);

  Future<Either<Failure, File>> call({
    required File csvFile,
    required String outputDirectory,
  }) async {
    return await repository.convertCsvToExcel(
      csvFile: csvFile,
      outputDirectory: outputDirectory,
    );
  }
}
