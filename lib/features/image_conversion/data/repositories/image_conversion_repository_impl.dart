import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:funswap/core/errors/exceptions.dart';
import 'package:funswap/core/errors/failures.dart';
import 'package:funswap/features/image_conversion/data/datasources/image_conversion_local_datasource.dart';
import 'package:funswap/features/image_conversion/domain/repositories/image_conversion_repository.dart';

class ImageConversionRepositoryImpl implements ImageConversionRepository {
  final ImageConversionLocalDataSource localDataSource;

  ImageConversionRepositoryImpl({required this.localDataSource});

  @override
  Future<Either<Failure, File>> convertImageToWebP({
    required File inputFile,
    required String outputDirectory,
  }) async {
    try {
      final outputFile = await localDataSource.convertImageToWebP(
        inputFile: inputFile,
        outputDirectory: outputDirectory,
      );
      return Right(outputFile);
    } on ConversionException catch (e) {
      return Left(ConversionFailure(e.message));
    } on UnsupportedFormatException catch (e) {
      return Left(UnsupportedFormatFailure(e.message));
    } on PermissionException catch (e) {
      return Left(PermissionFailure(e.message));
    } on LowStorageException catch (e) {
      return Left(LowStorageFailure(e.message));
    } catch (e) {
      return Left(ConversionFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, File>> convertImage({
    required File inputFile,
    required String outputFormat,
  }) async {
    try {
      final outputFile = await localDataSource.convertImage(
        inputFile: inputFile,
        outputFormat: outputFormat,
      );
      return Right(outputFile);
    } on ConversionException catch (e) {
      return Left(ConversionFailure(e.message));
    } on UnsupportedFormatException catch (e) {
      return Left(UnsupportedFormatFailure(e.message));
    } on PermissionException catch (e) {
      return Left(PermissionFailure(e.message));
    } on LowStorageException catch (e) {
      return Left(LowStorageFailure(e.message));
    } catch (e) {
      return Left(ConversionFailure('Unexpected error: $e'));
    }
  }
}
