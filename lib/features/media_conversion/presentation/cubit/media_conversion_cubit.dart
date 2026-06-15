import 'dart:io';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:funswap/features/media_conversion/domain/usecases/convert_media.dart';

part 'media_conversion_state.dart';

class MediaConversionCubit extends Cubit<MediaConversionState> {
  final ConvertMedia convertMedia;

  MediaConversionCubit({required this.convertMedia}) : super(MediaConversionInitial());

  File? _selectedFile;
  String? _outputFormat;

  File? get selectedFile => _selectedFile;
  String? get outputFormat => _outputFormat;

  void fileSelected(File? file) {
    if (file != null) {
      _selectedFile = file;
      _outputFormat = null;
      emit(MediaConversionFileSelected(selectedFile: file));
    } else {
      _selectedFile = null;
      _outputFormat = null;
      emit(MediaConversionInitial());
    }
  }

  void outputFormatSelected(String? format) {
    _outputFormat = format;
    if (_selectedFile != null && _outputFormat != null) {
      emit(MediaConversionFormatSelected(selectedFile: _selectedFile!, outputFormat: _outputFormat!));
    } else if (_selectedFile != null) {
      emit(MediaConversionFileSelected(selectedFile: _selectedFile!));
    }
  }

  Future<void> convertMediaNow() async {
    if (_selectedFile == null || _outputFormat == null) {
      emit(const MediaConversionError(message: 'Please select a file and an output format.'));
      return;
    }

    emit(const MediaConversionLoading(progress: 0));

    final result = await convertMedia(
      inputFile: _selectedFile!,
      outputFormat: _outputFormat!,
      onProgress: (progress) {
        if (!isClosed) {
          emit(MediaConversionLoading(progress: progress));
        }
      },
    );

    result.fold(
      (failure) => emit(MediaConversionError(message: failure.message)),
      (convertedFile) => emit(MediaConversionSuccess(convertedFile: convertedFile)),
    );
  }

  Future<void> cancelConversion() async {
    await convertMedia.cancel();
    if (!isClosed) {
      emit(const MediaConversionError(message: 'Conversion was cancelled.'));
    }
  }
}
