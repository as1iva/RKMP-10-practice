import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:movie_catalog/core/di/service_locator.dart';
import 'package:movie_catalog/features/movies/bloc/movies_event.dart';
import 'package:movie_catalog/features/movies/bloc/movies_state.dart';
import 'package:movie_catalog/features/movies/data/repositories/movies_repository.dart';
import 'package:movie_catalog/features/movies/models/movie.dart';
import 'package:movie_catalog/services/logger_service.dart';

class MoviesBloc extends Bloc<MoviesEvent, MoviesState> {
  final MoviesRepository _repository;

  MoviesBloc({required MoviesRepository repository})
      : _repository = repository,
        super(const MoviesInitial()) {
    on<LoadMovies>(_onLoadMovies);
    on<AddMovie>(_onAddMovie);
    on<UpdateMovie>(_onUpdateMovie);
    on<DeleteMovie>(_onDeleteMovie);
    on<ToggleMovieWatched>(_onToggleMovieWatched);
    on<RateMovie>(_onRateMovie);
  }

  Future<void> _onLoadMovies(LoadMovies event, Emitter<MoviesState> emit) async {
    try {
      emit(const MoviesLoading());
      final movies = await _repository.getMovies();
      emit(MoviesLoaded(movies));
      LoggerService.info('Фильмы загружены: ${movies.length} шт.');
    } catch (e) {
      LoggerService.error('Ошибка загрузки фильмов: $e');
      emit(const MoviesError('Не удалось загрузить фильмы'));
    }
  }

  Future<void> _onAddMovie(AddMovie event, Emitter<MoviesState> emit) async {
    try {
      if (state is MoviesLoaded) {
        final currentState = state as MoviesLoaded;

        final imageUrl = await Services.image.getNextMovieImage();
        final movieWithImage = event.movie.copyWith(imageUrl: imageUrl);

        await _repository.addMovie(movieWithImage);

        final updatedMovies = List<Movie>.from(currentState.movies)..add(movieWithImage);

        emit(MoviesLoaded(updatedMovies));

        LoggerService.info('Фильм добавлен: ${movieWithImage.name}');
      }
    } catch (e) {
      LoggerService.error('Ошибка при добавлении фильма: $e');
      emit(const MoviesError('Не удалось добавить фильм'));
    }
  }

  Future<void> _onUpdateMovie(UpdateMovie event, Emitter<MoviesState> emit) async {
    try {
      if (state is MoviesLoaded) {
        final currentState = state as MoviesLoaded;

        await _repository.updateMovie(event.movie);

        final updatedMovies = currentState.movies.map((movie) {
          return movie.id == event.movie.id ? event.movie : movie;
        }).toList();

        emit(MoviesLoaded(updatedMovies));
        LoggerService.info('Фильм обновлен: ${event.movie.name}');
      }
    } catch (e) {
      LoggerService.error('Ошибка при обновлении фильма: $e');
      emit(const MoviesError('Не удалось обновить фильм'));
    }
  }

  Future<void> _onDeleteMovie(DeleteMovie event, Emitter<MoviesState> emit) async {
    try {
      if (state is MoviesLoaded) {
        final currentState = state as MoviesLoaded;
        final movieToDelete = currentState.movies.firstWhere((movie) => movie.id == event.movieId);

        if (movieToDelete.imageUrl != null) {
          await Services.image.releaseImage(movieToDelete.imageUrl!);
        }

        await _repository.deleteMovie(event.movieId);

        final updatedMovies = currentState.movies.where((movie) => movie.id != event.movieId).toList();

        emit(MoviesLoaded(updatedMovies));

        LoggerService.info('Фильм удален: ${movieToDelete.name}');
      }
    } catch (e) {
      LoggerService.error('Ошибка при удалении фильма: $e');
      emit(const MoviesError('Не удалось удалить фильм'));
    }
  }

  Future<void> _onToggleMovieWatched(
    ToggleMovieWatched event,
    Emitter<MoviesState> emit,
  ) async {
    try {
      if (state is MoviesLoaded) {
        final currentState = state as MoviesLoaded;
        final updatedMovies = currentState.movies.map((movie) {
          if (movie.id == event.movieId) {
            return movie.copyWith(
              isWatched: event.isWatched,
              lastWatched: event.isWatched ? DateTime.now() : null,
            );
          }
          return movie;
        }).toList();

        final updatedMovie = updatedMovies.firstWhere((r) => r.id == event.movieId);
        await _repository.updateMovie(updatedMovie);

        emit(MoviesLoaded(updatedMovies));
        LoggerService.info('Статус просмотра обновлен для ID: ${event.movieId}');
      }
    } catch (e) {
      LoggerService.error('Ошибка при обновлении статуса просмотра: $e');
      emit(const MoviesError('Не удалось обновить статус фильма'));
    }
  }

  Future<void> _onRateMovie(RateMovie event, Emitter<MoviesState> emit) async {
    try {
      if (state is MoviesLoaded) {
        final currentState = state as MoviesLoaded;
        final updatedMovies = currentState.movies.map((movie) {
          if (movie.id == event.movieId) {
            return movie.copyWith(rating: event.rating);
          }
          return movie;
        }).toList();

        final updatedMovie = updatedMovies.firstWhere((r) => r.id == event.movieId);
        await _repository.updateMovie(updatedMovie);

        emit(MoviesLoaded(updatedMovies));
        LoggerService.info('Оценка сохранена для ID: ${event.movieId}, рейтинг: ${event.rating}');
      }
    } catch (e) {
      LoggerService.error('Ошибка при сохранении оценки фильма: $e');
      emit(const MoviesError('Не удалось сохранить оценку'));
    }
  }
}
