import 'package:get_it/get_it.dart';
import 'package:funswap/features/image_conversion/domain/usecases/convert_image_to_webp.dart';
import 'package:funswap/features/image_conversion/domain/usecases/convert_image.dart';
import 'package:funswap/features/image_conversion/domain/repositories/image_conversion_repository.dart';
import 'package:funswap/features/image_conversion/data/repositories/image_conversion_repository_impl.dart';
import 'package:funswap/features/image_conversion/data/datasources/image_conversion_local_datasource.dart';
import 'package:funswap/features/image_conversion/presentation/cubit/image_conversion_cubit.dart';

import 'package:funswap/features/document_conversion/domain/usecases/convert_csv_to_excel.dart';
import 'package:funswap/features/document_conversion/domain/usecases/convert_excel_to_csv.dart';
import 'package:funswap/features/document_conversion/domain/usecases/convert_image_to_pdf.dart';
import 'package:funswap/features/document_conversion/domain/usecases/convert_docx_to_pdf.dart';
import 'package:funswap/features/document_conversion/domain/repositories/document_conversion_repository.dart';
import 'package:funswap/features/document_conversion/data/repositories/document_conversion_repository_impl.dart';
import 'package:funswap/features/document_conversion/data/datasources/document_conversion_local_datasource.dart';
import 'package:funswap/features/document_conversion/presentation/cubit/document_conversion_cubit.dart';

import 'package:funswap/features/media_conversion/domain/usecases/convert_wav_to_mp3.dart';
import 'package:funswap/features/media_conversion/domain/usecases/convert_media.dart';
import 'package:funswap/features/media_conversion/domain/repositories/media_conversion_repository.dart';
import 'package:funswap/features/media_conversion/data/repositories/media_conversion_repository_impl.dart';
import 'package:funswap/features/media_conversion/data/datasources/media_conversion_local_datasource.dart';
import 'package:funswap/features/media_conversion/presentation/cubit/media_conversion_cubit.dart';


final sl = GetIt.instance; // sl stands for Service Locator

Future<void> init() async {
  //! Features - Image Conversion
  // Bloc
  sl.registerFactory(
    () => ImageConversionCubit(convertImage: sl()),
  );

  // Use cases
  sl.registerLazySingleton(
    () => ConvertImage(sl()),
  );
  sl.registerLazySingleton(
    () => ConvertImageToWebP(sl()),
  );

  // Repository
  sl.registerLazySingleton<ImageConversionRepository>(
    () => ImageConversionRepositoryImpl(localDataSource: sl()),
  );

  // Data sources
  sl.registerLazySingleton<ImageConversionLocalDataSource>(
    () => ImageConversionLocalDataSourceImpl(),
  );

  //! Features - Document Conversion
  // Cubit
  sl.registerFactory(
    () => DocumentConversionCubit(
      convertImageToPdf: sl(),
      convertCsvToExcel: sl(),
      convertExcelToCsv: sl(),
      convertDocxToPdf: sl(),
    ),
  );

  // Use cases
  sl.registerLazySingleton(() => ConvertImageToPdf(sl()));
  sl.registerLazySingleton(() => ConvertCsvToExcel(sl()));
  sl.registerLazySingleton(() => ConvertExcelToCsv(sl()));
  sl.registerLazySingleton(() => ConvertDocxToPdf(sl()));

  // Repository
  sl.registerLazySingleton<DocumentConversionRepository>(
    () => DocumentConversionRepositoryImpl(localDataSource: sl()),
  );

  // Data sources
  sl.registerLazySingleton<DocumentConversionLocalDataSource>(
    () => DocumentConversionLocalDataSourceImpl(),
  );

  //! Features - Media Conversion
  // Cubit
  sl.registerFactory(
    () => MediaConversionCubit(convertMedia: sl()),
  );

  // Use cases
  sl.registerLazySingleton(
    () => ConvertMedia(sl()),
  );
  sl.registerLazySingleton(
    () => ConvertWavToMp3(sl()),
  );

  // Repository
  sl.registerLazySingleton<MediaConversionRepository>(
    () => MediaConversionRepositoryImpl(localDataSource: sl()),
  );

  // Data sources
  sl.registerLazySingleton<MediaConversionLocalDataSource>(
    () => MediaConversionLocalDataSourceImpl(),
  );


  //! Core

  //! External
}
