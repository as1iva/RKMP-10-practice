import 'package:flutter/material.dart';

import 'package:movie_catalog/features/movie_viewer/presentation/screens/epub_movie_viewer_screen.dart';
import 'package:movie_catalog/features/movie_viewer/presentation/screens/fb2_movie_viewer_screen.dart';
import 'package:movie_catalog/features/movies/models/movie.dart';

class MovieViewerScreen extends StatelessWidget {
  final Movie movie;

  const MovieViewerScreen({super.key, required this.movie});

  @override
  Widget build(BuildContext context) {
    if (movie.filePath == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Файл фильма')),
        body: const Center(child: Text('Файл с описанием не прикреплен')),
      );
    }

    final format = movie.fileFormat?.toLowerCase();

    if (format == 'epub') {
      return EpubMovieViewerScreen(movie: movie);
    } else if (format == 'fb2') {
      return Fb2MovieViewerScreen(movie: movie);
    } else {
      return Scaffold(
        appBar: AppBar(title: const Text('Файл фильма')),
        body: Center(child: Text('Формат $format пока не поддерживается')),
      );
    }
  }
}
