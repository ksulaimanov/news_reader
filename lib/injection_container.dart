import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';

import 'core/network/dio_client.dart';
import 'features/news/data/datasources/news_remote_data_source.dart';
import 'features/news/data/repositories/news_repository_impl.dart';
import 'features/news/domain/repositories/news_repository.dart';
import 'features/news/domain/usecases/get_top_stories.dart';
import 'features/news/presentation/bloc/news_bloc.dart';

final sl = GetIt.instance;

void initDependencies() {
  sl
    ..registerLazySingleton<Dio>(createDio)
    ..registerLazySingleton<NewsRemoteDataSource>(
      () => NewsRemoteDataSourceImpl(sl()),
    )
    ..registerLazySingleton<NewsRepository>(() => NewsRepositoryImpl(sl()))
    ..registerLazySingleton(() => GetTopStories(sl()))
    ..registerFactory(() => NewsBloc(sl()));
}
