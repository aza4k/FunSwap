import 'dart:io';
import 'dart:isolate';
import 'package:csv/csv.dart';
import 'package:excel/excel.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path/path.dart' as p;
import 'package:funswap/core/errors/exceptions.dart';
import 'package:funswap/core/errors/file_system_exception_mapper.dart';
import 'package:funswap/core/services/file_service.dart';
import 'package:funswap/core/utils/docx_to_pdf_converter.dart';


abstract class DocumentConversionLocalDataSource {
  Future<File> convertImageToPdf({
    required List<File> imageFiles,
    required String outputDirectory,
    required String outputFileName,
  });

  Future<File> convertCsvToExcel({
    required File csvFile,
    required String outputDirectory,
  });

  Future<File> convertExcelToCsv({
    required File excelFile,
    required String outputDirectory,
  });

  Future<File> convertDocxToPdf({
    required File docxFile,
    required String outputDirectory,
  });
}

class DocumentConversionLocalDataSourceImpl implements DocumentConversionLocalDataSource {
  @override
  Future<File> convertImageToPdf({
    required List<File> imageFiles,
    required String outputDirectory,
    required String outputFileName,
  }) async {
    try {
      final outputFile = File(
        p.join(
          outputDirectory,
          _safeOutputName(outputFileName, 'pdf'),
        ),
      );

      final imagePaths = imageFiles.map((file) => file.path).toList();
      final pdfBytes = await Isolate.run(
        () => _convertImagesToPdfBytes(imagePaths),
      );

      await outputFile.writeAsBytes(pdfBytes);
      return outputFile;
    } on ConversionException {
      rethrow;
    } on PermissionException {
      rethrow;
    } on LowStorageException {
      rethrow;
    } on FileSystemException catch (e) {
      throwMappedFileSystemException(e, 'Could not write converted PDF');
    } catch (e) {
      throw ConversionException('Error converting images to PDF: $e');
    }
  }

  @override
  Future<File> convertCsvToExcel({
    required File csvFile,
    required String outputDirectory,
  }) async {
    try {
      final fileName = FileService.generateFileName('xlsx');
      final outputFile = File(p.join(outputDirectory, fileName));

      final outputBytes = await Isolate.run(
        () => _convertCsvToExcelBytes(csvFile.path),
      );

      await outputFile.writeAsBytes(outputBytes);
      return outputFile;
    } on ConversionException {
      rethrow;
    } on PermissionException {
      rethrow;
    } on LowStorageException {
      rethrow;
    } on FileSystemException catch (e) {
      throwMappedFileSystemException(e, 'Could not write converted Excel file');
    } catch (e) {
      throw ConversionException('Error converting CSV to Excel: $e');
    }
  }

  @override
  Future<File> convertExcelToCsv({
    required File excelFile,
    required String outputDirectory,
  }) async {
    try {
      final csvString = await Isolate.run(
        () => _convertExcelToCsvString(excelFile.path),
      );

      final fileName = FileService.generateFileName('csv');
      final outputFile = File(p.join(outputDirectory, fileName));
      
      await outputFile.writeAsString(csvString);
      return outputFile;
    } on ConversionException {
      rethrow;
    } on PermissionException {
      rethrow;
    } on LowStorageException {
      rethrow;
    } on FileSystemException catch (e) {
      throwMappedFileSystemException(e, 'Could not write converted CSV file');
    } catch (e) {
      throw ConversionException('Error converting Excel to CSV: $e');
    }
  }

  @override
  Future<File> convertDocxToPdf({
    required File docxFile,
    required String outputDirectory,
  }) async {
    try {
      final fileName = FileService.generateFileName('pdf');
      final outputFile = File(p.join(outputDirectory, fileName));
      return await DocxToPdfConverter.convert(docxFile, outputFile);
    } on ConversionException {
      rethrow;
    } on PermissionException {
      rethrow;
    } on LowStorageException {
      rethrow;
    } on FileSystemException catch (e) {
      throwMappedFileSystemException(e, 'Could not write converted PDF file');
    } catch (e) {
      throw ConversionException('Error converting DOCX to PDF: $e');
    }
  }

  String _safeOutputName(String baseName, String extension) {
    final sanitized = baseName
        .trim()
        .replaceAll(RegExp(r'[<>:"/\\|?*\x00-\x1F]'), '_')
        .replaceAll(RegExp(r'_+'), '_');
    final name = sanitized.isEmpty ? 'FunSwap' : sanitized;
    return '$name.$extension';
  }

  static String _convertExcelToCsvString(String excelPath) {
    final bytes = File(excelPath).readAsBytesSync();
    final excel = Excel.decodeBytes(bytes);

    final List<List<dynamic>> csvData = [];
    for (final table in excel.tables.keys) {
      for (final row in excel.tables[table]!.rows) {
        csvData.add(row.map((cell) => cell?.value).toList());
      }
    }

    const converter = ListToCsvConverter();
    return converter.convert(csvData);
  }

  static List<int> _convertCsvToExcelBytes(String csvPath) {
    final csvString = File(csvPath).readAsStringSync(encoding: const SystemEncoding());
    final fields = const CsvToListConverter().convert(csvString);

    final excel = Excel.createExcel();
    final sheet = excel[excel.getDefaultSheet()!];

    for (var row = 0; row < fields.length; row++) {
      for (var col = 0; col < fields[row].length; col++) {
        final cell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: col, rowIndex: row));
        cell.value = fields[row][col];
      }
    }
    return excel.encode()!;
  }

  static Future<List<int>> _convertImagesToPdfBytes(List<String> imagePaths) async {
    final pdf = pw.Document();

    for (final path in imagePaths) {
      final imageBytes = File(path).readAsBytesSync();
      final image = pw.MemoryImage(imageBytes);
      pdf.addPage(
        pw.Page(
          build: (pw.Context context) {
            return pw.Center(
              child: pw.Image(image),
            );
          },
        ),
      );
    }
    return await pdf.save();
  }
}
