import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:movie_catalog/features/movies/bloc/movies_bloc.dart';
import 'package:movie_catalog/features/movies/bloc/movies_state.dart';
import 'package:movie_catalog/features/movies/models/sort_option.dart';
import 'package:movie_catalog/features/movies/widgets/movie_tile.dart';
import 'package:movie_catalog/features/movies/widgets/sort_button.dart';
import 'package:movie_catalog/shared/widgets/empty_state.dart';

class ToWatchScreen extends StatefulWidget {
  const ToWatchScreen({super.key});

  @override
  State<ToWatchScreen> createState() => _ToWatchScreenState();
}

class _ToWatchScreenState extends State<ToWatchScreen> {
  SortOption _sortOption = SortOption.dateAddedNewest;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Хочу посмотреть'),
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

          final plannedMovies = state.plannedList.toList();

          plannedMovies.sort((a, b) {
            switch (_sortOption) {
              case SortOption.dateAddedNewest:
                return b.dateAdded.compareTo(a.dateAdded);
              case SortOption.dateAddedOldest:
                return a.dateAdded.compareTo(b.dateAdded);
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

          return plannedMovies.isEmpty
              ? const EmptyState(
                  icon: Icons.schedule_outlined,
                  title: 'Нет запланированных фильмов',
                  subtitle: 'Добавьте фильм, который хотите посмотреть позже.',
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: plannedMovies.length,
                  itemBuilder: (context, index) {
                    final movie = plannedMovies[index];
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
