import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:movie_catalog/features/watching_tracker/bloc/watching_tracker_event.dart';
import 'package:movie_catalog/features/watching_tracker/bloc/watching_tracker_state.dart';
import 'package:movie_catalog/features/watching_tracker/data/repositories/watching_tracker_repository.dart';

class WatchTrackerBloc extends Bloc<WatchTrackerEvent, WatchTrackerState> {
  final WatchTrackerRepository repository;

  WatchTrackerBloc({required this.repository}) : super(const WatchTrackerState()) {
    on<LoadWatchGoal>(_onLoadWatchGoal);
    on<UpdateWatchGoal>(_onUpdateWatchGoal);
    on<LoadWatchingHistory>(_onLoadWatchingHistory);
    on<AddWatchSession>(_onAddWatchSession);
    on<LoadMovieNotes>(_onLoadMovieNotes);
    on<AddMovieNote>(_onAddMovieNote);
    on<DeleteMovieNote>(_onDeleteMovieNote);
  }

  Future<void> _onLoadWatchGoal(
    LoadWatchGoal event,
    Emitter<WatchTrackerState> emit,
  ) async {
    emit(state.copyWith(status: WatchTrackerStatus.loading));
    try {
      final goal = await repository.getWatchGoal(event.year);
      emit(
        state.copyWith(
          status: WatchTrackerStatus.success,
          watchingGoal: goal,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: WatchTrackerStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> _onUpdateWatchGoal(
    UpdateWatchGoal event,
    Emitter<WatchTrackerState> emit,
  ) async {
    try {
      await repository.saveWatchGoal(event.goal);
      emit(
        state.copyWith(
          status: WatchTrackerStatus.success,
          watchingGoal: event.goal,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: WatchTrackerStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> _onLoadWatchingHistory(
    LoadWatchingHistory event,
    Emitter<WatchTrackerState> emit,
  ) async {
    emit(state.copyWith(status: WatchTrackerStatus.loading));
    try {
      final history = await repository.getWatchingHistory();
      emit(
        state.copyWith(
          status: WatchTrackerStatus.success,
          watchingHistory: history,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: WatchTrackerStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> _onAddWatchSession(
    AddWatchSession event,
    Emitter<WatchTrackerState> emit,
  ) async {
    try {
      await repository.addWatchSession(event.session);
      add(LoadWatchingHistory());
    } catch (e) {
      emit(
        state.copyWith(
          status: WatchTrackerStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> _onLoadMovieNotes(
    LoadMovieNotes event,
    Emitter<WatchTrackerState> emit,
  ) async {
    emit(state.copyWith(status: WatchTrackerStatus.loading));
    try {
      final notes = await repository.getMovieNotes(event.movieId);
      emit(
        state.copyWith(
          status: WatchTrackerStatus.success,
          movieNotes: notes,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: WatchTrackerStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> _onAddMovieNote(
    AddMovieNote event,
    Emitter<WatchTrackerState> emit,
  ) async {
    try {
      await repository.addMovieNote(event.note);
      add(LoadMovieNotes(event.note.movieId));
    } catch (e) {
      emit(
        state.copyWith(
          status: WatchTrackerStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> _onDeleteMovieNote(
    DeleteMovieNote event,
    Emitter<WatchTrackerState> emit,
  ) async {
    try {
      await repository.deleteMovieNote(event.noteId);
      add(LoadMovieNotes(event.movieId));
    } catch (e) {
      emit(
        state.copyWith(
          status: WatchTrackerStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }
}
