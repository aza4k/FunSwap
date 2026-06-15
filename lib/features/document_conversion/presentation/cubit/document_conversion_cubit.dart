import 'dart:io';
import 'package:bloc/bloc.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:funswap/core/conversion/conversion_registry.dart';
import 'package:funswap/core/errors/failures.dart';
import 'package:funswap/core/services/file_service.dart';
import 'package:funswap/features/document_conversion/domain/usecases/convert_csv_to_excel.dart';
import 'package:funswap/features/document_conversion/domain/usecases/convert_excel_to_csv.dart';
import 'package:funswap/features/document_conversion/domain/usecases/convert_image_to_pdf.dart';
import 'package:funswap/features/document_conversion/domain/usecases/convert_docx_to_pdf.dart';
import 'package:path/path.dart' as p;

part 'document_conversion_state.dart';

class DocumentConversionCubit extends Cubit<DocumentConversionState> {
  final ConvertImageToPdf convertImageToPdf;
  final ConvertCsvToExcel convertCsvToExcel;
  final ConvertExcelToCsv convertExcelToCsv;
  final ConvertDocxToPdf convertDocxToPdf;

  DocumentConversionCubit({
    required this.convertImageToPdf,
    required this.convertCsvToExcel,
    required this.convertExcelToCsv,
    required this.convertDocxToPdf,
  }) : super(DocumentConversionInitial());

  File? _selectedFile;
  String? _outputFormat;

  File? get selectedFile => _selectedFile;
  String? get outputFormat => _outputFormat;

  void fileSelected(File? file) {
    if (file != null) {
      _selectedFile = file;
      _outputFormat = null; // Reset output format when a new file is picked
      emit(DocumentConversionFileSelected(selectedFile: file));
    } else {
      _selectedFile = null;
      _outputFormat = null;
      emit(DocumentConversionInitial());
    }
  }

  void outputFormatSelected(String? format) {
    _outputFormat = format;
    if (_selectedFile != null && _outputFormat != null) {
      emit(DocumentConversionFormatSelected(selectedFile: _selectedFile!, outputFormat: _outputFormat!));
    } else if (_selectedFile != null) {
      emit(DocumentConversionFileSelected(selectedFile: _selectedFile!));
    }
  }

  Future<void> convertDocument() async {
    if (_selectedFile == null || _outputFormat == null) {
      emit(const DocumentConversionError(message: 'Please select a file and an output format.'));
      return;
    }

    emit(const DocumentConversionLoading());

    final outputDirectory = await FileService.getFunSwapPath();

    Either<Failure, File> result;
    final inputFileExtension = ConversionRegistry.extensionOf(_selectedFile!.path);

    if (['png', 'jpg', 'jpeg', 'webp'].contains(inputFileExtension)) {
      if (_outputFormat == 'pdf') {
        result = await convertImageToPdf(
          imageFiles: [_selectedFile!], // Assuming single image for now
          outputDirectory: outputDirectory,
          outputFileName: p.basenameWithoutExtension(_selectedFile!.path),
        );
      } else {
        result = Left(UnsupportedFormatFailure('Conversion from $inputFileExtension to $_outputFormat is not supported.'));
      }
    } else if (inputFileExtension == 'csv') {
      if (_outputFormat == 'xlsx') {
        result = await convertCsvToExcel(
          csvFile: _selectedFile!,
          outputDirectory: outputDirectory,
        );
      } else {
        result = Left(UnsupportedFormatFailure('Conversion from $inputFileExtension to $_outputFormat is not supported.'));
      }
    } else if (inputFileExtension == 'xlsx' || inputFileExtension == 'xls') {
      if (_outputFormat == 'csv') {
        result = await convertExcelToCsv(
          excelFile: _selectedFile!,
          outputDirectory: outputDirectory,
        );
      } else {
        result = Left(UnsupportedFormatFailure('Conversion from $inputFileExtension to $_outputFormat is not supported.'));
      }
    } else if (inputFileExtension == 'docx') {
      if (_outputFormat == 'pdf') {
        result = await convertDocxToPdf(
          docxFile: _selectedFile!,
          outputDirectory: outputDirectory,
        );
      } else {
        result = Left(UnsupportedFormatFailure('Conversion from $inputFileExtension to $_outputFormat is not supported.'));
      }
    } else {
      result = Left(UnsupportedFormatFailure('Unsupported input file format: $inputFileExtension'));
    }

    result.fold(
      (failure) => emit(DocumentConversionError(message: failure.message)),
      (convertedFile) => emit(DocumentConversionSuccess(convertedFile: convertedFile)),
    );
  }
}
