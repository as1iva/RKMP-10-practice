import 'package:get_it/get_it.dart';
import 'package:movie_catalog/services/image_service.dart';
import 'package:movie_catalog/services/profile_service.dart';
import 'package:movie_catalog/services/auth_service.dart';
import 'package:movie_catalog/services/feedback_service.dart';
import 'package:movie_catalog/features/movies/data/datasources/movies_local_datasource.dart';
import 'package:movie_catalog/features/movies/data/repositories/movies_repository.dart';
import 'package:movie_catalog/features/movies/data/repositories/movies_repository_impl.dart';
import 'package:movie_catalog/features/watching_tracker/data/datasources/watching_tracker_local_datasource.dart';
import 'package:movie_catalog/features/watching_tracker/data/repositories/watching_tracker_repository.dart';
import 'package:movie_catalog/features/watching_tracker/data/repositories/watching_tracker_repository_impl.dart';
import 'package:movie_catalog/features/movie_viewer/data/file_repository.dart';

final getIt = GetIt.instance;

Future<void> setupServiceLocator() async {
  getIt.registerSingleton<MoviesLocalDataSource>(MoviesLocalDataSource());
  getIt.registerSingleton<WatchTrackerLocalDataSource>(WatchTrackerLocalDataSource());
  getIt.registerSingleton<FileRepository>(FileRepository());

  getIt.registerSingleton<MoviesRepository>(
    MoviesRepositoryImpl(localDataSource: getIt<MoviesLocalDataSource>()),
  );

  getIt.registerSingleton<WatchTrackerRepository>(
    WatchTrackerRepositoryImpl(localDataSource: getIt<WatchTrackerLocalDataSource>()),
  );

  getIt.registerSingleton<ImageService>(ImageService());

  await getIt<ImageService>().initialize();

  getIt.registerSingleton<ProfileService>(ProfileService());

  getIt.registerSingleton<AuthService>(AuthService());

  getIt.registerSingleton<FeedbackService>(FeedbackService());
}

class Services {
  static ImageService get image => getIt<ImageService>();
  static ProfileService get profile => getIt<ProfileService>();
  static AuthService get auth => getIt<AuthService>();
  static FeedbackService get feedback => getIt<FeedbackService>();
}

class Repositories {
  static MoviesRepository get movies => getIt<MoviesRepository>();
  static WatchTrackerRepository get watchingTracker => getIt<WatchTrackerRepository>();
  static FileRepository get files => getIt<FileRepository>();
}






