import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:movie_catalog/core/di/service_locator.dart';
import 'package:movie_catalog/core/router/app_router.dart';
import 'package:movie_catalog/features/auth/bloc/auth_bloc.dart';
import 'package:movie_catalog/features/auth/bloc/auth_event.dart';
import 'package:movie_catalog/features/auth/bloc/auth_state.dart';
import 'package:movie_catalog/features/watching_tracker/bloc/watching_tracker_bloc.dart';
import 'package:movie_catalog/features/watching_tracker/bloc/watching_tracker_event.dart';
import 'package:movie_catalog/features/profile/bloc/profile_cubit.dart';
import 'package:movie_catalog/features/movies/bloc/movies_bloc.dart';
import 'package:movie_catalog/features/movies/bloc/movies_event.dart';
import 'package:movie_catalog/features/theme/bloc/theme_cubit.dart';
import 'package:movie_catalog/features/theme/bloc/theme_state.dart';
import 'package:movie_catalog/shared/app_theme.dart';

class MoviesApp extends StatelessWidget {
  const MoviesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => AuthBloc(
            authService: Services.auth,
          )..add(const CheckAccount()),
        ),
        BlocProvider(
          create: (context) => MoviesBloc(
            repository: Repositories.movies,
          )..add(const LoadMovies()),
        ),
        BlocProvider(
          create: (context) => WatchTrackerBloc(
            repository: Repositories.watchingTracker,
          )..add(LoadWatchGoal(DateTime.now().year))..add(LoadWatchingHistory()),
        ),
        BlocProvider(
          create: (context) => ProfileCubit(
            profileService: Services.profile,
          )..loadProfile(),
        ),
        BlocProvider(
          create: (context) => ThemeCubit()..loadTheme(),
        ),
      ],
      child: BlocBuilder<ThemeCubit, ThemeState>(
        builder: (context, themeState) {
          final themeMode = themeState is ThemeLoaded
              ? themeState.themeMode
              : ThemeMode.light;

          return BlocListener<AuthBloc, AuthState>(
            listener: (context, authState) {},
            child: MaterialApp.router(
              title: 'Movie Atlas',
              theme: AppTheme.lightTheme,
              darkTheme: AppTheme.darkTheme,
              themeMode: themeMode,
              debugShowCheckedModeBanner: false,
              routerConfig: AppRouter.router,
            ),
          );
        },
      ),
    );
  }
}
