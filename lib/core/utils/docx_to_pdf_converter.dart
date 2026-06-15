import 'dart:convert';
import 'dart:io';
import 'package:archive/archive.dart';
import 'package:pdf/widgets.dart' as pw;

class DocxToPdfConverter {
  static Future<File> convert(File docxFile, File outputFile) async {
    try {
      final bytes = await docxFile.readAsBytes();
      final archive = ZipDecoder().decodeBytes(bytes);
      
      String documentXml = '';
      for (final file in archive) {
        if (file.name == 'word/document.xml') {
          documentXml = utf8.decode(file.content as List<int>);
          break;
        }
      }
      
      if (documentXml.isEmpty) {
        throw Exception('Invalid DOCX file: word/document.xml not found.');
      }
      
      final pdf = pw.Document();
      final List<pw.Widget> pdfWidgets = [];
      
      // Parse paragraphs
      final pRegExp = RegExp(r'<w:p\b[^>]*>(.*?)</w:p>', dotAll: true);
      final rRegExp = RegExp(r'<w:r\b[^>]*>(.*?)</w:r>', dotAll: true);
      final tRegExp = RegExp(r'<w:t\b[^>]*>(.*?)</w:t>', dotAll: true);
      
      final pMatches = pRegExp.allMatches(documentXml);
      for (final pMatch in pMatches) {
        final pContent = pMatch.group(1) ?? '';
        
        final List<pw.InlineSpan> spans = [];
        final rMatches = rRegExp.allMatches(pContent);
        
        for (final rMatch in rMatches) {
          final rContent = rMatch.group(1) ?? '';
          final isBold = rContent.contains('<w:b') || rContent.contains('w:b/>') || rContent.contains('w:b ');
          final isItalic = rContent.contains('<w:i') || rContent.contains('w:i/>') || rContent.contains('w:i ');
          
          final tMatch = tRegExp.firstMatch(rContent);
          if (tMatch != null) {
            String text = tMatch.group(1) ?? '';
            text = _decodeXmlEntities(text);
            
            spans.add(
              pw.TextSpan(
                text: text,
                style: pw.TextStyle(
                  fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal,
                  fontStyle: isItalic ? pw.FontStyle.italic : pw.FontStyle.normal,
                ),
              ),
            );
          }
        }
        
        if (spans.isNotEmpty) {
          pdfWidgets.add(
            pw.Padding(
              padding: const pw.EdgeInsets.only(bottom: 8),
              child: pw.RichText(
                text: pw.TextSpan(
                  children: spans,
                  style: const pw.TextStyle(fontSize: 12),
                ),
              ),
            ),
          );
        } else {
          // Empty paragraph
          pdfWidgets.add(pw.SizedBox(height: 12));
        }
      }
      
      if (pdfWidgets.isEmpty) {
        pdfWidgets.add(pw.Center(child: pw.Text('Empty Document')));
      }
      
      pdf.addPage(
        pw.MultiPage(
          build: (pw.Context context) => pdfWidgets,
        ),
      );
      
      await outputFile.writeAsBytes(await pdf.save());
      return outputFile;
    } catch (e) {
      throw Exception('Error converting DOCX to PDF: $e');
    }
  }
  
  static String _decodeXmlEntities(String text) {
    return text
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&quot;', '"')
        .replaceAll('&apos;', "'")
        .replaceAll('&#39;', "'");
  }
}
