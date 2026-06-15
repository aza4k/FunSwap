import 'package:flutter/material.dart';
import 'package:funswap/core/theme/app_theme.dart';
import 'package:funswap/core/services/history_service.dart';
import 'package:funswap/features/conversion/presentation/pages/conversion_page.dart';
import 'package:funswap/features/profile/presentation/pages/settings_page.dart';
import 'package:funswap/core/services/localization_service.dart';
import 'package:funswap/core/utils/format_utils.dart';

class HomePage extends StatefulWidget {
  final Function(int) onTabChange;
  const HomePage({super.key, required this.onTabChange});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<ConversionRecord> _recentRecords = [];

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    final history = await HistoryService.getHistory();
    if (mounted) {
      setState(() {
        _recentRecords = history.take(3).toList();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'FunSwap',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, letterSpacing: 0.8),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsPage()),
              );
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadHistory,
        color: AppColors.primary,
        backgroundColor: AppColors.surface,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              
              // Top Banner
              _buildTopBanner(),
              
              const SizedBox(height: 28),
              
              // Categories Section
              Text(
                'home_conversion'.tr,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              
              // Category Grid
              _buildCategoryGrid(),
              
              const SizedBox(height: 32),
              
              // Recent Conversions Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'home_recent'.tr,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  if (_recentRecords.isNotEmpty)
                    TextButton(
                      onPressed: () => widget.onTabChange(1), // Go to files tab
                      child: Text(
                        'home_all'.tr,
                        style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              
              _recentRecords.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _recentRecords.length,
                      itemBuilder: (context, index) {
                        return _buildHistoryItem(_recentRecords[index]);
                      },
                    ),
              
              const SizedBox(height: 100), // Space for FAB
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBanner() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: AppColors.cardGradient,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.surfaceLight.withOpacity(0.5), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.08),
            blurRadius: 20,
            spreadRadius: 2,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Background graphic glow
          Positioned(
            right: -20,
            bottom: -20,
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.12),
                    blurRadius: 40,
                    spreadRadius: 20,
                  ),
                ],
              ),
            ),
          ),
          
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'home_banner_title'.tr,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          height: 1.3,
                        ),
                      ),
                      const SizedBox(height: 18),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const ConversionPage(),
                            ),
                          ).then((_) => _loadHistory());
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'home_start'.tr,
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(width: 8),
                            const Icon(Icons.arrow_forward, size: 16, color: Colors.black),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Banner illustration (Folder with document)
                Expanded(
                  flex: 2,
                  child: Center(
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(22),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(22),
                        child: Image.asset(
                          'assets/icons/app_logo.png',
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              decoration: const BoxDecoration(
                                gradient: AppColors.primaryGradient,
                              ),
                              child: const Icon(
                                Icons.swap_horiz_rounded,
                                size: 48,
                                color: Colors.white,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryGrid() {
    final List<CategoryItem> categories = [
      CategoryItem(
        id: 'documents',
        titleKey: 'cat_documents',
        iconPath: 'assets/icons/doc_logo.png',
        fallbackIcon: Icons.article_rounded,
        color: AppColors.accentRed,
      ),
      CategoryItem(
        id: 'images',
        titleKey: 'cat_images',
        iconPath: 'assets/icons/image_logo.png',
        fallbackIcon: Icons.image_rounded,
        color: AppColors.accentGreen,
      ),
      CategoryItem(
        id: 'audio',
        titleKey: 'cat_audio',
        iconPath: 'assets/icons/music_logo.png',
        fallbackIcon: Icons.music_note_rounded,
        color: AppColors.accentOrange,
      ),
      CategoryItem(
        id: 'video',
        titleKey: 'cat_video',
        iconPath: 'assets/icons/video_logo.png',
        fallbackIcon: Icons.video_collection_rounded,
        color: AppColors.accentBlue,
      ),
      CategoryItem(
        id: 'others',
        titleKey: 'cat_others',
        fallbackIcon: Icons.widgets_rounded,
        color: AppColors.primarySecondary,
      ),
      CategoryItem(
        id: 'favorites',
        titleKey: 'cat_favorites',
        fallbackIcon: Icons.star_rounded,
        color: Colors.amber,
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.85,
      ),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final cat = categories[index];
        return InkWell(
          onTap: () {
            if (cat.id == 'favorites') {
              widget.onTabChange(2); // Go to favorites tab
            } else {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ConversionPage(initialCategory: cat.id),
                ),
              ).then((_) => _loadHistory());
            }
          },
          borderRadius: BorderRadius.circular(16),
          child: Container(
            decoration: BoxDecoration(
              gradient: AppColors.cardGradient,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.surfaceLight.withOpacity(0.5), width: 1.0),
            ),
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Icon / Logo
                cat.iconPath != null
                    ? SizedBox(
                        width: 44,
                        height: 44,
                        child: Image.asset(
                          cat.iconPath!,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) {
                            return Icon(cat.fallbackIcon, color: cat.color, size: 36);
                          },
                        ),
                      )
                    : Icon(cat.fallbackIcon, color: cat.color, size: 38),
                const SizedBox(height: 10),
                Text(
                  cat.titleKey.tr,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
      decoration: BoxDecoration(
        color: AppColors.surface.withOpacity(0.5),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Icon(Icons.history_rounded, size: 48, color: AppColors.textSecondary.withOpacity(0.4)),
          const SizedBox(height: 12),
          Text(
            'home_empty_history'.tr,
            style: TextStyle(color: AppColors.textSecondary.withOpacity(0.8), fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryItem(ConversionRecord record) {
    // Get file icon color
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
        trailing: PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert, color: AppColors.textSecondary),
          color: AppColors.surfaceLight,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          onSelected: (value) async {
            if (value == 'favorite') {
              await HistoryService.toggleFavorite(record.id);
              _loadHistory();
            } else if (value == 'delete') {
              await HistoryService.deleteRecord(record.id);
              _loadHistory();
            }
          },
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'favorite',
              child: Row(
                children: [
                  Icon(
                    record.isFavorite ? Icons.star_rounded : Icons.star_border_rounded,
                    color: Colors.amber,
                  ),
                  const SizedBox(width: 8),
                  Text(record.isFavorite ? 'home_remove_favorite'.tr : 'home_add_favorite'.tr),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  const Icon(Icons.delete_outline_rounded, color: AppColors.accentRed),
                  const SizedBox(width: 8),
                  Text('home_delete'.tr, style: const TextStyle(color: AppColors.accentRed)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CategoryItem {
  final String id;
  final String titleKey;
  final String? iconPath;
  final IconData fallbackIcon;
  final Color color;
  final bool isLogo;

  CategoryItem({
    required this.id,
    required this.titleKey,
    this.iconPath,
    required this.fallbackIcon,
    required this.color,
    this.isLogo = false,
  });
}
