import 'package:flutter/material.dart';

import 'package:movie_catalog/features/movies/models/movie.dart';
import 'package:movie_catalog/shared/constants.dart';

class MovieFormScreen extends StatefulWidget {
  final Function(Movie) onSave;
  final Movie? movie;

  const MovieFormScreen({
    super.key,
    required this.onSave,
    this.movie,
  });

  @override
  State<MovieFormScreen> createState() => _MovieFormScreenState();
}

class _MovieFormScreenState extends State<MovieFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _directorController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _durationController = TextEditingController();
  String _selectedGenre = AppConstants.genres.first;

  @override
  void initState() {
    super.initState();
    if (widget.movie != null) {
      _nameController.text = widget.movie!.name;
      _directorController.text = widget.movie!.director;
      _selectedGenre = AppConstants.genres.contains(widget.movie!.genre)
          ? widget.movie!.genre
          : 'Другое';
      _descriptionController.text = widget.movie!.description ?? '';
      _durationController.text = widget.movie!.duration?.toString() ?? '';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _directorController.dispose();
    _descriptionController.dispose();
    _durationController.dispose();
    super.dispose();
  }

  void _saveMovie() {
    if (_formKey.currentState!.validate()) {
      final movie = widget.movie?.copyWith(
            name: _nameController.text.trim(),
            director: _directorController.text.trim(),
            genre: _selectedGenre,
            description: _descriptionController.text.trim().isEmpty
                ? null
                : _descriptionController.text.trim(),
            duration: _durationController.text.trim().isEmpty
                ? null
                : int.tryParse(_durationController.text.trim()),
          ) ??
          Movie(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            name: _nameController.text.trim(),
            director: _directorController.text.trim(),
            genre: _selectedGenre,
            description: _descriptionController.text.trim().isEmpty
                ? null
                : _descriptionController.text.trim(),
            duration: _durationController.text.trim().isEmpty
                ? null
                : int.tryParse(_durationController.text.trim()),
            dateAdded: DateTime.now(),
          );

      widget.onSave(movie);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.movie != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Редактировать фильм' : 'Новый фильм'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 8),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Название фильма *',
                  hintText: 'Введите название',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(16)),
                  ),
                  prefixIcon: Icon(Icons.movie_creation_outlined),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Введите название фильма';
                  }
                  return null;
                },
                textCapitalization: TextCapitalization.words,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _directorController,
                decoration: const InputDecoration(
                  labelText: 'Режиссер *',
                  hintText: 'Кто снял фильм',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(16)),
                  ),
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Укажите режиссера';
                  }
                  return null;
                },
                textCapitalization: TextCapitalization.words,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Жанр *',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(16)),
                  ),
                  prefixIcon: Icon(Icons.category),
                ),
                items: AppConstants.genres
                    .map((genre) => DropdownMenuItem(
                          value: genre,
                          child: Text(genre),
                        ))
                    .toList(),
                onChanged: (value) => setState(() => _selectedGenre = value!),
                value: _selectedGenre,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _durationController,
                decoration: const InputDecoration(
                  labelText: 'Длительность, мин',
                  hintText: 'Например, 120',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(16)),
                  ),
                  prefixIcon: Icon(Icons.numbers),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value != null && value.trim().isNotEmpty) {
                    if (int.tryParse(value.trim()) == null) {
                      return 'Введите длительность в минутах';
                    }
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Описание',
                  hintText: 'О чем фильм и чем он запомнился',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(16)),
                  ),
                  prefixIcon: Icon(Icons.description),
                ),
                maxLines: 4,
                textCapitalization: TextCapitalization.sentences,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _saveMovie,
                icon: Icon(isEditing ? Icons.save : Icons.add),
                label: Text(isEditing ? 'Сохранить изменения' : 'Добавить фильм'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
