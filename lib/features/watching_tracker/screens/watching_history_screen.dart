import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import 'package:movie_catalog/features/watching_tracker/bloc/watching_tracker_bloc.dart';
import 'package:movie_catalog/features/watching_tracker/bloc/watching_tracker_state.dart';
import 'package:movie_catalog/features/movies/bloc/movies_bloc.dart';
import 'package:movie_catalog/features/movies/bloc/movies_state.dart';
import 'package:movie_catalog/features/movies/models/movie.dart';

class WatchingHistoryScreen extends StatelessWidget {
  const WatchingHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('История просмотров'),
      ),
      body: BlocBuilder<MoviesBloc, MoviesState>(
        builder: (context, moviesState) {
          if (moviesState is! MoviesLoaded) {
            return const Center(child: CircularProgressIndicator());
          }

          return BlocBuilder<WatchTrackerBloc, WatchTrackerState>(
            builder: (context, trackerState) {
              if (trackerState.status == WatchTrackerStatus.loading) {
                return const Center(child: CircularProgressIndicator());
              }

              final List<_HistoryItem> historyItems = [];

              for (final session in trackerState.watchingHistory) {
                try {
                  final movie = moviesState.movies.firstWhere((b) => b.id == session.movieId);
                  historyItems.add(_HistoryItem(
                    movie: movie,
                    date: session.date,
                    minutes: session.minutesWatched,
                    isFinished: false,
                  ));
                } catch (_) {}
              }

              for (final movie in moviesState.movies) {
                if (movie.isWatched && movie.lastWatched != null) {
                  historyItems.add(_HistoryItem(
                    movie: movie,
                    date: movie.lastWatched!,
                    minutes: movie.duration,
                    isFinished: true,
                  ));
                }
              }

              if (historyItems.isEmpty) {
                return const Center(child: Text('Пока нет записей о просмотре'));
              }

              historyItems.sort((a, b) => b.date.compareTo(a.date));

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: historyItems.length,
                itemBuilder: (context, index) {
                  final item = historyItems[index];
                  final movie = item.movie;

                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: InkWell(
                      onTap: () => context.push('/movie/${movie.id}', extra: movie),
                      borderRadius: BorderRadius.circular(12),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: movie.imageUrl != null
                                  ? CachedNetworkImage(
                                      imageUrl: movie.imageUrl!,
                                      width: 50,
                                      height: 75,
                                      fit: BoxFit.cover,
                                      placeholder: (context, url) => Container(
                                        width: 50,
                                        height: 75,
                                        color: Colors.grey[300],
                                      ),
                                      errorWidget: (context, url, error) => Container(
                                        width: 50,
                                        height: 75,
                                        color: Colors.grey[300],
                                        child: const Icon(Icons.local_movies),
                                      ),
                                    )
                                  : Container(
                                      width: 50,
                                      height: 75,
                                      color: Colors.grey[300],
                                      child: const Icon(Icons.local_movies),
                                    ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    movie.name,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    movie.director,
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Icon(Icons.calendar_today,
                                          size: 14, color: Theme.of(context).colorScheme.primary),
                                      const SizedBox(width: 4),
                                      Text(
                                        DateFormat.yMMMd().format(item.date),
                                        style: TextStyle(
                                          color: Theme.of(context).colorScheme.primary,
                                          fontWeight: FontWeight.w500,
                                          fontSize: 12,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      if (item.isFinished) ...[
                                        const Icon(Icons.check_circle, size: 14, color: Colors.green),
                                        const SizedBox(width: 4),
                                        const Text(
                                          'Просмотрено',
                                          style: TextStyle(
                                            color: Colors.green,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ] else if (item.minutes != null) ...[
                                        const Icon(Icons.timer_outlined, size: 14, color: Colors.grey),
                                        const SizedBox(width: 4),
                                        Text(
                                          '${item.minutes} мин.',
                                          style: const TextStyle(
                                            color: Colors.grey,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
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
                },
              );
            },
          );
        },
      ),
    );
  }
}

class _HistoryItem {
  final Movie movie;
  final DateTime date;
  final int? minutes;
  final bool isFinished;

  _HistoryItem({
    required this.movie,
    required this.date,
    this.minutes,
    required this.isFinished,
  });
}
