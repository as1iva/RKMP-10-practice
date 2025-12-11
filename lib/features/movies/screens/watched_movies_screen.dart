import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:movie_catalog/features/movies/bloc/movies_bloc.dart';
import 'package:movie_catalog/features/movies/bloc/movies_state.dart';
import 'package:movie_catalog/features/movies/models/sort_option.dart';
import 'package:movie_catalog/features/movies/widgets/movie_tile.dart';
import 'package:movie_catalog/features/movies/widgets/sort_button.dart';
import 'package:movie_catalog/shared/widgets/empty_state.dart';

class WatchedMoviesScreen extends StatefulWidget {
  const WatchedMoviesScreen({super.key});

  @override
  State<WatchedMoviesScreen> createState() => _WatchedMoviesScreenState();
}

class _WatchedMoviesScreenState extends State<WatchedMoviesScreen> {
  SortOption _sortOption = SortOption.dateAddedNewest;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Просмотренные фильмы'),
        actions: [
          SortButton(
            currentSort: _sortOption,
            onSortChanged: (option) => setState(() => _sortOption = option),
          ),
        ],
      ),
      body: BlocBuilder<MoviesBloc, MoviesState>(
        builder: (context, state) {
          if (state is! MoviesLoaded) {
            return const Center(child: CircularProgressIndicator());
          }

          final watchedMovies = state.watchedList.toList();

          watchedMovies.sort((a, b) {
            switch (_sortOption) {
              case SortOption.dateAddedNewest:
                return (b.lastWatched ?? b.dateAdded).compareTo(a.lastWatched ?? a.dateAdded);
              case SortOption.dateAddedOldest:
                return (a.lastWatched ?? a.dateAdded).compareTo(b.lastWatched ?? b.dateAdded);
              case SortOption.titleAZ:
                return a.name.compareTo(b.name);
              case SortOption.titleZA:
                return b.name.compareTo(a.name);
              case SortOption.ratingHighLow:
                return (b.rating ?? 0).compareTo(a.rating ?? 0);
              case SortOption.ratingLowHigh:
                return (a.rating ?? 0).compareTo(b.rating ?? 0);
            }
          });

          return watchedMovies.isEmpty
              ? const EmptyState(
                  icon: Icons.check_circle_outline,
                  title: 'Пока нет просмотренных фильмов',
                  subtitle: 'Отметьте фильм как просмотренный, и он появится здесь.',
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: watchedMovies.length,
                  itemBuilder: (context, index) {
                    final movie = watchedMovies[index];
                    return MovieTile(
                      key: ValueKey(movie.id),
                      movie: movie,
                    );
                  },
                );
        },
      ),
    );
  }
}
