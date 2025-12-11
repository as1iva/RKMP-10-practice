import 'package:equatable/equatable.dart';

class Movie extends Equatable {
  final String id;
  final String name;
  final String director;
  final String genre;
  final String? description;
  final int? duration;
  final bool isWatched;
  final int? rating;
  final DateTime dateAdded;
  final DateTime? lastWatched;
  final String? imageUrl;
  final String? filePath;
  final String? fileFormat;
  final String? lastViewedStep;

  const Movie({
    required this.id,
    required this.name,
    required this.director,
    required this.genre,
    this.description,
    this.duration,
    this.isWatched = false,
    this.rating,
    required this.dateAdded,
    this.lastWatched,
    this.imageUrl,
    this.filePath,
    this.fileFormat,
    this.lastViewedStep,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        director,
        genre,
        description,
        duration,
        isWatched,
        rating,
        dateAdded,
        lastWatched,
        imageUrl,
        filePath,
        fileFormat,
        lastViewedStep,
      ];

  Movie copyWith({
    String? id,
    String? name,
    String? director,
    String? genre,
    String? description,
    int? duration,
    bool? isWatched,
    int? rating,
    DateTime? dateAdded,
    DateTime? lastWatched,
    String? imageUrl,
    String? filePath,
    String? fileFormat,
    String? lastViewedStep,
  }) {
    return Movie(
      id: id ?? this.id,
      name: name ?? this.name,
      director: director ?? this.director,
      genre: genre ?? this.genre,
      description: description ?? this.description,
      duration: duration ?? this.duration,
      isWatched: isWatched ?? this.isWatched,
      rating: rating ?? this.rating,
      dateAdded: dateAdded ?? this.dateAdded,
      lastWatched: lastWatched ?? this.lastWatched,
      imageUrl: imageUrl ?? this.imageUrl,
      filePath: filePath ?? this.filePath,
      fileFormat: fileFormat ?? this.fileFormat,
      lastViewedStep: lastViewedStep ?? this.lastViewedStep,
    );
  }
}
