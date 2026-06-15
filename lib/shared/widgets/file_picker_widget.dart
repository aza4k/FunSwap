import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';

class FilePickerWidget extends StatefulWidget {
  final String buttonText;
  final Function(File?) onFilePicked;
  final FileType allowedFileType;
  final List<String>? allowedExtensions;

  const FilePickerWidget({
    super.key,
    required this.buttonText,
    required this.onFilePicked,
    this.allowedFileType = FileType.any,
    this.allowedExtensions,
  });

  @override
  State<FilePickerWidget> createState() => _FilePickerWidgetState();
}

class _FilePickerWidgetState extends State<FilePickerWidget> {
  File? _pickedFile;

  Future<void> _pickFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: widget.allowedFileType,
        allowedExtensions: widget.allowedExtensions,
      );

      if (result != null && result.files.single.path != null) {
        setState(() {
          _pickedFile = File(result.files.single.path!);
        });
        widget.onFilePicked(_pickedFile);
      } else {
        // User canceled the picker
        setState(() {
          _pickedFile = null;
        });
        widget.onFilePicked(null);
      }
    } catch (e) {
      print('Error picking file: $e');
      setState(() {
        _pickedFile = null;
      });
      widget.onFilePicked(null);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking file: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ElevatedButton.icon(
          onPressed: _pickFile,
          icon: const Icon(Icons.upload_file),
          label: Text(widget.buttonText),
        ),
        if (_pickedFile != null)
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Selected File: ${_pickedFile!.path.split('/').last}', style: const TextStyle(fontWeight: FontWeight.bold)),
                FutureBuilder<int>(
                  future: _pickedFile!.length(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      return Text('Size: ${(snapshot.data! / (1024 * 1024)).toStringAsFixed(2)} MB');
                    } else {
                      return const Text('Size: Calculating...');
                    }
                  },
                ),
                Text('Path: ${_pickedFile!.path}'),
              ],
            ),
          ),
      ],
    );
  }
}
