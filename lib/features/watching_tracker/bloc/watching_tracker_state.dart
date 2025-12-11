import 'package:equatable/equatable.dart';

import 'package:movie_catalog/features/watching_tracker/models/watching_goal.dart';
import 'package:movie_catalog/features/watching_tracker/models/watching_session.dart';
import 'package:movie_catalog/features/watching_tracker/models/movie_note.dart';

enum WatchTrackerStatus { initial, loading, success, failure }

class WatchTrackerState extends Equatable {
  final WatchTrackerStatus status;
  final WatchGoal? watchingGoal;
  final List<WatchSession> watchingHistory;
  final List<MovieNote> movieNotes;
  final String? errorMessage;

  const WatchTrackerState({
    this.status = WatchTrackerStatus.initial,
    this.watchingGoal,
    this.watchingHistory = const [],
    this.movieNotes = const [],
    this.errorMessage,
  });

  WatchTrackerState copyWith({
    WatchTrackerStatus? status,
    WatchGoal? watchingGoal,
    List<WatchSession>? watchingHistory,
    List<MovieNote>? movieNotes,
    String? errorMessage,
  }) {
    return WatchTrackerState(
      status: status ?? this.status,
      watchingGoal: watchingGoal ?? this.watchingGoal,
      watchingHistory: watchingHistory ?? this.watchingHistory,
      movieNotes: movieNotes ?? this.movieNotes,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, watchingGoal, watchingHistory, movieNotes, errorMessage];
}
