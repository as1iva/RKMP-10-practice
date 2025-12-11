import 'package:equatable/equatable.dart';

class MovieNote extends Equatable {
  final String id;
  final String movieId;
  final String content;
  final int? stepNumber;
  final DateTime date;

  const MovieNote({
    required this.id,
    required this.movieId,
    required this.content,
    this.stepNumber,
    required this.date,
  });

  @override
  List<Object?> get props => [id, movieId, content, stepNumber, date];
}

