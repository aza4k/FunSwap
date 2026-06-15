import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:funswap/core/errors/failures.dart';
import 'package:funswap/features/document_conversion/domain/repositories/document_conversion_repository.dart';

class ConvertExcelToCsv {
  final DocumentConversionRepository repository;

  ConvertExcelToCsv(this.repository);

  Future<Either<Failure, File>> call({
    required File excelFile,
    required String outputDirectory,
  }) async {
    return await repository.convertExcelToCsv(
      excelFile: excelFile,
      outputDirectory: outputDirectory,
    );
  }
}
