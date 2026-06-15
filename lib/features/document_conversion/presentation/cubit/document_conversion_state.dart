part of 'document_conversion_cubit.dart';

abstract class DocumentConversionState extends Equatable {
  const DocumentConversionState();

  @override
  List<Object?> get props => [];
}

class DocumentConversionInitial extends DocumentConversionState {}

class DocumentConversionFileSelected extends DocumentConversionState {
  final File selectedFile;
  final String? outputFormat;

  const DocumentConversionFileSelected({required this.selectedFile, this.outputFormat});

  @override
  List<Object?> get props => [selectedFile, outputFormat];
}

class DocumentConversionFormatSelected extends DocumentConversionState {
  final File selectedFile;
  final String outputFormat;

  const DocumentConversionFormatSelected({required this.selectedFile, required this.outputFormat});

  @override
  List<Object?> get props => [selectedFile, outputFormat];
}

class DocumentConversionLoading extends DocumentConversionState {
  final double? progress; // Optional progress for long operations

  const DocumentConversionLoading({this.progress});

  @override
  List<Object?> get props => [progress];
}

class DocumentConversionSuccess extends DocumentConversionState {
  final File convertedFile;

  const DocumentConversionSuccess({required this.convertedFile});

  @override
  List<Object?> get props => [convertedFile];
}

class DocumentConversionError extends DocumentConversionState {
  final String message;

  const DocumentConversionError({required this.message});

  @override
  List<Object?> get props => [message];
}
