import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:path/path.dart' as path;

import 'package:movie_catalog/core/di/service_locator.dart';
import 'package:movie_catalog/features/movies/bloc/movies_bloc.dart';
import 'package:movie_catalog/features/movies/bloc/movies_event.dart';
import 'package:movie_catalog/features/movies/models/movie.dart';

class ImportMovieScreen extends StatefulWidget {
  const ImportMovieScreen({super.key});

  @override
  State<ImportMovieScreen> createState() => _ImportMovieScreenState();
}

class _ImportMovieScreenState extends State<ImportMovieScreen> {
  bool _isLoading = false;

  Future<void> _pickFile() async {
    setState(() => _isLoading = true);

    try {
      final file = await Repositories.files.pickFile();
      if (file != null) {
        if (!mounted) return;

        final savedFile = await Repositories.files.saveFileToAppStorage(file);
        final format = Repositories.files.getFileFormat(savedFile.path);
        final fileName = path.basenameWithoutExtension(savedFile.path);

        final tempMovie = Movie(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          name: fileName,
          director: 'Режиссер не указан',
          genre: 'Новая подборка',
          dateAdded: DateTime.now(),
          filePath: savedFile.path,
          fileFormat: format,
          description: 'Добавьте описание фильма и впечатления после просмотра.',
        );

        if (!mounted) return;

        context.push('/movie-form', extra: {
          'movie': tempMovie,
          'onSave': (Movie movie) {
            context.read<MoviesBloc>().add(AddMovie(movie));
            context.pop();
            context.pop();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Фильм добавлен в каталог')),
            );
          },
        });
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Не удалось импортировать файл: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Импорт фильма'),
      ),
      body: Center(
        child: _isLoading
            ? const CircularProgressIndicator()
            : Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.file_upload_outlined,
                      size: 100,
                      color: Colors.grey,
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Добавьте фильмы в формате EPUB или FB2',
                      style: Theme.of(context).textTheme.headlineSmall,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Мы сохраним файл и предложим заполнить детали фильма.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[600],
                          ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 48),
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton.icon(
                        onPressed: _pickFile,
                        icon: const Icon(Icons.folder_open),
                        label: const Text('Выбрать файл'),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
