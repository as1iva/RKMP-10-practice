import 'dart:io';

import 'package:epub_view/epub_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:movie_catalog/features/movies/bloc/movies_bloc.dart';
import 'package:movie_catalog/features/movies/bloc/movies_event.dart';
import 'package:movie_catalog/features/movies/models/movie.dart';

class EpubMovieViewerScreen extends StatefulWidget {
  final Movie movie;

  const EpubMovieViewerScreen({super.key, required this.movie});

  @override
  State<EpubMovieViewerScreen> createState() => _EpubMovieViewerScreenState();
}

class _EpubMovieViewerScreenState extends State<EpubMovieViewerScreen> {
  late EpubController _epubController;
  double _fontSize = 16.0;

  @override
  void initState() {
    super.initState();
    _epubController = EpubController(
      document: EpubDocument.openFile(File(widget.movie.filePath!)),
      epubCfi: widget.movie.lastViewedStep,
    );
  }

  void _saveProgress() {
    final cfi = _epubController.generateEpubCfi();
    if (cfi != null) {
      context.read<MoviesBloc>().add(UpdateMovie(widget.movie.copyWith(lastViewedStep: cfi)));
    }
  }

  @override
  void dispose() {
    _saveProgress();
    _epubController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.movie.filePath == null) {
      return Scaffold(
        appBar: AppBar(title: Text(widget.movie.name)),
        body: const Center(child: Text('Файл фильма не прикреплен')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.movie.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.format_size),
            onPressed: () => setState(() {
              _fontSize = _fontSize >= 26 ? 16 : _fontSize + 2;
            }),
            tooltip: 'Размер текста',
          ),
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: () {
              _saveProgress();
              Navigator.pop(context);
            },
            tooltip: 'Закрыть',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: EpubView(
          controller: _epubController,
          onChapterChanged: (_) => _saveProgress(),
          builders: EpubViewBuilders<DefaultBuilderOptions>(
            options: DefaultBuilderOptions(
              textStyle: TextStyle(
                height: 1.5,
                fontSize: _fontSize,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
