import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:funswap/core/errors/exceptions.dart';
import 'package:funswap/core/errors/failures.dart';
import 'package:funswap/features/document_conversion/data/datasources/document_conversion_local_datasource.dart';
import 'package:funswap/features/document_conversion/domain/repositories/document_conversion_repository.dart';

class DocumentConversionRepositoryImpl implements DocumentConversionRepository {
  final DocumentConversionLocalDataSource localDataSource;

  DocumentConversionRepositoryImpl({required this.localDataSource});

  @override
  Future<Either<Failure, File>> convertImageToPdf({
    required List<File> imageFiles,
    required String outputDirectory,
    required String outputFileName,
  }) async {
    try {
      final outputFile = await localDataSource.convertImageToPdf(
        imageFiles: imageFiles,
        outputDirectory: outputDirectory,
        outputFileName: outputFileName,
      );
      return Right(outputFile);
    } on ConversionException catch (e) {
      return Left(ConversionFailure(e.message));
    } on PermissionException catch (e) {
      return Left(PermissionFailure(e.message));
    } on LowStorageException catch (e) {
      return Left(LowStorageFailure(e.message));
    } catch (e) {
      return Left(ConversionFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, File>> convertCsvToExcel({
    required File csvFile,
    required String outputDirectory,
  }) async {
    try {
      final outputFile = await localDataSource.convertCsvToExcel(
        csvFile: csvFile,
        outputDirectory: outputDirectory,
      );
      return Right(outputFile);
    } on ConversionException catch (e) {
      return Left(ConversionFailure(e.message));
    } on PermissionException catch (e) {
      return Left(PermissionFailure(e.message));
    } on LowStorageException catch (e) {
      return Left(LowStorageFailure(e.message));
    } catch (e) {
      return Left(ConversionFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, File>> convertExcelToCsv({
    required File excelFile,
    required String outputDirectory,
  }) async {
    try {
      final outputFile = await localDataSource.convertExcelToCsv(
        excelFile: excelFile,
        outputDirectory: outputDirectory,
      );
      return Right(outputFile);
    } on ConversionException catch (e) {
      return Left(ConversionFailure(e.message));
    } on PermissionException catch (e) {
      return Left(PermissionFailure(e.message));
    } on LowStorageException catch (e) {
      return Left(LowStorageFailure(e.message));
    } catch (e) {
      return Left(ConversionFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, File>> convertDocxToPdf({
    required File docxFile,
    required String outputDirectory,
  }) async {
    try {
      final outputFile = await localDataSource.convertDocxToPdf(
        docxFile: docxFile,
        outputDirectory: outputDirectory,
      );
      return Right(outputFile);
    } on ConversionException catch (e) {
      return Left(ConversionFailure(e.message));
    } on PermissionException catch (e) {
      return Left(PermissionFailure(e.message));
    } on LowStorageException catch (e) {
      return Left(LowStorageFailure(e.message));
    } catch (e) {
      return Left(ConversionFailure('Unexpected error: $e'));
    }
  }
}
