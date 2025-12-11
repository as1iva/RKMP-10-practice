import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:movie_catalog/features/movies/bloc/movies_bloc.dart';
import 'package:movie_catalog/features/movies/bloc/movies_state.dart';
import 'package:movie_catalog/features/movies/models/sort_option.dart';
import 'package:movie_catalog/features/movies/widgets/movie_tile.dart';
import 'package:movie_catalog/features/movies/widgets/sort_button.dart';
import 'package:movie_catalog/shared/widgets/empty_state.dart';

class RatingsScreen extends StatefulWidget {
  const RatingsScreen({super.key});

  @override
  State<RatingsScreen> createState() => _RatingsScreenState();
}

class _RatingsScreenState extends State<RatingsScreen> {
  SortOption _sortOption = SortOption.ratingHighLow;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Рейтинги'),
        actions: [
          SortButton(
            currentSort: _sortOption,
            onSortChanged: (option) => setState(() => _sortOption = option),
          ),
        ],
      ),
      body: BlocBuilder<MoviesBloc, MoviesState>(
        builder: (context, state) {
          if (state is MoviesLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is! MoviesLoaded) {
            return const Center(child: Text('Не удалось загрузить рейтинги'));
          }

          final ratedMovies = state.movies.where((movie) => movie.rating != null).toList();

          ratedMovies.sort((a, b) {
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

          if (ratedMovies.isEmpty) {
            return const EmptyState(
              icon: Icons.star_outline,
              title: 'Пока нет оценок',
              subtitle: 'Оцените фильмы, чтобы увидеть их здесь.',
            );
          }

          return Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                margin: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.amber.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.amber.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatItem('Средний рейтинг', state.averageRating.toStringAsFixed(1), Icons.star),
                    Container(
                      width: 1,
                      height: 40,
                      color: Colors.amber.withValues(alpha: 0.3),
                    ),
                    _buildStatItem('Оценено фильмов', ratedMovies.length.toString(), Icons.check_circle),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  itemCount: ratedMovies.length,
                  itemBuilder: (context, index) {
                    final movie = ratedMovies[index];
                    return MovieTile(
                      key: ValueKey(movie.id),
                      movie: movie,
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.amber, size: 32),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.amber,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }
}
