import 'package:movie_catalog/features/watching_tracker/data/datasources/watching_tracker_local_datasource.dart';
import 'package:movie_catalog/features/watching_tracker/data/repositories/watching_tracker_repository.dart';
import 'package:movie_catalog/features/watching_tracker/models/watching_goal.dart';
import 'package:movie_catalog/features/watching_tracker/models/watching_session.dart';
import 'package:movie_catalog/features/watching_tracker/models/movie_note.dart';

class WatchTrackerRepositoryImpl implements WatchTrackerRepository {
  final WatchTrackerLocalDataSource localDataSource;

  WatchTrackerRepositoryImpl({required this.localDataSource});

  @override
  Future<WatchGoal> getWatchGoal(int year) {
    return localDataSource.getWatchGoal(year).then(
          (goal) => goal ?? WatchGoal(targetMovies: 0, currentMovies: 0, year: year),
        );
  }

  @override
  Future<void> saveWatchGoal(WatchGoal goal) {
    return localDataSource.saveWatchGoal(goal);
  }

  @override
  Future<List<WatchSession>> getWatchingHistory() {
    return localDataSource.getWatchingHistory();
  }

  @override
  Future<void> addWatchSession(WatchSession session) {
    return localDataSource.addWatchSession(session);
  }

  @override
  Future<List<MovieNote>> getMovieNotes(String movieId) {
    return localDataSource.getMovieNotes(movieId);
  }

  @override
  Future<void> addMovieNote(MovieNote note) {
    return localDataSource.addMovieNote(note);
  }

  @override
  Future<void> deleteMovieNote(String noteId) {
    return localDataSource.deleteMovieNote(noteId);
  }
}
