import 'package:flutter/material.dart';
import 'package:funswap/features/conversion/presentation/pages/conversion_page.dart';

class MediaConversionPage extends StatelessWidget {
  const MediaConversionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const ConversionPage(initialCategory: 'audio');
  }
}
