import 'dart:io';

import 'package:funswap/core/errors/exceptions.dart';

Never throwMappedFileSystemException(
  FileSystemException exception,
  String fallbackMessage,
) {
  final details = [
    exception.message,
    exception.osError?.message ?? '',
  ].join(' ').toLowerCase();

  if (details.contains('no space') ||
      details.contains('enospc') ||
      details.contains('not enough space')) {
    throw LowStorageException(fallbackMessage);
  }

  if (details.contains('permission') ||
      details.contains('access is denied') ||
      details.contains('eacces')) {
    throw PermissionException(fallbackMessage);
  }

  throw ConversionException(fallbackMessage);
}
