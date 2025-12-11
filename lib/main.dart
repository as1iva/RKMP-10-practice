import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:movie_catalog/app.dart';
import 'package:movie_catalog/core/bloc/app_bloc_observer.dart';
import 'package:movie_catalog/core/di/service_locator.dart';
import 'package:movie_catalog/services/logger_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  Bloc.observer = AppBlocObserver();

  await setupServiceLocator();

  Services.image.preloadImagePool().catchError((e) {
    LoggerService.warning('Не удалось подготовить пул постеров для фильмов...: $e');
  });

  runApp(const MoviesApp());
}
