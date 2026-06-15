import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:funswap/core/theme/app_theme.dart';
import 'package:funswap/core/services/history_service.dart';
import 'package:funswap/core/services/file_service.dart';
import 'package:funswap/core/conversion/conversion_registry.dart';
import 'package:funswap/features/conversion/presentation/pages/file_selector_page.dart';
import 'package:funswap/injection_container.dart';
import 'package:funswap/features/image_conversion/presentation/cubit/image_conversion_cubit.dart';
import 'package:funswap/features/document_conversion/presentation/cubit/document_conversion_cubit.dart';
import 'package:funswap/features/media_conversion/presentation/cubit/media_conversion_cubit.dart';
import 'package:share_plus/share_plus.dart';
import 'package:open_filex/open_filex.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as p;
import 'package:funswap/core/services/localization_service.dart';
import 'package:funswap/core/utils/format_utils.dart';

class ConversionPage extends StatelessWidget {
  final String? initialCategory;
  const ConversionPage({super.key, this.initialCategory});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<ImageConversionCubit>(
          create: (context) => sl<ImageConversionCubit>(),
        ),
        BlocProvider<DocumentConversionCubit>(
          create: (context) => sl<DocumentConversionCubit>(),
        ),
        BlocProvider<MediaConversionCubit>(
          create: (context) => sl<MediaConversionCubit>(),
        ),
      ],
      child: ConversionView(initialCategory: initialCategory),
    );
  }
}

class ConversionView extends StatefulWidget {
  final String? initialCategory;
  const ConversionView({super.key, this.initialCategory});

  @override
  State<ConversionView> createState() => _ConversionViewState();
}

class _ConversionViewState extends State<ConversionView> {
  String _inputFormat = 'docx';
  String _outputFormat = 'pdf';
  File? _selectedFile;
  bool _isConverting = false;
  double? _progress = 0.0;
  bool _isSuccess = false;
  File? _convertedFile;
  List<ConversionRecord> _recentConversions = [];

  // Allowed Formats Lists
  final List<String> _inputFormats = [
    'pdf', 'docx', 'csv', 'xlsx',
    'png', 'jpg', 'jpeg', 'webp',
    'mp3', 'wav', 'mp4', 'mkv', 'avi', 'mov'
  ];

  @override
  void initState() {
    super.initState();
    _setInitialCategoryFormats();
    _loadRecentConversions();
  }

  void _setInitialCategoryFormats() {
    if (widget.initialCategory == null) return;
    
    if (widget.initialCategory == 'documents') {
      setState(() {
        _inputFormat = 'docx';
        _outputFormat = 'pdf';
      });
    } else if (widget.initialCategory == 'images') {
      setState(() {
        _inputFormat = 'png';
        _outputFormat = 'jpg';
      });
    } else if (widget.initialCategory == 'audio') {
      setState(() {
        _inputFormat = 'wav';
        _outputFormat = 'mp3';
      });
    } else if (widget.initialCategory == 'video') {
      setState(() {
        _inputFormat = 'mp4';
        _outputFormat = 'avi';
      });
    }
  }

  Future<void> _loadRecentConversions() async {
    final history = await HistoryService.getHistory();
    if (mounted) {
      setState(() {
        _recentConversions = history.take(2).toList();
      });
    }
  }

  List<String> _getAvailableOutputFormats(String input) {
    if (ConversionRegistry.imageOutputFormats.contains(input)) {
      final list = ConversionRegistry.imageOutputFormats.toList();
      if (['png', 'jpg', 'jpeg', 'webp'].contains(input)) {
        list.add('pdf');
      }
      return list;
    }
    if (input == 'docx') return ['pdf'];
    if (input == 'pdf') return ['png', 'jpg'];
    if (input == 'csv') return ['xlsx'];
    if (input == 'xlsx') return ['csv'];
    if (input == 'mp4' || input == 'mkv' || input == 'avi' || input == 'mov') {
      return ['mp3', 'wav', 'mp4', 'mkv', 'avi', 'mov'];
    }
    if (input == 'mp3' || input == 'wav') {
      return ['mp3', 'wav'];
    }
    return [];
  }

