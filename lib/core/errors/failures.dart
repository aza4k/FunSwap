import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String message;
  const Failure(this.message);

  @override
  List<Object> get props => [message];
}

// General failures
class ServerFailure extends Failure {
  const ServerFailure(String message) : super(message);
}

class CacheFailure extends Failure {
  const CacheFailure(String message) : super(message);
}

// Conversion specific failures
class ConversionFailure extends Failure {
  const ConversionFailure(String message) : super(message);
}

class FilePickerFailure extends Failure {
  const FilePickerFailure(String message) : super(message);
}

class PermissionFailure extends Failure {
  const PermissionFailure(String message) : super(message);
}

class LowStorageFailure extends Failure {
  const LowStorageFailure(String message) : super(message);
}

class UnsupportedFormatFailure extends Failure {
  const UnsupportedFormatFailure(String message) : super(message);
}
