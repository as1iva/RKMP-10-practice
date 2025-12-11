import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'package:movie_catalog/features/movies/models/movie.dart';
import 'package:movie_catalog/services/logger_service.dart';

class MoviesLocalDataSource {
  static const String _moviesKey = 'movies_data';

  Future<List<Movie>> getMovies() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? moviesJson = prefs.getString(_moviesKey);

      if (moviesJson == null || moviesJson.isEmpty) {
        LoggerService.info('MoviesLocalDataSource: нет сохраненных фильмов, возвращаю пустой список.');
        return [];
      }

      final List<dynamic> decoded = json.decode(moviesJson);
      final movies = decoded.map((json) => _movieFromJson(json)).toList();

      LoggerService.info('MoviesLocalDataSource: загружено ${movies.length} фильмов');
      return movies;
    } catch (e) {
      LoggerService.error('MoviesLocalDataSource: ошибка при загрузке фильмов: $e');
      return [];
    }
  }

  Future<void> saveMovies(List<Movie> movies) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final moviesJson = json.encode(movies.map((movie) => _movieToJson(movie)).toList());
      await prefs.setString(_moviesKey, moviesJson);

      LoggerService.info('MoviesLocalDataSource: сохранено ${movies.length} фильмов');
    } catch (e) {
      LoggerService.error('MoviesLocalDataSource: ошибка при сохранении фильмов: $e');
      rethrow;
    }
  }

  Future<void> clearMovies() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_moviesKey);
      LoggerService.info('MoviesLocalDataSource: все фильмы очищены');
    } catch (e) {
      LoggerService.error('MoviesLocalDataSource: ошибка при очистке фильмов: $e');
      rethrow;
    }
  }

  Map<String, dynamic> _movieToJson(Movie movie) {
    return {
      'id': movie.id,
      'name': movie.name,
      'director': movie.director,
      'genre': movie.genre,
      'description': movie.description,
      'duration': movie.duration,
      'isWatched': movie.isWatched,
      'rating': movie.rating,
      'dateAdded': movie.dateAdded.toIso8601String(),
      'lastWatched': movie.lastWatched?.toIso8601String(),
      'imageUrl': movie.imageUrl,
      'filePath': movie.filePath,
      'fileFormat': movie.fileFormat,
      'lastViewedStep': movie.lastViewedStep,
    };
  }

  Movie _movieFromJson(Map<String, dynamic> json) {
    return Movie(
      id: json['id'] as String,
      name: json['name'] as String,
      director: json['director'] as String,
      genre: json['genre'] as String,
      description: json['description'] as String?,
      duration: json['duration'] as int?,
      isWatched: json['isWatched'] as bool? ?? false,
      rating: json['rating'] as int?,
      dateAdded: DateTime.parse(json['dateAdded'] as String),
      lastWatched: json['lastWatched'] != null
          ? DateTime.parse(json['lastWatched'] as String)
          : null,
      imageUrl: json['imageUrl'] as String?,
      filePath: json['filePath'] as String?,
      fileFormat: json['fileFormat'] as String?,
      lastViewedStep: json['lastViewedStep'] as String?,
    );
  }
}