  void _onInputFormatChanged(String? newValue) {
    if (newValue == null) return;
    final outputs = _getAvailableOutputFormats(newValue);
    setState(() {
      _inputFormat = newValue;
      _outputFormat = outputs.contains(_outputFormat) ? _outputFormat : outputs.first;
      _selectedFile = null; // Reset file selection
    });
  }

  void _swapFormats() {
    if (_inputFormats.contains(_outputFormat)) {
      final oldInput = _inputFormat;
      final oldOutput = _outputFormat;
      final outputs = _getAvailableOutputFormats(oldOutput);
      setState(() {
        _inputFormat = oldOutput;
        _outputFormat = outputs.contains(oldInput) ? oldInput : outputs.first;
        _selectedFile = null;
      });
    }
  }

  Future<void> _selectFile() async {
    final resultFile = await Navigator.push<File?>(
      context,
      MaterialPageRoute(
        builder: (context) => FileSelectorPage(
          allowedExtensions: [_inputFormat],
          title: '${_inputFormat.toUpperCase()} ${'select_input_file'.tr}',
        ),
      ),
    );

    if (resultFile != null) {
      final sizeInBytes = await resultFile.length();
      final sizeInMb = sizeInBytes / (1024 * 1024);
      
      double limitMb = 150.0;
      final isImage = ConversionRegistry.imageOutputFormats.contains(_inputFormat);
      final isDoc = ['csv', 'xlsx', 'docx', 'pdf'].contains(_inputFormat);
      
      if (isImage) {
        limitMb = 25.0;
      } else if (isDoc) {
        limitMb = 15.0;
      }
      
      if (sizeInMb > limitMb) {
        final proceed = await _showSizeWarningDialog(sizeInMb, limitMb);
        if (proceed != true) return;
      }

      setState(() {
        _selectedFile = resultFile;
      });
    }
  }

  Future<bool?> _showSizeWarningDialog(double sizeInMb, double limitMb) {
    return showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.surface,
          title: Text(
            'file_too_large_title'.tr,
            style: const TextStyle(color: AppColors.accentRed, fontWeight: FontWeight.bold),
          ),
          content: Text(
            'file_too_large_desc'.tr,
            style: const TextStyle(color: Colors.white),
          ),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text('cancel'.tr, style: const TextStyle(color: AppColors.textSecondary)),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accentRed,
              ),
              child: Text(
                'proceed_anyway'.tr,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }



  Future<void> _startConversion() async {
    if (_selectedFile == null) return;

    final isMedia = ConversionRegistry.mediaOutputsFor(_selectedFile!.path).contains(_outputFormat);
    final isImage = ConversionRegistry.imageOutputFormats.contains(_inputFormat) && 
        ConversionRegistry.imageOutputFormats.contains(_outputFormat);
    
    final isDoc = (['png', 'jpg', 'jpeg', 'webp'].contains(_inputFormat) && _outputFormat == 'pdf') ||
        (_inputFormat == 'csv' && _outputFormat == 'xlsx') ||
        (_inputFormat == 'xlsx' && _outputFormat == 'csv') ||
        (_inputFormat == 'docx' && _outputFormat == 'pdf');

    final isMock = _selectedFile!.path.startsWith('/mock/');

    if (isMock) {
      _startFallbackConversion();
    } else if (isImage) {
      final cubit = context.read<ImageConversionCubit>();
      cubit.fileSelected(_selectedFile);
      cubit.outputFormatSelected(_outputFormat);
      cubit.convertImageNow();
    } else if (isDoc) {
      final cubit = context.read<DocumentConversionCubit>();
      cubit.fileSelected(_selectedFile);
      cubit.outputFormatSelected(_outputFormat);
      cubit.convertDocument();
    } else if (isMedia) {
      final cubit = context.read<MediaConversionCubit>();
      cubit.fileSelected(_selectedFile);
      cubit.outputFormatSelected(_outputFormat);
      cubit.convertMediaNow();
    } else {
      _startFallbackConversion();
    }
  }

