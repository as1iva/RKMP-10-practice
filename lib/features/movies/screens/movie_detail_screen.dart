import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import 'package:movie_catalog/features/watching_tracker/bloc/watching_tracker_bloc.dart';
import 'package:movie_catalog/features/watching_tracker/bloc/watching_tracker_event.dart';
import 'package:movie_catalog/features/watching_tracker/models/watching_session.dart';
import 'package:movie_catalog/features/movies/bloc/movies_bloc.dart';
import 'package:movie_catalog/features/movies/bloc/movies_event.dart';
import 'package:movie_catalog/features/movies/bloc/movies_state.dart';
import 'package:movie_catalog/features/movies/models/movie.dart';

class MovieDetailScreen extends StatefulWidget {
  final Movie movie;

  const MovieDetailScreen({super.key, required this.movie});

  @override
  State<MovieDetailScreen> createState() => _MovieDetailScreenState();
}

class _MovieDetailScreenState extends State<MovieDetailScreen> {
  late Movie _currentMovie;

  @override
  void initState() {
    super.initState();
    _currentMovie = widget.movie;
  }

  void _showRatingDialog() {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Оцените фильм'),
        content: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(5, (index) {
            final rating = index + 1;
            return IconButton(
              icon: Icon(
                rating <= (_currentMovie.rating ?? 0) ? Icons.star : Icons.star_border,
                color: Colors.amber,
                size: 36,
              ),
              onPressed: () {
                context.read<MoviesBloc>().add(RateMovie(_currentMovie.id, rating));
                setState(() => _currentMovie = _currentMovie.copyWith(rating: rating));
                Navigator.pop(dialogContext);
              },
            );
          }),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Отмена'),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation() {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Удалить фильм?'),
        content: Text('Вы уверены, что хотите удалить "${_currentMovie.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () {
              context.read<MoviesBloc>().add(DeleteMovie(_currentMovie.id));
              Navigator.pop(dialogContext);
              context.pop();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Удалить'),
          ),
        ],
      ),
    );
  }

  void _navigateToEditScreen() {
    context.push('/movie-form', extra: {
      'movie': _currentMovie,
      'onSave': (updated) {
        context.read<MoviesBloc>().add(UpdateMovie(updated));
        setState(() => _currentMovie = updated);
        context.pop();
      },
    });
  }

  void _toggleWatched() {
    final newIsWatched = !_currentMovie.isWatched;
    context.read<MoviesBloc>().add(ToggleMovieWatched(_currentMovie.id, newIsWatched));

    if (newIsWatched) {
      final session = WatchSession(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        movieId: _currentMovie.id,
        date: DateTime.now(),
        minutesWatched: _currentMovie.duration,
      );
      context.read<WatchTrackerBloc>().add(AddWatchSession(session));

      final trackerState = context.read<WatchTrackerBloc>().state;
      final currentGoal = trackerState.watchingGoal;
      if (currentGoal != null) {
        context.read<WatchTrackerBloc>().add(
              UpdateWatchGoal(
                currentGoal.copyWith(currentMovies: currentGoal.currentMovies + 1),
              ),
            );
      }
    }

    setState(() {
      _currentMovie = _currentMovie.copyWith(
        isWatched: newIsWatched,
        lastWatched: newIsWatched ? DateTime.now() : null,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd.MM.yyyy');

    return BlocListener<MoviesBloc, MoviesState>(
      listener: (context, state) {
        if (state is MoviesLoaded) {
          try {
            final updated = state.movies.firstWhere((b) => b.id == _currentMovie.id);
            if (updated != _currentMovie) {
              setState(() => _currentMovie = updated);
            }
          } catch (_) {}
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Фильм'),
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          actions: [
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: _navigateToEditScreen,
              tooltip: 'Редактировать',
            ),
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: _showDeleteConfirmation,
              tooltip: 'Удалить',
            ),
          ],
        ),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_currentMovie.imageUrl != null)
                Container(
                  width: double.infinity,
                  height: 260,
                  color: Colors.grey[200],
                  child: CachedNetworkImage(
                    imageUrl: _currentMovie.imageUrl!,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      color: Colors.grey[300],
                      child: const Center(child: CircularProgressIndicator()),
                    ),
                    errorWidget: (context, url, error) => Container(
                      color: Colors.grey[300],
                      child: const Icon(Icons.local_movies, size: 48),
                    ),
                  ),
                ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _currentMovie.name,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Режиссер: ${_currentMovie.director}',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Жанр: ${_currentMovie.genre}',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Icon(
                          _currentMovie.isWatched ? Icons.check_circle : Icons.schedule,
                          color: _currentMovie.isWatched ? Colors.green : Colors.orange,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _currentMovie.isWatched ? 'Просмотрено' : 'Запланировано',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: _currentMovie.isWatched ? Colors.green : Colors.orange,
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          onPressed: _toggleWatched,
                          icon: Icon(
                            _currentMovie.isWatched ? Icons.undo : Icons.check_circle,
                            color: _currentMovie.isWatched ? Colors.grey : Colors.green,
                          ),
                          tooltip: _currentMovie.isWatched ? 'Сбросить' : 'Отметить как просмотрено',
                        ),
                        IconButton(
                          onPressed: _showRatingDialog,
                          icon: Icon(
                            _currentMovie.rating == null ? Icons.star_border : Icons.star,
                            color: Colors.amber,
                          ),
                          tooltip: 'Оценить',
                        ),
                      ],
                    ),
                    if (_currentMovie.duration != null) ...[
                      const SizedBox(height: 8),
                      Text('Длительность: ${_currentMovie.duration} мин'),
                    ],
                    const SizedBox(height: 12),
                    if (_currentMovie.description != null && _currentMovie.description!.isNotEmpty)
                      Text(
                        _currentMovie.description!,
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    const SizedBox(height: 16),
                    if (_currentMovie.lastWatched != null)
                      Text(
                        'Смотрели: ${dateFormat.format(_currentMovie.lastWatched!)}',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    const SizedBox(height: 24),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        _actionChip(
                          icon: Icons.playlist_add_check,
                          label: 'Отметить просмотр',
                          onTap: _toggleWatched,
                        ),
                        _actionChip(
                          icon: Icons.sticky_note_2_outlined,
                          label: 'Заметки',
                          onTap: () => context.push('/movie-notes/${_currentMovie.id}'),
                        ),
                        _actionChip(
                          icon: Icons.insert_drive_file_outlined,
                          label: 'Открыть файл',
                          onTap: _currentMovie.filePath != null
                              ? () => context.push('/movie-viewer', extra: _currentMovie)
                              : null,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _actionChip({required IconData icon, required String label, VoidCallback? onTap}) {
    return ActionChip(
      avatar: Icon(icon, size: 18),
      label: Text(label),
      onPressed: onTap,
      disabledColor: Colors.grey.shade300,
    );
  }
}
