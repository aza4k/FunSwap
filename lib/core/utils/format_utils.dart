import 'package:funswap/core/services/localization_service.dart';

class FormatUtils {
  static String formatSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  static String timeAgo(DateTime dateTime) {
    final difference = DateTime.now().difference(dateTime);
    if (difference.inMinutes < 1) return 'home_just_now'.tr;
    if (difference.inMinutes < 60) return '${difference.inMinutes} ${'home_min_ago'.tr}';
    if (difference.inHours < 24) return '${difference.inHours} ${'home_hours_ago'.tr}';
    return '${difference.inDays} ${'home_days_ago'.tr}';
  }
}
