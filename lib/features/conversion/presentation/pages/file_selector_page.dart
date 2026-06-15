import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:funswap/core/theme/app_theme.dart';
import 'package:funswap/core/services/localization_service.dart';

class FileSelectorPage extends StatefulWidget {
  final List<String>? allowedExtensions;
  final String title;

  const FileSelectorPage({
    super.key,
    this.allowedExtensions,
    this.title = 'Select File',
  });

  @override
  State<FileSelectorPage> createState() => _FileSelectorPageState();
}

class _FileSelectorPageState extends State<FileSelectorPage> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedTab = 'Barchasi'; // Keep internal ID constant
  File? _selectedFile;
  List<FileItem> _mockFiles = [];
  List<FileItem> _filteredFiles = [];

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
    _generateMockFiles();
    _searchController.addListener(_filterFiles);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _generateMockFiles() {
    _mockFiles = [
      FileItem(name: 'Document.pdf', size: 2.4 * 1024 * 1024, type: 'document', date: '23.05.2024', path: '/mock/Document.pdf'),
      FileItem(name: 'Report.docx', size: 1.8 * 1024 * 1024, type: 'document', date: '22.05.2024', path: '/mock/Report.docx'),
      FileItem(name: 'Image.jpg', size: 3.2 * 1024 * 1024, type: 'image', date: '21.05.2024', path: '/mock/Image.jpg'),
      FileItem(name: 'Music.mp3', size: 4.7 * 1024 * 1024, type: 'audio', date: '20.05.2024', path: '/mock/Music.mp3'),
      FileItem(name: 'Video.mp4', size: 15.6 * 1024 * 1024, type: 'video', date: '19.05.2024', path: '/mock/Video.mp4'),
      FileItem(name: 'Presentation.pptx', size: 6.1 * 1024 * 1024, type: 'document', date: '18.05.2024', path: '/mock/Presentation.pptx'),
    ];
    _filterFiles();
  }

  void _filterFiles() {
    final query = _searchController.text.toLowerCase();
    List<FileItem> result = _mockFiles;

    // Filter by Tab
    if (_selectedTab != 'Barchasi') {
      String typeMap = 'other';
      if (_selectedTab == 'Hujjatlar') typeMap = 'document';
      if (_selectedTab == 'Rasmlar') typeMap = 'image';
      if (_selectedTab == 'Audio') typeMap = 'audio';
      if (_selectedTab == 'Video') typeMap = 'video';
      result = result.where((f) => f.type == typeMap).toList();
    }

    // Filter by Extensions if defined in widget
    if (widget.allowedExtensions != null && widget.allowedExtensions!.isNotEmpty) {
      result = result.where((f) {
        final ext = f.name.split('.').last.toLowerCase();
        return widget.allowedExtensions!.contains(ext);
      }).toList();
    }

    // Filter by Search Query
    if (query.isNotEmpty) {
      result = result.where((f) => f.name.toLowerCase().contains(query)).toList();
    }

    setState(() {
      _filteredFiles = result;
    });
  }

  Future<void> _pickFromSystem() async {
    try {
      FileType fileType = FileType.any;
      if (widget.allowedExtensions != null && widget.allowedExtensions!.isNotEmpty) {
        if (widget.allowedExtensions!.every((e) => ['png', 'jpg', 'jpeg', 'webp', 'gif', 'bmp'].contains(e))) {
          fileType = FileType.image;
        } else if (widget.allowedExtensions!.every((e) => ['mp3', 'wav', 'aac', 'ogg', 'flac'].contains(e))) {
          fileType = FileType.audio;
        } else if (widget.allowedExtensions!.every((e) => ['mp4', 'avi', 'mkv', 'mov'].contains(e))) {
          fileType = FileType.video;
        } else {
          fileType = FileType.custom;
        }
      }

      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: fileType,
        allowedExtensions: fileType == FileType.custom ? widget.allowedExtensions : null,
      );

      if (result != null && result.files.single.path != null) {
        final file = File(result.files.single.path!);
        if (mounted) {
          Navigator.pop(context, file);
        }
      }
    } catch (e) {
      print('Error picking file: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(widget.title),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
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
          
          // Filter Chips
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
                          _selectedFile = null; // Clear selection when tab changes
                        });
                        _filterFiles();
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
          
          // Files list or Empty State
          Expanded(
            child: _filteredFiles.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                    itemCount: _filteredFiles.length,
                    itemBuilder: (context, index) {
                      final item = _filteredFiles[index];
                      final isSelected = _selectedFile != null && _selectedFile!.path == item.path;
                      
                      return _buildFileItem(item, isSelected);
                    },
                  ),
          ),
          
          // Bottom Actions
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _pickFromSystem,
                    icon: const Icon(Icons.cloud_upload_outlined, color: Colors.white),
                    label: Text('pick_system'.tr, style: const TextStyle(color: Colors.white)),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: const BorderSide(color: AppColors.primary, width: 1.5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ),
                if (_selectedFile != null) ...[
                  const SizedBox(width: 16),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: AppColors.primaryGradient,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context, _selectedFile);
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('${'selected_count'.tr} (1)', style: const TextStyle(fontWeight: FontWeight.bold)),
                            const SizedBox(width: 8),
                            const Icon(Icons.arrow_forward, size: 18),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.folder_off_rounded,
            size: 64,
            color: AppColors.textSecondary.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'no_files'.tr,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'no_files_desc'.tr,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFileItem(FileItem item, bool isSelected) {
    Color fileColor = AppColors.accentBlue;
    IconData fileIcon = Icons.insert_drive_file_rounded;
    
    if (item.type == 'document') {
      fileColor = AppColors.accentRed;
      fileIcon = Icons.description_rounded;
    } else if (item.type == 'image') {
      fileColor = AppColors.accentGreen;
      fileIcon = Icons.image_rounded;
    } else if (item.type == 'audio') {
      fileColor = AppColors.accentOrange;
      fileIcon = Icons.audiotrack_rounded;
    } else if (item.type == 'video') {
      fileColor = Colors.purple;
      fileIcon = Icons.video_library_rounded;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isSelected ? AppColors.primary.withOpacity(0.1) : AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSelected ? AppColors.primary : AppColors.surfaceLight.withOpacity(0.4),
          width: isSelected ? 1.5 : 1,
        ),
      ),
      child: ListTile(
        onTap: () {
          setState(() {
            if (isSelected) {
              _selectedFile = null;
            } else {
              _selectedFile = File(item.path);
            }
          });
        },
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
          item.name,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.white),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4.0),
          child: Text(
            '${(item.size / (1024 * 1024)).toStringAsFixed(1)} MB • ${item.date}',
            style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
          ),
        ),
        trailing: Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: isSelected ? AppColors.primary : AppColors.textSecondary.withOpacity(0.5),
              width: 2,
            ),
            color: isSelected ? AppColors.primary : Colors.transparent,
          ),
          child: isSelected
              ? const Icon(Icons.check, size: 16, color: Colors.white)
              : null,
        ),
      ),
    );
  }
}

class FileItem {
  final String name;
  final double size;
  final String type;
  final String date;
  final String path;

  FileItem({
    required this.name,
    required this.size,
    required this.type,
    required this.date,
    required this.path,
  });
}
