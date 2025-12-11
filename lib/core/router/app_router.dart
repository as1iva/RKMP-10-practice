import 'package:go_router/go_router.dart';
import 'package:movie_catalog/core/di/service_locator.dart';
import 'package:movie_catalog/features/auth/login_screen.dart';
import 'package:movie_catalog/features/auth/register_screen.dart';
import 'package:movie_catalog/features/auth/welcome_screen.dart';
import 'package:movie_catalog/features/feedback/presentation/pages/feedback_screen.dart';
import 'package:movie_catalog/features/profile/profile_screen.dart';
import 'package:movie_catalog/features/movies/models/movie.dart';
import 'package:movie_catalog/features/movies/screens/watched_movies_screen.dart';
import 'package:movie_catalog/features/movies/screens/home_screen.dart';
import 'package:movie_catalog/features/movies/screens/my_movies_screen.dart';
import 'package:movie_catalog/features/movies/screens/ratings_screen.dart';
import 'package:movie_catalog/features/movies/screens/movie_detail_screen.dart';
import 'package:movie_catalog/features/movies/screens/movie_form_screen.dart';
import 'package:movie_catalog/features/movies/screens/statistics_screen.dart';
import 'package:movie_catalog/features/movies/screens/to_watch_screen.dart';
import 'package:movie_catalog/features/watching_tracker/screens/watching_goals_screen.dart';
import 'package:movie_catalog/features/watching_tracker/screens/watching_history_screen.dart';
import 'package:movie_catalog/features/watching_tracker/screens/movie_notes_screen.dart';
import 'package:movie_catalog/features/watching_tracker/screens/recommendations_screen.dart';
import 'package:movie_catalog/features/movie_viewer/presentation/screens/import_movie_screen.dart';
import 'package:movie_catalog/features/movie_viewer/presentation/screens/movie_viewer_screen.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/',
    refreshListenable: Services.auth,
    redirect: (context, state) async {
      final isLoggedIn = await Services.auth.isLoggedIn();
      final isGoingToLogin = state.matchedLocation == '/login';
      final isGoingToRegister = state.matchedLocation == '/register';
      final isGoingToWelcome = state.matchedLocation == '/welcome';

      if (!isLoggedIn) {
        if (isGoingToLogin || isGoingToRegister || isGoingToWelcome) return null;
        return '/welcome';
      }

      if (isLoggedIn && (isGoingToLogin || isGoingToRegister || isGoingToWelcome)) {
        return '/';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/welcome',
        name: 'welcome',
        builder: (context, state) => const WelcomeScreen(),
      ),
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        name: 'register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/',
        name: 'home',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/profile',
        name: 'profile',
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        path: '/watched-movies',
        name: 'watched-movies',
        builder: (context, state) => const WatchedMoviesScreen(),
      ),
      GoRoute(
        path: '/to-watch',
        name: 'to-watch',
        builder: (context, state) => const ToWatchScreen(),
      ),
      GoRoute(
        path: '/my-movies',
        name: 'my-movies',
        builder: (context, state) => const MyMoviesScreen(),
      ),
      GoRoute(
        path: '/ratings',
        name: 'ratings',
        builder: (context, state) => const RatingsScreen(),
      ),
      GoRoute(
        path: '/statistics',
        name: 'statistics',
        builder: (context, state) => const StatisticsScreen(),
      ),
      GoRoute(
        path: '/watching-goals',
        name: 'watching-goals',
        builder: (context, state) => const WatchGoalsScreen(),
      ),
      GoRoute(
        path: '/watching-history',
        name: 'watching-history',
        builder: (context, state) => const WatchingHistoryScreen(),
      ),
      GoRoute(
        path: '/movie-notes/:movieId',
        name: 'movie-notes',
        builder: (context, state) {
          final movieId = state.pathParameters['movieId']!;
          return MovieNotesScreen(movieId: movieId);
        },
      ),
      GoRoute(
        path: '/recommendations',
        name: 'recommendations',
        builder: (context, state) => const RecommendationsScreen(),
      ),
      GoRoute(
        path: '/movie/:id',
        name: 'movie-detail',
        builder: (context, state) {
          final movie = state.extra as Movie;
          return MovieDetailScreen(movie: movie);
        },
      ),
      GoRoute(
        path: '/movie-form',
        name: 'movie-form',
        builder: (context, state) {
          final params = state.extra as Map<String, dynamic>?;
          final onSave = params?['onSave'] as Function(Movie)?;
          final movie = params?['movie'] as Movie?;

          return MovieFormScreen(
            onSave: onSave ?? (movie) {},
            movie: movie,
          );
        },
      ),
      GoRoute(
        path: '/import',
        name: 'import',
        builder: (context, state) => const ImportMovieScreen(),
      ),
      GoRoute(
        path: '/movie-viewer',
        name: 'movie-viewer',
        builder: (context, state) {
          final movie = state.extra as Movie;
          return MovieViewerScreen(movie: movie);
        },
      ),
      GoRoute(
        path: '/feedback',
        name: 'feedback',
        builder: (context, state) => const FeedbackScreen(),
      ),
    ],
  );
}





