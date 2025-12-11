import 'package:equatable/equatable.dart';

class WatchGoal extends Equatable {
  final int targetMovies;
  final int currentMovies;
  final int year;

  const WatchGoal({
    required this.targetMovies,
    required this.currentMovies,
    required this.year,
  });

  WatchGoal copyWith({
    int? targetMovies,
    int? currentMovies,
    int? year,
  }) {
    return WatchGoal(
      targetMovies: targetMovies ?? this.targetMovies,
      currentMovies: currentMovies ?? this.currentMovies,
      year: year ?? this.year,
    );
  }

  @override
  List<Object?> get props => [targetMovies, currentMovies, year];
}
