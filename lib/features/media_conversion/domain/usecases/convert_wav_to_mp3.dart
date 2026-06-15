import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:funswap/core/errors/failures.dart';
import 'package:funswap/features/media_conversion/domain/repositories/media_conversion_repository.dart';

class ConvertWavToMp3 {
  final MediaConversionRepository repository;

  ConvertWavToMp3(this.repository);

  Future<Either<Failure, File>> call({
    required File inputFile,
    required String outputDirectory,
  }) async {
    return await repository.convertWavToMp3(
      inputFile: inputFile,
      outputDirectory: outputDirectory,
    );
  }
}
