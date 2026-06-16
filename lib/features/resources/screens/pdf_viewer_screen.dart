import 'dart:io';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class PdfViewerScreen extends StatelessWidget {
  final String title;
  final String filePath;

  const PdfViewerScreen({
    super.key,
    required this.title,
    required this.filePath,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF111827),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, 
              color: Color(0xFF4F46E5), size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SfPdfViewer.file(
        File(filePath),
        pageLayoutMode: PdfPageLayoutMode.continuous,
      ),
    );
  }
}