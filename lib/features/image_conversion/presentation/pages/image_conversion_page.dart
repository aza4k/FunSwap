import 'package:flutter/material.dart';
import 'package:funswap/features/conversion/presentation/pages/conversion_page.dart';

class ImageConversionPage extends StatelessWidget {
  const ImageConversionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const ConversionPage(initialCategory: 'images');
  }
}
