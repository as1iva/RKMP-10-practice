import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:movie_catalog/features/movies/bloc/movies_bloc.dart';
import 'package:movie_catalog/features/movies/bloc/movies_event.dart';
import 'package:movie_catalog/features/movies/models/movie.dart';

class MovieTile extends StatelessWidget {
  final Movie movie;

  const MovieTile({
    super.key,
    required this.movie,
  });

  void _showRatingDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Оцените фильм'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              movie.name,
              style: const TextStyle(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                final rating = index + 1;
                return IconButton(
                  icon: Icon(
                    rating <= (movie.rating ?? 0) ? Icons.star : Icons.star_border,
                    color: Colors.amber,
                    size: 32,
                  ),
                  onPressed: () {
                    context.read<MoviesBloc>().add(RateMovie(movie.id, rating));
                    Navigator.pop(dialogContext);
                  },
                );
              }),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Отмена'),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Удалить фильм?'),
        content: Text('Вы уверены, что хотите удалить "${movie.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<MoviesBloc>().add(DeleteMovie(movie.id));
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Удалить'),
          ),
        ],
      ),
    );
  }

  void _navigateToDetail(BuildContext context) {
    context.push('/movie/${movie.id}', extra: movie);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      elevation: 2,
      child: InkWell(
        onTap: () => _navigateToDetail(context),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Stack(
                children: [
                  if (movie.imageUrl != null)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: CachedNetworkImage(
                        imageUrl: movie.imageUrl!,
                        width: 60,
                        height: 85,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          width: 60,
                          height: 85,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: Colors.grey[300],
                          ),
                          child: const Center(
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        ),
                        errorWidget: (context, url, error) => Container(
                          width: 60,
                          height: 85,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                movie.isWatched ? Colors.green.shade400 : Colors.orange.shade400,
                                movie.isWatched ? Colors.green.shade700 : Colors.orange.shade700,
                              ],
                            ),
                          ),
                          child: Center(
                            child: Icon(
                              Icons.local_movies,
                              color: Colors.white.withValues(alpha: 0.7),
                              size: 32,
                            ),
                          ),
                        ),
                      ),
                    )
                  else
                    Container(
                      width: 60,
                      height: 85,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            movie.isWatched ? Colors.green.shade400 : Colors.orange.shade400,
                            movie.isWatched ? Colors.green.shade700 : Colors.orange.shade700,
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.2),
                            blurRadius: 4,
                            offset: const Offset(2, 2),
                          ),
                        ],
                      ),
                    child: Center(
                      child: Icon(
                        Icons.local_movies,
                        color: Colors.white.withValues(alpha: 0.7),
                        size: 32,
                        ),
                      ),
                    ),
                  Positioned(
                    top: 4,
                    right: 4,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: movie.isWatched ? Colors.green : Colors.orange,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: Icon(
                        movie.isWatched ? Icons.check : Icons.schedule,
                        color: Colors.white,
                        size: 14,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      movie.name,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      movie.director,
                      style: TextStyle(color: Colors.grey[700]),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      movie.genre,
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          movie.isWatched ? Icons.check_circle_outline : Icons.schedule,
                          color: movie.isWatched ? Colors.green : Colors.orange,
                          size: 18,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          movie.isWatched ? 'Просмотрено' : 'Запланировано',
                          style: TextStyle(
                            color: movie.isWatched ? Colors.green : Colors.orange,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          icon: Icon(
                            movie.rating == null ? Icons.star_border : Icons.star,
                            color: Colors.amber,
                          ),
                          tooltip: 'Поставить оценку',
                          onPressed: () => _showRatingDialog(context),
                        ),
                        IconButton(
                          icon: Icon(
                            movie.isWatched ? Icons.undo : Icons.check_circle,
                            color: movie.isWatched ? Colors.grey : Colors.green,
                          ),
                          tooltip: movie.isWatched ? 'Сбросить' : 'Отметить как просмотрено',
                          onPressed: () => context
                              .read<MoviesBloc>()
                              .add(ToggleMovieWatched(movie.id, !movie.isWatched)),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline),
                          onPressed: () => _showDeleteConfirmation(context),
                          tooltip: 'Удалить',
                          color: Colors.redAccent,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
