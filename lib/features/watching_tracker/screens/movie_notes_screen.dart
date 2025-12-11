import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import 'package:movie_catalog/features/watching_tracker/bloc/watching_tracker_bloc.dart';
import 'package:movie_catalog/features/watching_tracker/bloc/watching_tracker_event.dart';
import 'package:movie_catalog/features/watching_tracker/bloc/watching_tracker_state.dart';
import 'package:movie_catalog/features/watching_tracker/models/movie_note.dart';

class MovieNotesScreen extends StatefulWidget {
  final String movieId;

  const MovieNotesScreen({super.key, required this.movieId});

  @override
  State<MovieNotesScreen> createState() => _MovieNotesScreenState();
}

class _MovieNotesScreenState extends State<MovieNotesScreen> {
  @override
  void initState() {
    super.initState();
    context.read<WatchTrackerBloc>().add(LoadMovieNotes(widget.movieId));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Заметки'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddNoteDialog(context),
        child: const Icon(Icons.add),
      ),
      body: BlocBuilder<WatchTrackerBloc, WatchTrackerState>(
        builder: (context, state) {
          if (state.status == WatchTrackerStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.movieNotes.isEmpty) {
            return const Center(child: Text('Заметок пока нет'));
          }

          return ListView.builder(
            itemCount: state.movieNotes.length,
            itemBuilder: (context, index) {
              final note = state.movieNotes[index];
              return Card(
                margin: const EdgeInsets.all(8.0),
                child: ListTile(
                  title: Text(note.content),
                  subtitle: Text(
                    '${DateFormat.yMMMd().format(note.date)}${note.stepNumber != null ? ' • Шаг ${note.stepNumber}' : ''}',
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () {
                      context.read<WatchTrackerBloc>().add(
                            DeleteMovieNote(note.id, widget.movieId),
                          );
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _showAddNoteDialog(BuildContext context) {
    final contentController = TextEditingController();
    final stepController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Добавить заметку'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: contentController,
              decoration: const InputDecoration(
                labelText: 'Текст заметки',
              ),
              maxLines: 3,
            ),
            TextField(
              controller: stepController,
              decoration: const InputDecoration(
                labelText: 'Номер шага (необязательно)',
              ),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () {
              if (contentController.text.isNotEmpty) {
                final note = MovieNote(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  movieId: widget.movieId,
                  content: contentController.text,
                  stepNumber: int.tryParse(stepController.text),
                  date: DateTime.now(),
                );
                context.read<WatchTrackerBloc>().add(AddMovieNote(note));
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
