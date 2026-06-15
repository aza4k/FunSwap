import 'dart:io';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:open_filex/open_filex.dart';

class ConversionResultPage extends StatelessWidget {
  final File convertedFile;
  final String conversionType;

  const ConversionResultPage({
    super.key,
    required this.convertedFile,
    required this.conversionType,
  });

  Future<void> _openFile(BuildContext context) async {
    // Check if the file exists before trying to open it
    if (!await convertedFile.exists()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('File not found!')),
      );
      return;
    }

    final result = await OpenFilex.open(convertedFile.path);
    if (result.type != ResultType.done) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not open file: ${result.message}')),
        );
      }
    }
  }

  Future<void> _shareFile(BuildContext context) async {
    if (!await convertedFile.exists()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('File not found!')),
      );
      return;
    }
    await Share.shareXFiles([XFile(convertedFile.path)], text: 'Check out my converted $conversionType!');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Conversion Result'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(
              Icons.check_circle_outline,
              color: Colors.green,
              size: 100,
            ),
            const SizedBox(height: 20),
            Text(
              '$conversionType Conversion Successful!',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Output File Location:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            SelectableText(
              convertedFile.path,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              onPressed: () => _openFile(context),
              icon: const Icon(Icons.folder_open),
              label: const Text('Open File'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 15),
                textStyle: const TextStyle(fontSize: 18),
              ),
            ),
            const SizedBox(height: 15),
            ElevatedButton.icon(
              onPressed: () => _shareFile(context),
              icon: const Icon(Icons.share),
              label: const Text('Share File'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 15),
                textStyle: const TextStyle(fontSize: 18),
              ),
            ),
            const SizedBox(height: 15),
            OutlinedButton.icon(
              onPressed: () {
                Navigator.popUntil(context, (route) => route.isFirst); // Go back to home
              },
              icon: const Icon(Icons.home),
              label: const Text('Go to Home'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 15),
                textStyle: const TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
