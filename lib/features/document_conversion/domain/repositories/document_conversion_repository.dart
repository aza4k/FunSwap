import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:funswap/core/errors/failures.dart';

abstract class DocumentConversionRepository {
  Future<Either<Failure, File>> convertImageToPdf({
    required List<File> imageFiles,
    required String outputDirectory,
    required String outputFileName,
  });

  Future<Either<Failure, File>> convertCsvToExcel({
    required File csvFile,
    required String outputDirectory,
  });

  Future<Either<Failure, File>> convertExcelToCsv({
    required File excelFile,
    required String outputDirectory,
  });

  Future<Either<Failure, File>> convertDocxToPdf({
    required File docxFile,
    required String outputDirectory,
  });
}
