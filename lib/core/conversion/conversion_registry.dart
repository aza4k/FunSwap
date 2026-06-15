import 'package:path/path.dart' as p;

enum ConversionCategory {
  image,
  document,
  media,
}

class ConversionRegistry {
  static const Set<String> imageOutputFormats = {
    'png',
    'jpg',
    'jpeg',
    'webp',
    'gif',
    'bmp',
    'tiff',
    'tif',
    'ico',
  };

  static const Set<String> _imageToPdfInputs = {
    'png',
    'jpg',
    'jpeg',
    'webp',
  };

  static const Set<String> _audioInputs = {
    'wav',
    'mp3',
    'aac',
    'ogg',
    'oga',
    'flac',
    'wma',
    'opus',
  };

  static const Set<String> _videoInputs = {
    'mp4',
    'avi',
    'mkv',
    'mov',
    'webm',
    'flv',
    '3gp',
    'wmv',
  };

  static const Set<String> audioOutputFormats = {
    'mp3',
    'wav',
    'aac',
    'ogg',
    'flac',
    'wma',
    'opus',
  };

  static const Set<String> videoOutputFormats = {
    'mp4',
    'avi',
    'mkv',
    'webm',
    'mov',
    'flv',
    '3gp',
    'wmv',
  };

  static String extensionOf(String path) {
    final extension = p.extension(path).toLowerCase();
    return extension.startsWith('.') ? extension.substring(1) : extension;
  }

  static List<String> imageOutputsFor(String inputPath) {
    final input = extensionOf(inputPath);
    if (!imageOutputFormats.contains(input)) {
      return const [];
    }
    return imageOutputFormats.toList(growable: false);
  }

  static List<String> documentOutputsFor(String inputPath) {
    final input = extensionOf(inputPath);
    if (_imageToPdfInputs.contains(input)) {
      return const ['pdf'];
    }
    if (input == 'csv') {
      return const ['xlsx'];
    }
    if (input == 'xlsx' || input == 'xls') {
      return const ['csv'];
    }
    return const [];
  }

  static List<String> mediaOutputsFor(String inputPath) {
    final input = extensionOf(inputPath);
    if (_audioInputs.contains(input)) {
      return audioOutputFormats.toList(growable: false);
    }
    if (_videoInputs.contains(input)) {
      return videoOutputFormats.toList(growable: false);
    }
    return const [];
  }

  static bool isSupportedOutput({
    required ConversionCategory category,
    required String inputPath,
    required String outputFormat,
  }) {
    final normalizedOutput = outputFormat.toLowerCase();
    return switch (category) {
      ConversionCategory.image =>
        imageOutputsFor(inputPath).contains(normalizedOutput),
      ConversionCategory.document =>
        documentOutputsFor(inputPath).contains(normalizedOutput),
      ConversionCategory.media =>
        mediaOutputsFor(inputPath).contains(normalizedOutput),
    };
  }
}
