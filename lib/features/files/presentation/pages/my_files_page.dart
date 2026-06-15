import 'dart:io';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:open_filex/open_filex.dart';
import 'package:funswap/core/theme/app_theme.dart';
import 'package:funswap/core/services/history_service.dart';
import 'package:path/path.dart' as p;
import 'package:funswap/core/services/localization_service.dart';
import 'package:funswap/core/utils/format_utils.dart';

class MyFilesPage extends StatefulWidget {
  final Function(int) onTabChange;
  const MyFilesPage({super.key, required this.onTabChange});

  @override
  State<MyFilesPage> createState() => _MyFilesPageState();
}

class _MyFilesPageState extends State<MyFilesPage> {
  List<ConversionRecord> _allRecords = [];
  List<ConversionRecord> _filteredRecords = [];
  bool _isLoading = true;
  String _selectedTab = 'Barchasi';
  final TextEditingController _searchController = TextEditingController();

  final List<Map<String, String>> _tabItems = [
    {'id': 'Barchasi', 'key': 'home_all'},
    {'id': 'Hujjatlar', 'key': 'cat_documents'},
    {'id': 'Rasmlar', 'key': 'cat_images'},
    {'id': 'Audio', 'key': 'cat_audio'},
    {'id': 'Video', 'key': 'cat_video'},
  ];

  @override
  void initState() {
    super.initState();
    _loadRecords();
    _searchController.addListener(_filterRecords);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadRecords() async {
    setState(() => _isLoading = true);
    final history = await HistoryService.getHistory();
    if (mounted) {
      setState(() {
        _allRecords = history;
        _isLoading = false;
      });
      _filterRecords();
    }
  }

  void _filterRecords() {
    final query = _searchController.text.toLowerCase();
    List<ConversionRecord> result = _allRecords;

    // Filter by Tab
    if (_selectedTab != 'Barchasi') {
      String typeMap = 'other';
      if (_selectedTab == 'Hujjatlar') typeMap = 'document';
      if (_selectedTab == 'Rasmlar') typeMap = 'image';
      if (_selectedTab == 'Audio') typeMap = 'audio';
      if (_selectedTab == 'Video') typeMap = 'video';
      result = result.where((r) => r.fileType == typeMap).toList();
    }

    // Filter by Search Query
    if (query.isNotEmpty) {
      result = result
          .where((r) =>
              r.originalName.toLowerCase().contains(query) ||
              r.convertedName.toLowerCase().contains(query))
          .toList();
    }

    setState(() {
      _filteredRecords = result;
    });
  }



  Future<void> _openFile(String path) async {
    final file = File(path);
    if (!await file.exists()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('file_not_found'.tr)),
      );
      return;
    }
    await OpenFilex.open(path);
  }

  String _getMimeType(String path) {
    final ext = p.extension(path).toLowerCase().replaceAll('.', '');
    switch (ext) {
      case 'png':
        return 'image/png';
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'webp':
        return 'image/webp';
      case 'gif':
        return 'image/gif';
      case 'bmp':
        return 'image/bmp';
      case 'pdf':
        return 'application/pdf';
      case 'csv':
        return 'text/csv';
      case 'xlsx':
        return 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet';
      case 'mp3':
        return 'audio/mpeg';
      case 'wav':
        return 'audio/wav';
      case 'mp4':
        return 'video/mp4';
      case 'mkv':
        return 'video/x-matroska';
      case 'avi':
        return 'video/x-msvideo';
      case 'mov':
        return 'video/quicktime';
      default:
        return 'application/octet-stream';
    }
  }

  Future<void> _shareFile(String path) async {
    final file = File(path);
    if (!await file.exists()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('file_not_found'.tr)),
      );
      return;
    }
    await Share.shareXFiles([XFile(path, mimeType: _getMimeType(path))]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('files_title'.tr),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadRecords,
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'files_search'.tr,
                prefixIcon: const Icon(Icons.search, color: AppColors.textSecondary),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: AppColors.textSecondary),
                        onPressed: () => _searchController.clear(),
                      )
                    : null,
              ),
            ),
          ),
          
          // Filter Chips / Tabs
          SizedBox(
            height: 48,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              itemCount: _tabItems.length,
              itemBuilder: (context, index) {
                final tab = _tabItems[index];
                final isSelected = _selectedTab == tab['id'];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: ChoiceChip(
                    label: Text(tab['key']!.tr),
                    selected: isSelected,
                    onSelected: (selected) {
                      if (selected) {
                        setState(() {
                          _selectedTab = tab['id']!;
                        });
                        _filterRecords();
                      }
                    },
                    backgroundColor: AppColors.surface,
                    selectedColor: AppColors.primary,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : AppColors.textSecondary,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide.none,
                    ),
                    showCheckmark: false,
                  ),
                );
              },
            ),
          ),
          
          const SizedBox(height: 10),
          
          // Files List
          Expanded(
            child: RefreshIndicator(
              onRefresh: _loadRecords,
              color: AppColors.primary,
              backgroundColor: AppColors.surface,
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _filteredRecords.isEmpty
                      ? _buildEmptyState()
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                          itemCount: _filteredRecords.length,
                          itemBuilder: (context, index) {
                            return _buildFileItem(_filteredRecords[index]);
                          },
                        ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.5,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.folder_open_rounded,
                size: 64,
                color: AppColors.textSecondary.withOpacity(0.3),
              ),
              const SizedBox(height: 16),
              Text(
                'files_empty'.tr,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                _searchController.text.isNotEmpty
                    ? 'files_empty_search'.tr
                    : 'files_empty_desc'.tr,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFileItem(ConversionRecord record) {
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
        onTap: () => _openFile(record.convertedPath),
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
          '${record.originalName.split('.').first} → ${record.convertedName}',
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
            if (value == 'open') {
              _openFile(record.convertedPath);
            } else if (value == 'share') {
              _shareFile(record.convertedPath);
            } else if (value == 'favorite') {
              await HistoryService.toggleFavorite(record.id);
              _loadRecords();
            } else if (value == 'delete') {
              await HistoryService.deleteRecord(record.id);
              _loadRecords();
            }
          },
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'open',
              child: Row(
                children: [
                  const Icon(Icons.folder_open_rounded, color: Colors.white),
                  const SizedBox(width: 8),
                  Text('open_file'.tr),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'share',
              child: Row(
                children: [
                  const Icon(Icons.share_outlined, color: Colors.white),
                  const SizedBox(width: 8),
                  Text('share'.tr),
                ],
              ),
            ),
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
