class ServerException implements Exception {
  final String message;
  const ServerException(this.message);
}

class CacheException implements Exception {
  final String message;
  const CacheException(this.message);
}

class ConversionException implements Exception {
  final String message;
  const ConversionException(this.message);
}

class FilePickerException implements Exception {
  final String message;
  const FilePickerException(this.message);
}

class PermissionException implements Exception {
  final String message;
  const PermissionException(this.message);
}

class LowStorageException implements Exception {
  final String message;
  const LowStorageException(this.message);
}

class UnsupportedFormatException implements Exception {
  final String message;
  const UnsupportedFormatException(this.message);
}
