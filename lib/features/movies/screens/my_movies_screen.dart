import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:movie_catalog/features/movies/bloc/movies_bloc.dart';
import 'package:movie_catalog/features/movies/bloc/movies_state.dart';
import 'package:movie_catalog/features/movies/models/movie.dart';
import 'package:movie_catalog/features/movies/models/sort_option.dart';
import 'package:movie_catalog/features/movies/widgets/movie_tile.dart';
import 'package:movie_catalog/shared/widgets/empty_state.dart';

class MyMoviesScreen extends StatefulWidget {
  const MyMoviesScreen({super.key});

  @override
  State<MyMoviesScreen> createState() => _MyMoviesScreenState();
}

class _MyMoviesScreenState extends State<MyMoviesScreen> {
  String _searchQuery = '';
  String _selectedGenre = 'Все';
  SortOption _sortOption = SortOption.dateAddedNewest;

  List<Movie> _getFilteredMovies(List<Movie> movies) {
    var filtered = movies.where((movie) {
      final matchesSearch = movie.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          movie.director.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesGenre = _selectedGenre == 'Все' || movie.genre == _selectedGenre;
      return matchesSearch && matchesGenre;
    }).toList();

    switch (_sortOption) {
      case SortOption.titleAZ:
        filtered.sort((a, b) => a.name.compareTo(b.name));
        break;
      case SortOption.titleZA:
        filtered.sort((a, b) => b.name.compareTo(a.name));
        break;
      case SortOption.ratingHighLow:
        filtered.sort((a, b) => (b.rating ?? 0).compareTo(a.rating ?? 0));
        break;
      case SortOption.ratingLowHigh:
        filtered.sort((a, b) => (a.rating ?? 0).compareTo(b.rating ?? 0));
        break;
      case SortOption.dateAddedOldest:
        filtered.sort((a, b) => a.dateAdded.compareTo(b.dateAdded));
        break;
      case SortOption.dateAddedNewest:
        filtered.sort((a, b) => b.dateAdded.compareTo(a.dateAdded));
    }

    return filtered;
  }

  List<String> _getGenres(List<Movie> movies) {
    final genres = movies.map((movie) => movie.genre).toSet().toList();
    genres.sort();
    return ['Все', ...genres];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Моя коллекция'),
      ),
      body: BlocBuilder<MoviesBloc, MoviesState>(
        builder: (context, state) {
          if (state is! MoviesLoaded) {
            return const Center(child: CircularProgressIndicator());
          }

          final filteredMovies = _getFilteredMovies(state.movies);
          final genres = _getGenres(state.movies);

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    TextField(
                      decoration: const InputDecoration(
                        hintText: 'Поиск по названию или режиссеру',
                        prefixIcon: Icon(Icons.search),
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (value) => setState(() => _searchQuery = value),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: _selectedGenre,
                            decoration: const InputDecoration(
                              labelText: 'Жанр',
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            ),
                            items: genres
                                .map((genre) => DropdownMenuItem(
                                      value: genre,
                                      child: Text(genre),
                                    ))
                                .toList(),
                            onChanged: (value) => setState(() => _selectedGenre = value!),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: DropdownButtonFormField<SortOption>(
                            value: _sortOption,
                            decoration: const InputDecoration(
                              labelText: 'Сортировка',
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            ),
                            items: SortOption.values
                                .map((option) => DropdownMenuItem(
                                      value: option,
                                      child: Text(option.label),
                                    ))
                                .toList(),
                            onChanged: (value) => setState(() => _sortOption = value!),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Expanded(
                child: filteredMovies.isEmpty
                    ? const EmptyState(
                        icon: Icons.search_off,
                        title: 'Ничего не найдено',
                        subtitle: 'Попробуйте изменить фильтр или добавить новый фильм.',
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        itemCount: filteredMovies.length,
                        itemBuilder: (context, index) {
                          final movie = filteredMovies[index];
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
}
