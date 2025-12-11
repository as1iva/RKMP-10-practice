import 'package:equatable/equatable.dart';

class WatchSession extends Equatable {
  final String id;
  final String movieId;
  final DateTime date;
  final int? minutesWatched;

  const WatchSession({
    required this.id,
    required this.movieId,
    required this.date,
    this.minutesWatched,
  });

  @override
  List<Object?> get props => [id, movieId, date, minutesWatched];
}
