import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:movie_catalog/features/movies/bloc/movies_bloc.dart';
import 'package:movie_catalog/features/movies/bloc/movies_event.dart';
import 'package:movie_catalog/features/movies/bloc/movies_state.dart';
import 'package:movie_catalog/features/movies/widgets/movie_tile.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void _showAddMovieSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (modalContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit_note),
              title: const Text('Добавить новый фильм'),
              onTap: () {
                Navigator.pop(modalContext);
                context.push('/movie-form', extra: {
                  'onSave': (movie) {
                    context.read<MoviesBloc>().add(AddMovie(movie));
                    context.pop();
                  },
                });
              },
            ),
            ListTile(
              leading: const Icon(Icons.file_upload),
              title: const Text('Импортировать файл'),
              subtitle: const Text('EPUB, FB2'),
              onTap: () {
                Navigator.pop(modalContext);
                context.push('/import');
              },
            ),
          ],
        ),
      ),
    );
  }

  void _openProfile(BuildContext context) => context.push('/profile');

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      body: BlocBuilder<MoviesBloc, MoviesState>(
        builder: (context, state) {
          if (state is MoviesLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is MoviesError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: colorScheme.error),
                  const SizedBox(height: 16),
                  Text(state.message, style: theme.textTheme.titleMedium),
                ],
              ),
            );
          }

          if (state is! MoviesLoaded) {
            return const Center(child: Text('Не удалось загрузить фильмы'));
          }

          final total = state.totalMovies;
          final watched = state.watchedMovies;
          final planned = state.plannedMovies;
          final recent = state.recentMovies;

          return CustomScrollView(
            slivers: [
              SliverAppBar.large(
                floating: true,
                pinned: true,
                expandedHeight: 120,
                flexibleSpace: FlexibleSpaceBar(
                  title: const Text(
                    'Каталог фильмов',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  background: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          colorScheme.primaryContainer,
                          colorScheme.secondaryContainer,
                        ],
                      ),
                    ),
                  ),
                  centerTitle: true,
                ),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.person_outline),
                    onPressed: () => _openProfile(context),
                    tooltip: 'Профиль',
                  ),
                ],
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              colorScheme.primary,
                              colorScheme.secondary,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: colorScheme.primary.withValues(alpha: 0.3),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: InkWell(
                          onTap: () => context.push('/my-movies'),
                          borderRadius: BorderRadius.circular(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.movie_filter_outlined,
                                    color: colorScheme.onPrimary,
                                    size: 32,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Моя коллекция',
                                          style: TextStyle(
                                            color: colorScheme.onPrimary,
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          '$total ${_moviesWord(total)}',
                                          style: TextStyle(
                                            color: colorScheme.onPrimary.withValues(alpha: 0.9),
                                            fontSize: 14,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  _statPill(
                                    colorScheme,
                                    icon: Icons.check_circle_outline,
                                    label: 'Просмотрено',
                                    value: '$watched',
                                  ),
                                  const SizedBox(width: 12),
                                  _statPill(
                                    colorScheme,
                                    icon: Icons.schedule,
                                    label: 'Запланировано',
                                    value: '$planned',
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  Expanded(
                                    child: ElevatedButton.icon(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: colorScheme.onPrimary.withValues(alpha: 0.12),
                                        foregroundColor: colorScheme.onPrimary,
                                        padding: const EdgeInsets.symmetric(vertical: 14),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(14),
                                        ),
                                        elevation: 0,
                                      ),
                                      onPressed: () => context.push('/statistics'),
                                      icon: const Icon(Icons.pie_chart_rounded),
                                      label: const Text('Статистика'),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: ElevatedButton.icon(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: colorScheme.onPrimary.withValues(alpha: 0.12),
                                        foregroundColor: colorScheme.onPrimary,
                                        padding: const EdgeInsets.symmetric(vertical: 14),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(14),
                                        ),
                                        elevation: 0,
                                      ),
                                      onPressed: () => context.push('/recommendations'),
                                      icon: const Icon(Icons.auto_awesome),
                                      label: const Text('Рекомендации'),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Text(
                            'Недавно добавленные',
                            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const Spacer(),
                          IconButton(
                            tooltip: 'Добавить фильм',
                            onPressed: () => _showAddMovieSheet(context),
                            icon: const Icon(Icons.add_circle_outline),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      if (recent.isEmpty)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: colorScheme.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            children: [
                              Icon(Icons.local_movies_outlined, color: colorScheme.primary),
                              const SizedBox(height: 8),
                              const Text('Пока нет фильмов. Добавьте первый!'),
                            ],
                          ),
                        )
                      else
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: recent.length,
                          itemBuilder: (context, index) {
                            final movie = recent[index];
                            return MovieTile(movie: movie);
                          },
                        ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _statPill(
    ColorScheme scheme, {
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: scheme.onPrimary.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: scheme.onPrimary),
          const SizedBox(width: 6),
          Text(label, style: TextStyle(color: scheme.onPrimary)),
          const SizedBox(width: 6),
          Text(
            value,
            style: TextStyle(
              color: scheme.onPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  String _moviesWord(int count) {
    final mod10 = count % 10;
    final mod100 = count % 100;
    if (mod10 == 1 && mod100 != 11) return 'фильм';
    if (mod10 >= 2 && mod10 <= 4 && (mod100 < 12 || mod100 > 14)) return 'фильма';
    return 'фильмов';
  }
}
