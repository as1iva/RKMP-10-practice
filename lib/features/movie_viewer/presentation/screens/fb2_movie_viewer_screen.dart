import 'dart:io';

import 'package:flutter/material.dart';

import 'package:movie_catalog/features/movies/models/movie.dart';

class Fb2MovieViewerScreen extends StatelessWidget {
  final Movie movie;

  const Fb2MovieViewerScreen({super.key, required this.movie});

  Future<String> _loadPreview() async {
    try {
      final file = File(movie.filePath!);
      final raw = await file.readAsString();
      // Extract a small text preview to keep UI fast.
      return raw.replaceAll(RegExp(r'<[^>]*>'), '').replaceAll('&nbsp;', ' ').trim();
    } catch (_) {
      return 'Не удалось прочитать файл фильма.';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(movie.name)),
      body: FutureBuilder<String>(
        future: _loadPreview(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final text = snapshot.data ?? 'Файл пустой';
          return Padding(
            padding: const EdgeInsets.all(16),
            child: SingleChildScrollView(
              child: Text(
                text,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.5),
              ),
            ),
          );
        },
      ),
    );
  }
}
