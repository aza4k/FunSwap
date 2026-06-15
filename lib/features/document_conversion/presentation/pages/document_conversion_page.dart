import 'package:flutter/material.dart';
import 'package:funswap/features/conversion/presentation/pages/conversion_page.dart';

class DocumentConversionPage extends StatelessWidget {
  const DocumentConversionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const ConversionPage(initialCategory: 'documents');
  }
}
