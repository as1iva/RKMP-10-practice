import 'package:equatable/equatable.dart';

import 'package:movie_catalog/features/watching_tracker/models/watching_goal.dart';
import 'package:movie_catalog/features/watching_tracker/models/watching_session.dart';
import 'package:movie_catalog/features/watching_tracker/models/movie_note.dart';

abstract class WatchTrackerEvent extends Equatable {
  const WatchTrackerEvent();

  @override
  List<Object?> get props => [];
}

class LoadWatchGoal extends WatchTrackerEvent {
  final int year;
  const LoadWatchGoal(this.year);

  @override
  List<Object?> get props => [year];
}

class UpdateWatchGoal extends WatchTrackerEvent {
  final WatchGoal goal;
  const UpdateWatchGoal(this.goal);

  @override
  List<Object?> get props => [goal];
}

class LoadWatchingHistory extends WatchTrackerEvent {}

class AddWatchSession extends WatchTrackerEvent {
  final WatchSession session;
  const AddWatchSession(this.session);

  @override
  List<Object?> get props => [session];
}

class LoadMovieNotes extends WatchTrackerEvent {
  final String movieId;
  const LoadMovieNotes(this.movieId);

  @override
  List<Object?> get props => [movieId];
}

class AddMovieNote extends WatchTrackerEvent {
  final MovieNote note;
  const AddMovieNote(this.note);

  @override
  List<Object?> get props => [note];
}

class DeleteMovieNote extends WatchTrackerEvent {
  final String noteId;
  final String movieId;
  const DeleteMovieNote(this.noteId, this.movieId);

  @override
  List<Object?> get props => [noteId, movieId];
}
