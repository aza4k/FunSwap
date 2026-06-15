part of 'image_conversion_cubit.dart';

abstract class ImageConversionState extends Equatable {
  const ImageConversionState();

  @override
  List<Object?> get props => [];
}

class ImageConversionInitial extends ImageConversionState {}

class ImageConversionFileSelected extends ImageConversionState {
  final File selectedFile;
  final String? outputFormat;

  const ImageConversionFileSelected({required this.selectedFile, this.outputFormat});

  @override
  List<Object?> get props => [selectedFile, outputFormat];
}

class ImageConversionFormatSelected extends ImageConversionState {
  final File selectedFile;
  final String outputFormat;

  const ImageConversionFormatSelected({required this.selectedFile, required this.outputFormat});

  @override
  List<Object?> get props => [selectedFile, outputFormat];
}

class ImageConversionLoading extends ImageConversionState {
  final double? progress; // Optional progress for long operations

  const ImageConversionLoading({this.progress});

  @override
  List<Object?> get props => [progress];
}

class ImageConversionSuccess extends ImageConversionState {
  final File convertedFile;

  const ImageConversionSuccess({required this.convertedFile});

  @override
  List<Object?> get props => [convertedFile];
}

class ImageConversionError extends ImageConversionState {
  final String message;

  const ImageConversionError({required this.message});

  @override
  List<Object?> get props => [message];
}
