import 'package:movie_catalog/features/watching_tracker/models/watching_goal.dart';
import 'package:movie_catalog/features/watching_tracker/models/watching_session.dart';
import 'package:movie_catalog/features/watching_tracker/models/movie_note.dart';

abstract class WatchTrackerRepository {
  Future<WatchGoal> getWatchGoal(int year);
  Future<void> saveWatchGoal(WatchGoal goal);

  Future<List<WatchSession>> getWatchingHistory();
  Future<void> addWatchSession(WatchSession session);

  Future<List<MovieNote>> getMovieNotes(String movieId);
  Future<void> addMovieNote(MovieNote note);
  Future<void> deleteMovieNote(String noteId);
}
