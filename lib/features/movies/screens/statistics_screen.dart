import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:movie_catalog/features/movies/bloc/movies_bloc.dart';
import 'package:movie_catalog/features/movies/bloc/movies_state.dart';

class StatisticsScreen extends StatelessWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Статистика'),
      ),
      body: BlocBuilder<MoviesBloc, MoviesState>(
        builder: (context, state) {
          if (state is MoviesLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is! MoviesLoaded) {
            return const Center(child: Text('Не удалось загрузить статистику'));
          }

          final total = state.totalMovies;
          final watched = state.watchedMovies;
          final planned = state.plannedMovies;
          final averageRating = state.averageRating;
          final progress = total > 0 ? (watched / total * 100) : 0;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildStatCard(
                title: 'Общее',
                icon: Icons.local_movies,
                color: Colors.blue,
                children: [
                  _buildStatRow('Всего фильмов', total.toString()),
                  _buildStatRow('Просмотрено', watched.toString()),
                  _buildStatRow('Запланировано', planned.toString()),
                  _buildStatRow('Прогресс', '${progress.toStringAsFixed(0)}%'),
                ],
              ),
              const SizedBox(height: 16),
              _buildStatCard(
                title: 'Оценки',
                icon: Icons.star,
                color: Colors.amber,
                children: [
                  _buildStatRow('Средний рейтинг', averageRating.toStringAsFixed(1)),
                  _buildStatRow(
                    'Оценено фильмов',
                    state.movies.where((r) => r.rating != null).length.toString(),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildStatCard(
                title: 'По жанрам',
                icon: Icons.theaters,
                color: Colors.green,
                children: _buildGenreStats(state),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required IconData icon,
    required Color color,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 16),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildGenreStats(MoviesLoaded state) {
    final genreMap = <String, int>{};
    for (var movie in state.movies) {
      genreMap[movie.genre] = (genreMap[movie.genre] ?? 0) + 1;
    }

    final sorted = genreMap.entries.toList()..sort((a, b) => b.value.compareTo(a.value));

    if (sorted.isEmpty) {
      return [
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 8),
          child: Text(
            'Нет данных',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ),
      ];
    }

    return sorted.map((entry) => _buildStatRow(entry.key, entry.value.toString())).toList();
  }
}
