import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

import '../../data/datasources/local/article_local_data_source.dart';
import '../../data/datasources/remote/article_remote_data_source.dart';
import '../../data/models/article_model.dart';
import '../../data/repositories/article_repository_impl.dart';
import '../../domain/repositories/article_repository.dart';
import '../../domain/usecases/get_articles.dart';
import '../../presentation/blocs/article/article_bloc.dart';
import '../network/dio_client.dart';

import '../native/native_service.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // 1. External (Database & Network)
  final dir = await getApplicationDocumentsDirectory();
  final isar = await Isar.open(
    [ArticleModelSchema], // Schema akan di-generate oleh build_runner
    directory: dir.path,
  );
  sl.registerLazySingleton<Isar>(() => isar);
  
  sl.registerLazySingleton<Dio>(() => DioClient().dio);
  
  // Native MethodChannel
  sl.registerLazySingleton<NativeService>(() => NativeService());

  // 2. Data Sources
  sl.registerLazySingleton<ArticleLocalDataSource>(
    () => ArticleLocalDataSourceImpl(isar: sl()),
  );
  sl.registerLazySingleton<ArticleRemoteDataSource>(
    () => ArticleRemoteDataSourceImpl(dio: sl()),
  );

  // 3. Repository
  sl.registerLazySingleton<ArticleRepository>(
    () => ArticleRepositoryImpl(
      remoteDataSource: sl(),
      localDataSource: sl(),
    ),
  );

  // 4. Use Cases
  sl.registerLazySingleton(() => GetArticles(sl()));

  // 5. Bloc
  sl.registerFactory(() => ArticleBloc(getArticles: sl()));
}

