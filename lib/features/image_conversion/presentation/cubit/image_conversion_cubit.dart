import 'dart:io';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:funswap/features/image_conversion/domain/usecases/convert_image.dart';

part 'image_conversion_state.dart';

class ImageConversionCubit extends Cubit<ImageConversionState> {
  final ConvertImage convertImage;

  ImageConversionCubit({required this.convertImage}) : super(ImageConversionInitial());

  File? _selectedFile;
  String? _outputFormat;

  File? get selectedFile => _selectedFile;
  String? get outputFormat => _outputFormat;

  void fileSelected(File? file) {
    if (file != null) {
      _selectedFile = file;
      emit(ImageConversionFileSelected(selectedFile: file, outputFormat: _outputFormat));
    } else {
      _selectedFile = null;
      _outputFormat = null;
      emit(ImageConversionInitial());
    }
  }

  void outputFormatSelected(String? format) {
    _outputFormat = format;
    if (_selectedFile != null && _outputFormat != null) {
      emit(ImageConversionFormatSelected(selectedFile: _selectedFile!, outputFormat: _outputFormat!));
    } else if (_selectedFile != null) {
      emit(ImageConversionFileSelected(selectedFile: _selectedFile!));
    }
  }

  Future<void> convertImageNow() async {
    if (_selectedFile == null || _outputFormat == null) {
      emit(const ImageConversionError(message: 'Please select a file and an output format.'));
      return;
    }

    emit(const ImageConversionLoading());

    final result = await convertImage(
      inputFile: _selectedFile!,
      outputFormat: _outputFormat!,
    );

    result.fold(
      (failure) => emit(ImageConversionError(message: failure.message)),
      (convertedFile) => emit(ImageConversionSuccess(convertedFile: convertedFile)),
    );
  }
}
