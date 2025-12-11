import 'package:equatable/equatable.dart';

import 'package:movie_catalog/features/movies/models/movie.dart';

abstract class MoviesState extends Equatable {
  const MoviesState();

  @override
  List<Object?> get props => [];
}

class MoviesInitial extends MoviesState {
  const MoviesInitial();
}

class MoviesLoading extends MoviesState {
  const MoviesLoading();
}

class MoviesLoaded extends MoviesState {
  final List<Movie> movies;

  const MoviesLoaded(this.movies);

  @override
  List<Object?> get props => [movies];

  int get totalMovies => movies.length;

  int get watchedMovies => movies.where((movie) => movie.isWatched).length;

  int get plannedMovies => totalMovies - watchedMovies;

  double get averageRating {
    final rated = movies.where((movie) => movie.rating != null);
    if (rated.isEmpty) return 0.0;

    final sum = rated.map((movie) => movie.rating!).reduce((a, b) => a + b);
    return sum / rated.length;
  }

  List<Movie> get recentMovies {
    if (movies.isEmpty) return [];

    final sorted = movies.toList()
      ..sort((a, b) => b.dateAdded.compareTo(a.dateAdded));
    return sorted.take(3).toList();
  }

  List<Movie> get watchedList => movies.where((movie) => movie.isWatched).toList();

  List<Movie> get plannedList => movies.where((movie) => !movie.isWatched).toList();
}

class MoviesError extends MoviesState {
  final String message;

  const MoviesError(this.message);

  @override
  List<Object?> get props => [message];
}
