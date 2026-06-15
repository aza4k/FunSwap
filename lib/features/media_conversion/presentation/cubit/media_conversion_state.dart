part of 'media_conversion_cubit.dart';

abstract class MediaConversionState extends Equatable {
  const MediaConversionState();

  @override
  List<Object?> get props => [];
}

class MediaConversionInitial extends MediaConversionState {}

class MediaConversionFileSelected extends MediaConversionState {
  final File selectedFile;
  final String? outputFormat;

  const MediaConversionFileSelected({required this.selectedFile, this.outputFormat});

  @override
  List<Object?> get props => [selectedFile, outputFormat];
}

class MediaConversionFormatSelected extends MediaConversionState {
  final File selectedFile;
  final String outputFormat;

  const MediaConversionFormatSelected({required this.selectedFile, required this.outputFormat});

  @override
  List<Object?> get props => [selectedFile, outputFormat];
}

class MediaConversionLoading extends MediaConversionState {
  final double? progress; // Optional progress for long operations

  const MediaConversionLoading({this.progress});

  @override
  List<Object?> get props => [progress];
}

class MediaConversionSuccess extends MediaConversionState {
  final File convertedFile;

  const MediaConversionSuccess({required this.convertedFile});

  @override
  List<Object?> get props => [convertedFile];
}

class MediaConversionError extends MediaConversionState {
  final String message;

  const MediaConversionError({required this.message});

  @override
  List<Object?> get props => [message];
}
