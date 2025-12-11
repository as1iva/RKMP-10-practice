import 'package:movie_catalog/features/movies/data/datasources/movies_local_datasource.dart';
import 'package:movie_catalog/features/movies/data/repositories/movies_repository.dart';
import 'package:movie_catalog/features/movies/models/movie.dart';
import 'package:movie_catalog/services/logger_service.dart';

class MoviesRepositoryImpl implements MoviesRepository {
  final MoviesLocalDataSource _localDataSource;

  MoviesRepositoryImpl({required MoviesLocalDataSource localDataSource})
      : _localDataSource = localDataSource;

  @override
  Future<List<Movie>> getMovies() async {
    try {
      return await _localDataSource.getMovies();
    } catch (e) {
      LoggerService.error('MoviesRepository: ошибка при загрузке фильмов: $e');
      rethrow;
    }
  }

  @override
  Future<void> addMovie(Movie movie) async {
    try {
      final movies = await getMovies();
      movies.add(movie);
      await _localDataSource.saveMovies(movies);
      LoggerService.info('MoviesRepository: фильм добавлен: ${movie.name}');
    } catch (e) {
      LoggerService.error('MoviesRepository: ошибка при добавлении фильма: $e');
      rethrow;
    }
  }

  @override
  Future<void> updateMovie(Movie movie) async {
    try {
      final movies = await getMovies();
      final index = movies.indexWhere((r) => r.id == movie.id);

      if (index != -1) {
        movies[index] = movie;
        await _localDataSource.saveMovies(movies);
        LoggerService.info('MoviesRepository: фильм обновлен: ${movie.name}');
      } else {
        throw Exception('Фильм с ID ${movie.id} не найден');
      }
    } catch (e) {
      LoggerService.error('MoviesRepository: ошибка при обновлении фильма: $e');
      rethrow;
    }
  }

  @override
  Future<void> deleteMovie(String id) async {
    try {
      final movies = await getMovies();
      movies.removeWhere((movie) => movie.id == id);
      await _localDataSource.saveMovies(movies);
      LoggerService.info('MoviesRepository: фильм удален: $id');
    } catch (e) {
      LoggerService.error('MoviesRepository: ошибка при удалении фильма: $e');
      rethrow;
    }
  }

  @override
  Future<void> saveMovies(List<Movie> movies) async {
    try {
      await _localDataSource.saveMovies(movies);
    } catch (e) {
      LoggerService.error('MoviesRepository: ошибка при сохранении фильмов: $e');
      rethrow;
    }
  }
}
