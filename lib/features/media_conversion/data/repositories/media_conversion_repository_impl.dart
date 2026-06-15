import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:funswap/core/conversion/conversion_progress.dart';
import 'package:funswap/core/errors/exceptions.dart';
import 'package:funswap/core/errors/failures.dart';
import 'package:funswap/features/media_conversion/data/datasources/media_conversion_local_datasource.dart';
import 'package:funswap/features/media_conversion/domain/repositories/media_conversion_repository.dart';

class MediaConversionRepositoryImpl implements MediaConversionRepository {
  final MediaConversionLocalDataSource localDataSource;

  MediaConversionRepositoryImpl({required this.localDataSource});

  @override
  Future<Either<Failure, File>> convertWavToMp3({
    required File inputFile,
    required String outputDirectory,
  }) async {
    try {
      final outputFile = await localDataSource.convertWavToMp3(
        inputFile: inputFile,
        outputDirectory: outputDirectory,
      );
      return Right(outputFile);
    } on ConversionException catch (e) {
      return Left(ConversionFailure(e.message));
    } catch (e) {
      return Left(ConversionFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, File>> convertMedia({
    required File inputFile,
    required String outputFormat,
    ConversionProgressCallback? onProgress,
  }) async {
    try {
      final outputFile = await localDataSource.convertMedia(
        inputFile: inputFile,
        outputFormat: outputFormat,
        onProgress: onProgress,
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
  Future<void> cancelActiveConversion() {
    return localDataSource.cancelActiveConversion();
  }
}
