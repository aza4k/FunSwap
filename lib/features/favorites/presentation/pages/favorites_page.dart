import 'package:flutter/material.dart';
import 'package:funswap/core/theme/app_theme.dart';
import 'package:funswap/core/services/history_service.dart';
import 'package:funswap/core/services/localization_service.dart';
import 'package:funswap/core/utils/format_utils.dart';

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key});

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  List<ConversionRecord> _favoriteRecords = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    setState(() => _isLoading = true);
    final history = await HistoryService.getHistory();
    if (mounted) {
      setState(() {
        _favoriteRecords = history.where((r) => r.isFavorite).toList();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('fav_title'.tr),
      ),
      body: RefreshIndicator(
        onRefresh: _loadFavorites,
        color: AppColors.primary,
        backgroundColor: AppColors.surface,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _favoriteRecords.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.all(20.0),
                    itemCount: _favoriteRecords.length,
                    itemBuilder: (context, index) {
                      return _buildFavoriteItem(_favoriteRecords[index]);
                    },
                  ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Container(
        height: MediaQuery.of(context).size.height * 0.7,
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                color: AppColors.surface,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.star_rounded,
                size: 56,
                color: Colors.amber,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'fav_empty'.tr,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'fav_empty_subtitle'.tr,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFavoriteItem(ConversionRecord record) {
    Color fileColor = AppColors.accentBlue;
    IconData fileIcon = Icons.insert_drive_file_rounded;
    
    if (record.fileType == 'document') {
      fileColor = AppColors.accentRed;
      fileIcon = Icons.description_rounded;
    } else if (record.fileType == 'image') {
      fileColor = AppColors.accentGreen;
      fileIcon = Icons.image_rounded;
    } else if (record.fileType == 'audio') {
      fileColor = AppColors.accentOrange;
      fileIcon = Icons.audiotrack_rounded;
    } else if (record.fileType == 'video') {
      fileColor = Colors.purple;
      fileIcon = Icons.video_library_rounded;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.surfaceLight.withOpacity(0.4), width: 1),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: fileColor.withOpacity(0.15),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(fileIcon, color: fileColor, size: 24),
        ),
        title: Text(
          record.originalName,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.white),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4.0),
          child: Row(
            children: [
              Text(
                FormatUtils.formatSize(record.fileSize),
                style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
              ),
              const SizedBox(width: 8),
              const Text('•', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  FormatUtils.timeAgo(record.timestamp),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                ),
              ),
            ],
          ),
        ),
        trailing: IconButton(
          icon: const Icon(Icons.star_rounded, color: Colors.amber),
          onPressed: () async {
            await HistoryService.toggleFavorite(record.id);
            _loadFavorites();
          },
        ),
      ),
    );
  }
}
