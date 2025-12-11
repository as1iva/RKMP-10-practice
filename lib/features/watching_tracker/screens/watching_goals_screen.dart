import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:movie_catalog/features/watching_tracker/bloc/watching_tracker_bloc.dart';
import 'package:movie_catalog/features/watching_tracker/bloc/watching_tracker_event.dart';
import 'package:movie_catalog/features/watching_tracker/bloc/watching_tracker_state.dart';
import 'package:movie_catalog/features/watching_tracker/models/watching_goal.dart';
import 'package:movie_catalog/features/movies/bloc/movies_bloc.dart';
import 'package:movie_catalog/features/movies/bloc/movies_state.dart';

class WatchGoalsScreen extends StatelessWidget {
  const WatchGoalsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Цели на год'),
      ),
      body: BlocBuilder<WatchTrackerBloc, WatchTrackerState>(
        builder: (context, trackerState) {
          if (trackerState.status == WatchTrackerStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          final goal = trackerState.watchingGoal;
          if (goal == null) {
            return const Center(child: Text('Цель не задана'));
          }

          return BlocBuilder<MoviesBloc, MoviesState>(
            builder: (context, moviesState) {
              int currentMovies = 0;
              if (moviesState is MoviesLoaded) {
                currentMovies = moviesState.movies
                    .where((r) => r.isWatched && (r.lastWatched?.year == goal.year))
                    .length;
              }

              final progress = goal.targetMovies > 0 ? currentMovies / goal.targetMovies : 0.0;

              return Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        'Цель на ${goal.year} год',
                        style: Theme.of(context).textTheme.headlineSmall,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 40),
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          SizedBox(
                            width: 200,
                            height: 200,
                            child: CircularProgressIndicator(
                              value: progress.clamp(0.0, 1.0),
                              strokeWidth: 15,
                              backgroundColor: Colors.grey[200],
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                          Column(
                            children: [
                              Text(
                                '${(progress * 100).toInt()}%',
                                style: Theme.of(context).textTheme.displayMedium,
                              ),
                              Text(
                                '$currentMovies из ${goal.targetMovies}',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 40),
                      ElevatedButton.icon(
                        onPressed: () => _showEditGoalDialog(context, goal),
                        icon: const Icon(Icons.edit),
                        label: const Text('Изменить цель'),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _showEditGoalDialog(BuildContext context, WatchGoal currentGoal) {
    final controller = TextEditingController(text: currentGoal.targetMovies.toString());
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Изменить цель'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Количество фильмов',
            hintText: 'Например, 50',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () {
              final target = int.tryParse(controller.text);
              if (target != null && target > 0) {
                context.read<WatchTrackerBloc>().add(
                      UpdateWatchGoal(currentGoal.copyWith(targetMovies: target)),
                    );
                Navigator.pop(context);
              }
            },
            child: const Text('Сохранить'),
          ),
        ],
      ),
    );
  }
}
