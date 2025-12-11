import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'package:movie_catalog/features/watching_tracker/models/watching_goal.dart';
import 'package:movie_catalog/features/watching_tracker/models/watching_session.dart';
import 'package:movie_catalog/features/watching_tracker/models/movie_note.dart';
import 'package:movie_catalog/services/logger_service.dart';

class WatchTrackerLocalDataSource {
  static const String _goalsKey = 'watching_goals';
  static const String _historyKey = 'watching_history';
  static const String _notesKey = 'movie_notes';

  Future<WatchGoal?> getWatchGoal(int year) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? goalsJson = prefs.getString(_goalsKey);

      if (goalsJson == null) return null;

      final List<dynamic> decoded = json.decode(goalsJson);
      final goals = decoded.map((json) => _goalFromJson(json)).toList();
      return goals.firstWhere((g) => g.year == year, orElse: () => WatchGoal(targetMovies: 0, currentMovies: 0, year: year));
    } catch (e) {
      LoggerService.error('WatchTrackerLocalDataSource: ошибка загрузки цели: $e');
      return null;
    }
  }

  Future<void> saveWatchGoal(WatchGoal goal) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? goalsJson = prefs.getString(_goalsKey);
      List<WatchGoal> goals = [];

      if (goalsJson != null) {
        final List<dynamic> decoded = json.decode(goalsJson);
        goals = decoded.map((json) => _goalFromJson(json)).toList();
      }

      goals.removeWhere((g) => g.year == goal.year);
      goals.add(goal);

      final encoded = json.encode(goals.map((g) => _goalToJson(g)).toList());
      await prefs.setString(_goalsKey, encoded);
    } catch (e) {
      LoggerService.error('WatchTrackerLocalDataSource: ошибка сохранения цели: $e');
      rethrow;
    }
  }

  Future<List<WatchSession>> getWatchingHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? historyJson = prefs.getString(_historyKey);

      if (historyJson == null) return [];

      final List<dynamic> decoded = json.decode(historyJson);
      return decoded.map((json) => _sessionFromJson(json)).toList();
    } catch (e) {
      LoggerService.error('WatchTrackerLocalDataSource: ошибка загрузки истории: $e');
      return [];
    }
  }

  Future<void> addWatchSession(WatchSession session) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final sessions = await getWatchingHistory();
      sessions.add(session);

      final encoded = json.encode(sessions.map((s) => _sessionToJson(s)).toList());
      await prefs.setString(_historyKey, encoded);
    } catch (e) {
      LoggerService.error('WatchTrackerLocalDataSource: ошибка сохранения просмотра: $e');
      rethrow;
    }
  }

  Future<List<MovieNote>> getMovieNotes(String movieId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? notesJson = prefs.getString(_notesKey);

      if (notesJson == null) return [];

      final List<dynamic> decoded = json.decode(notesJson);
      final allNotes = decoded.map((json) => _noteFromJson(json)).toList();

      return allNotes.where((note) => note.movieId == movieId).toList();
    } catch (e) {
      LoggerService.error('WatchTrackerLocalDataSource: ошибка загрузки заметок: $e');
      return [];
    }
  }

  Future<void> addMovieNote(MovieNote note) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? notesJson = prefs.getString(_notesKey);
      List<MovieNote> notes = [];

      if (notesJson != null) {
        final List<dynamic> decoded = json.decode(notesJson);
        notes = decoded.map((json) => _noteFromJson(json)).toList();
      }

      notes.add(note);

      final encoded = json.encode(notes.map((n) => _noteToJson(n)).toList());
      await prefs.setString(_notesKey, encoded);
    } catch (e) {
      LoggerService.error('WatchTrackerLocalDataSource: ошибка сохранения заметки: $e');
      rethrow;
    }
  }

  Future<void> deleteMovieNote(String noteId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? notesJson = prefs.getString(_notesKey);
      if (notesJson == null) return;

      final List<dynamic> decoded = json.decode(notesJson);
      List<MovieNote> notes = decoded.map((json) => _noteFromJson(json)).toList();

      notes.removeWhere((n) => n.id == noteId);

      final encoded = json.encode(notes.map((n) => _noteToJson(n)).toList());
      await prefs.setString(_notesKey, encoded);
    } catch (e) {
      LoggerService.error('WatchTrackerLocalDataSource: ошибка удаления заметки: $e');
      rethrow;
    }
  }

  Map<String, dynamic> _goalToJson(WatchGoal goal) => {
        'targetMovies': goal.targetMovies,
        'currentMovies': goal.currentMovies,
        'year': goal.year,
      };

  WatchGoal _goalFromJson(Map<String, dynamic> json) => WatchGoal(
        targetMovies: json['targetMovies'],
        currentMovies: json['currentMovies'],
        year: json['year'],
      );

  Map<String, dynamic> _sessionToJson(WatchSession session) => {
        'id': session.id,
        'movieId': session.movieId,
        'date': session.date.toIso8601String(),
        'minutesWatched': session.minutesWatched,
      };

  WatchSession _sessionFromJson(Map<String, dynamic> json) => WatchSession(
        id: json['id'],
        movieId: json['movieId'],
        date: DateTime.parse(json['date']),
        minutesWatched: json['minutesWatched'],
      );

  Map<String, dynamic> _noteToJson(MovieNote note) => {
        'id': note.id,
        'movieId': note.movieId,
        'content': note.content,
        'stepNumber': note.stepNumber,
        'date': note.date.toIso8601String(),
      };

  MovieNote _noteFromJson(Map<String, dynamic> json) => MovieNote(
        id: json['id'],
        movieId: json['movieId'],
        content: json['content'],
        stepNumber: json['stepNumber'],
        date: DateTime.parse(json['date']),
      );
}
