import 'dart:io';
import 'package:flutter/material.dart';

class FullScreenViewer extends StatelessWidget {
  final String pathOrUrl;
  final String title;

  const FullScreenViewer({
    super.key,
    required this.pathOrUrl,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    final bool isNetwork = pathOrUrl.startsWith('http');

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(title, style: const TextStyle(color: Colors.white)),
        elevation: 0,
      ),
      body: Center(
        child: InteractiveViewer(
          minScale: 0.5,
          maxScale: 4.0,
          child: isNetwork
              ? Image.network(
                  pathOrUrl,
                  fit: BoxFit.contain,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return const Center(child: CircularProgressIndicator(color: Colors.white));
                  },
                )
              : Image.file(
                  File(pathOrUrl),
                  fit: BoxFit.contain,
                ),
        ),
      ),
    );
  }
}