  Future<void> _onConversionSuccess(File outputResultFile, String category) async {
    final record = ConversionRecord(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      originalName: p.basename(_selectedFile!.path),
      originalPath: _selectedFile!.path,
      convertedName: p.basename(outputResultFile.path),
      convertedPath: outputResultFile.path,
      fileType: category,
      fileSize: await outputResultFile.length(),
      timestamp: DateTime.now(),
    );
    await HistoryService.saveRecord(record);

    if (mounted) {
      setState(() {
        _isConverting = false;
        _isSuccess = true;
        _convertedFile = outputResultFile;
      });
      _loadRecentConversions();
    }
  }

  void _onConversionError(String message) {
    if (mounted) {
      setState(() {
        _isConverting = false;
        _isSuccess = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${'conversion_error'.tr}: $message')),
      );
    }
  }

  Future<void> _startFallbackConversion() async {
    setState(() {
      _isConverting = true;
      _progress = null;
      _isSuccess = false;
    });
    try {
      final funSwapDir = await FileService.getFunSwapDirectory();
      final baseName = p.basenameWithoutExtension(_selectedFile!.path);
      final mockOutName = '${baseName}_converted.$_outputFormat';
      final outputFile = File('${funSwapDir.path}/$mockOutName');
      await outputFile.writeAsString('FunSwap Mock Conversion completed successfully.');
      _onConversionSuccess(outputFile, 'other');
    } catch (e) {
      _onConversionError(e.toString());
    }
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

  Future<void> _saveFileToDevice() async {
    if (_convertedFile == null) return;
    try {
      final bytes = await _convertedFile!.readAsBytes();
      final fileName = p.basename(_convertedFile!.path);
      
      final String? path = await FilePicker.platform.saveFile(
        dialogTitle: 'select_save_location'.tr,
        fileName: fileName,
        bytes: bytes,
      );
      
      if (path != null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${'file_saved'.tr}: $path')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${'save_error'.tr}: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget childWidget;
    if (_isConverting) {
      childWidget = _buildProgressScreen();
    } else if (_isSuccess && _convertedFile != null) {
      childWidget = _buildSuccessScreen();
    } else {
      final outputs = _getAvailableOutputFormats(_inputFormat);
      childWidget = Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: Text('conversion_title'.tr),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),
              
              _buildFormatSelectorCard(
                title: 'from'.tr,
                selectedFormat: _inputFormat,
                formatsList: _inputFormats,
                onChanged: _onInputFormatChanged,
              ),
              
              Center(
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.surface,
                    border: Border.all(color: AppColors.surfaceLight, width: 1.5),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.swap_vert_rounded, color: Colors.white, size: 26),
                    onPressed: _swapFormats,
                  ),
                ),
              ),
              
              _buildFormatSelectorCard(
                title: 'to'.tr,
                selectedFormat: _outputFormat,
                formatsList: outputs,
                onChanged: (val) {
                  if (val != null) setState(() => _outputFormat = val);
                },
              ),
              
              const SizedBox(height: 28),
              
              _buildFileSelectionZone(),
              
              const SizedBox(height: 36),
              
              Text(
                'recent_conversions'.tr,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 12),
              _recentConversions.isEmpty
                  ? _buildEmptyRecentState()
                  : ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _recentConversions.length,
                      itemBuilder: (context, index) {
                        return _buildRecentItem(_recentConversions[index]);
                      },
                    ),
              
              const SizedBox(height: 40),
            ],
          ),
        ),
      );
    }

    return MultiBlocListener(
      listeners: [
        BlocListener<ImageConversionCubit, ImageConversionState>(
          listener: (context, state) {
            if (state is ImageConversionLoading) {
              setState(() {
                _isConverting = true;
                _progress = state.progress;
                _isSuccess = false;
              });
            } else if (state is ImageConversionSuccess) {
              _onConversionSuccess(state.convertedFile, 'image');
            } else if (state is ImageConversionError) {
              _onConversionError(state.message);
            }
          },
        ),
        BlocListener<DocumentConversionCubit, DocumentConversionState>(
          listener: (context, state) {
            if (state is DocumentConversionLoading) {
              setState(() {
                _isConverting = true;
                _progress = state.progress;
                _isSuccess = false;
              });
            } else if (state is DocumentConversionSuccess) {
              _onConversionSuccess(state.convertedFile, 'document');
            } else if (state is DocumentConversionError) {
              _onConversionError(state.message);
            }
          },
        ),
        BlocListener<MediaConversionCubit, MediaConversionState>(
          listener: (context, state) {
            if (state is MediaConversionLoading) {
              setState(() {
                _isConverting = true;
                _progress = state.progress;
                _isSuccess = false;
              });
            } else if (state is MediaConversionSuccess) {
              final isAudioInput = ['mp3', 'wav'].contains(_inputFormat);
              final isAudioOutput = ['mp3', 'wav'].contains(_outputFormat);
              final category = (isAudioInput && isAudioOutput) ? 'audio' : 'video';
              _onConversionSuccess(state.convertedFile, category);
            } else if (state is MediaConversionError) {
              _onConversionError(state.message);
            }
          },
        ),
      ],
      child: childWidget,
    );
  }

  Widget _buildFormatSelectorCard({
    required String title,
    required String selectedFormat,
    required List<String> formatsList,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.surfaceLight.withOpacity(0.4), width: 1),
      ),
      padding: const EdgeInsets.all(18.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.insert_drive_file_outlined, color: AppColors.primary, size: 18),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    selectedFormat.toUpperCase(),
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ],
              ),
            ],
          ),
          
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: AppColors.surfaceLight,
              borderRadius: BorderRadius.circular(12),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: selectedFormat,
                icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.white),
                dropdownColor: AppColors.surfaceLight,
                items: formatsList.map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(
                      value.toUpperCase(),
                      style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  );
                }).toList(),
                onChanged: onChanged,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFileSelectionZone() {
    if (_selectedFile != null) {
      return Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.surfaceLight, width: 1),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(Icons.description_rounded, color: AppColors.primary, size: 30),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _selectedFile!.path.split('/').last,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.white),
                      ),
                      const SizedBox(height: 6),
                      FutureBuilder<int>(
                        future: _selectedFile!.length(),
                        builder: (context, snapshot) {
                          final sizeStr = snapshot.hasData ? FormatUtils.formatSize(snapshot.data!) : 'Calculating...';
                          return Text(
                            sizeStr,
                            style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.cancel_rounded, color: AppColors.textSecondary),
                  onPressed: () => setState(() => _selectedFile = null),
                ),
              ],
            ),
            const SizedBox(height: 20),
            
            Container(
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: _startConversion,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: Text('start_conversion'.tr, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ),
          ],
        ),
      );
    }

    final isUz = appLanguageNotifier.value == 'Uzbekcha';
    final isRu = appLanguageNotifier.value == 'Русский';
    final dragHint = isUz 
        ? 'yoki faylni shu yerga sudrab tashlang' 
        : isRu 
            ? 'или перетащите файл сюда' 
            : 'or drag and drop file here';

    return InkWell(
      onTap: _selectFile,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        height: 140,
        decoration: BoxDecoration(
          color: AppColors.surface.withOpacity(0.4),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.primary.withOpacity(0.3), width: 1.5, style: BorderStyle.solid),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.cloud_upload_outlined, size: 44, color: AppColors.primary),
            const SizedBox(height: 12),
            Text(
              'select_file'.tr,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 6),
            Text(
              dragHint,
              style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyRecentState() {
    final isUz = appLanguageNotifier.value == 'Uzbekcha';
    final isRu = appLanguageNotifier.value == 'Русский';
    final emptyHint = isUz 
        ? 'Yaqin orada konvertatsiyalar bajarilmadi' 
        : isRu 
            ? 'Недавних конверсий не обнаружено' 
            : 'No recent conversions found';

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.surface.withOpacity(0.5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Center(
        child: Text(
          emptyHint,
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
        ),
      ),
    );
  }

  Widget _buildRecentItem(ConversionRecord record) {
    Color fileColor = AppColors.accentBlue;
    if (record.fileType == 'document') fileColor = AppColors.accentRed;
    if (record.fileType == 'image') fileColor = AppColors.accentGreen;
    if (record.fileType == 'audio') fileColor = AppColors.accentOrange;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        dense: true,
        leading: Icon(Icons.insert_drive_file, color: fileColor, size: 20),
        title: Text(record.originalName, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white)),
        subtitle: Text(FormatUtils.formatSize(record.fileSize), style: const TextStyle(color: AppColors.textSecondary)),
        trailing: const Icon(Icons.chevron_right, color: AppColors.textSecondary),
      ),
    );
  }

  Widget _buildProgressScreen() {
    final showPercentage = _progress != null;
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 160,
                  height: 160,
                  child: CircularProgressIndicator(
                    value: _progress,
                    strokeWidth: 8,
                    backgroundColor: AppColors.surfaceLight,
                    valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                  ),
                ),
                if (showPercentage)
                  Text(
                    '${(_progress! * 100).toInt()}%',
                    style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white),
                  )
                else
                  const Icon(Icons.sync, size: 48, color: Colors.white),
              ],
            ),
            const SizedBox(height: 40),
            Text(
              'converting'.tr,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 8),
            Text(
              'please_wait'.tr,
              style: const TextStyle(fontSize: 14, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 48),
            OutlinedButton(
              onPressed: () {
                final isMedia = ConversionRegistry.mediaOutputsFor(_selectedFile?.path ?? '').contains(_outputFormat);
                if (isMedia) {
                  context.read<MediaConversionCubit>().cancelConversion();
                } else {
                  setState(() {
                    _isConverting = false;
                  });
                }
              },
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.surfaceLight),
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text('cancel'.tr, style: const TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuccessScreen() {
    final convertedName = p.basename(_convertedFile!.path);
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Spacer(flex: 3),
            
            // Folder sync graphic mockup
            Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 140,
                    height: 120,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF293241), Color(0xFF3D5A80)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(
                      Icons.folder_open,
                      size: 70,
                      color: Color(0xFF98C1D9),
                    ),
                  ),
                  Positioned(
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.accentGreen,
                      ),
                      child: const Icon(Icons.check, size: 28, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 32),
            
            Text(
              'conversion_success'.tr,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 8),
            Text(
              appLanguageNotifier.value == 'Uzbekcha' 
                  ? 'Faylingiz muvaffaqiyatli konvertatsiya qilindi.'
                  : appLanguageNotifier.value == 'Русский' 
                      ? 'Ваш файл был успешно конвертирован.' 
                      : 'Your file has been successfully converted.',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14, color: AppColors.textSecondary),
            ),
            
            const SizedBox(height: 28),
            
            // File Detail Card
            Container(
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.surfaceLight.withOpacity(0.4), width: 1),
              ),
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Icon(Icons.insert_drive_file, color: AppColors.accentGreen, size: 28),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          convertedName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 14),
                        ),
                        const SizedBox(height: 4),
                        FutureBuilder<int>(
                          future: _convertedFile!.length(),
                          builder: (context, snapshot) {
                            return Text(
                              snapshot.hasData ? FormatUtils.formatSize(snapshot.data!) : '...',
                              style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            const Spacer(flex: 2),
            
            // Actions
            Container(
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(16),
              ),
              child: ElevatedButton(
                onPressed: () => OpenFilex.open(_convertedFile!.path),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: Text('open_file'.tr, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ),
            
            const SizedBox(height: 12),
            
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => Share.shareXFiles([XFile(_convertedFile!.path, mimeType: _getMimeType(_convertedFile!.path))]),
                    icon: const Icon(Icons.share_outlined, color: Colors.white),
                    label: Text('share'.tr, style: const TextStyle(color: Colors.white)),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: const BorderSide(color: AppColors.surfaceLight),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _saveFileToDevice,
                    icon: const Icon(Icons.save_alt_rounded, color: Colors.white),
                    label: Text('save_to_device'.tr, style: const TextStyle(color: Colors.white)),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: const BorderSide(color: AppColors.surfaceLight),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            TextButton(
              onPressed: () {
                setState(() {
                  _isSuccess = false;
                  _selectedFile = null;
                  _convertedFile = null;
                });
              },
              child: Text(
                'convert_another'.tr,
                style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
              ),
            ),
            
            const Spacer(flex: 1),
          ],
        ),
      ),
    );
  }
}
