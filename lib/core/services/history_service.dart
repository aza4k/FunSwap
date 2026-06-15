import 'dart:convert';
import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class ConversionRecord {
  final String id;
  final String originalName;
  final String originalPath;
  final String convertedName;
  final String convertedPath;
  final String fileType; // 'document', 'image', 'audio', 'video', 'other'
  final int fileSize;
  final DateTime timestamp;
  bool isFavorite;

  ConversionRecord({
    required this.id,
    required this.originalName,
    required this.originalPath,
    required this.convertedName,
    required this.convertedPath,
    required this.fileType,
    required this.fileSize,
    required this.timestamp,
    this.isFavorite = false,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'originalName': originalName,
        'originalPath': originalPath,
        'convertedName': convertedName,
        'convertedPath': convertedPath,
        'fileType': fileType,
        'fileSize': fileSize,
        'timestamp': timestamp.toIso8601String(),
        'isFavorite': isFavorite,
      };

  factory ConversionRecord.fromJson(Map<String, dynamic> json) => ConversionRecord(
        id: json['id'] as String,
        originalName: json['originalName'] as String,
        originalPath: json['originalPath'] as String,
        convertedName: json['convertedName'] as String,
        convertedPath: json['convertedPath'] as String,
        fileType: json['fileType'] as String,
        fileSize: json['fileSize'] as int,
        timestamp: DateTime.parse(json['timestamp'] as String),
        isFavorite: (json['isFavorite'] as bool?) ?? false,
      );
}

class HistoryService {
  static const _fileName = 'conversion_history.json';
  
  static Future<File> _getHistoryFile() async {
    final directory = await getApplicationDocumentsDirectory();
    return File(p.join(directory.path, _fileName));
  }

  static Future<List<ConversionRecord>> getHistory() async {
    try {
      final file = await _getHistoryFile();
      if (!await file.exists()) {
        return [];
      }
      final contents = await file.readAsString();
      final List<dynamic> jsonList = jsonDecode(contents) as List<dynamic>;
      return jsonList
          .map((json) => ConversionRecord.fromJson(json as Map<String, dynamic>))
          .toList()
        ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
    } catch (e) {
      print('Error reading history: $e');
      return [];
    }
  }

  static Future<void> saveRecord(ConversionRecord record) async {
    try {
      final history = await getHistory();
      // Remove if already exists with same id (unlikely, but safe)
      history.removeWhere((r) => r.id == record.id);
      history.add(record);
      await _saveHistoryList(history);
    } catch (e) {
      print('Error saving history record: $e');
    }
  }

  static Future<void> toggleFavorite(String id) async {
    try {
      final history = await getHistory();
      final index = history.indexWhere((r) => r.id == id);
      if (index != -1) {
        history[index].isFavorite = !history[index].isFavorite;
        await _saveHistoryList(history);
      }
    } catch (e) {
      print('Error toggling favorite: $e');
    }
  }

  static Future<void> deleteRecord(String id) async {
    try {
      final history = await getHistory();
      history.removeWhere((r) => r.id == id);
      await _saveHistoryList(history);
    } catch (e) {
      print('Error deleting record: $e');
    }
  }

  static Future<void> clearHistory() async {
    try {
      final file = await _getHistoryFile();
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      print('Error clearing history: $e');
    }
  }

  static Future<void> _saveHistoryList(List<ConversionRecord> history) async {
    final file = await _getHistoryFile();
    final jsonList = history.map((r) => r.toJson()).toList();
    await file.writeAsString(jsonEncode(jsonList));
  }
}
