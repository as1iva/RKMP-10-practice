import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:movie_catalog/features/movies/bloc/movies_bloc.dart';
import 'package:movie_catalog/features/movies/bloc/movies_state.dart';
import 'package:movie_catalog/features/movies/widgets/movie_tile.dart';

class RecommendationsScreen extends StatelessWidget {
  const RecommendationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Рекомендации'),
      ),
      body: BlocBuilder<MoviesBloc, MoviesState>(
        builder: (context, state) {
          if (state is MoviesLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is MoviesLoaded) {
            final recommended = state.movies.where((b) => !b.isWatched).take(5).toList();

            if (recommended.isEmpty) {
              return const Center(child: Text('Добавьте фильмы, чтобы увидеть рекомендации.'));
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: recommended.length,
              itemBuilder: (context, index) {
                final movie = recommended[index];
                return MovieTile(movie: movie);
              },
            );
          }

          return const Center(child: Text('Не удалось загрузить рекомендации'));
        },
      ),
    );
  }
}
