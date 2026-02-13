import 'package:dio/dio.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get_it/get_it.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:photo_sync_app/core/network/dio_client.dart';
import 'package:photo_sync_app/core/network/network.dart';
import 'package:photo_sync_app/features/gallery/data/datasource/local_datasource.dart';
import 'package:photo_sync_app/features/gallery/data/datasource/remote_datasource.dart';
import 'package:photo_sync_app/features/gallery/data/repository/gallery_impl.dart';
import 'package:photo_sync_app/features/gallery/data/services/local_hashing_service.dart';
import 'package:photo_sync_app/features/gallery/data/services/local_sync_notification_service.dart';
import 'package:photo_sync_app/features/gallery/domain/repository/gallery.dart';
import 'package:photo_sync_app/features/gallery/domain/services/hashing_service.dart';
import 'package:photo_sync_app/features/gallery/domain/usecases/fetch_image.dart';
import 'package:photo_sync_app/features/gallery/domain/usecases/fetch_images.dart';
import 'package:photo_sync_app/features/gallery/domain/usecases/login.dart';
import 'package:photo_sync_app/features/gallery/domain/usecases/logout.dart';
import 'package:photo_sync_app/features/gallery/domain/usecases/register.dart';
import 'package:photo_sync_app/features/gallery/domain/usecases/sync_image.dart';
import 'package:photo_sync_app/features/gallery/domain/usecases/upload_image.dart';
import 'package:photo_sync_app/features/gallery/presentation/bloc/image/image_bloc.dart';
import 'package:photo_sync_app/features/gallery/domain/services/notification_service.dart';
import 'package:photo_sync_app/features/gallery/presentation/bloc/login/login_bloc.dart';
import 'package:photo_sync_app/features/gallery/presentation/bloc/logout/logout_bloc.dart';
import 'package:photo_sync_app/features/gallery/presentation/bloc/photo%20main/image_bloc.dart';
import 'package:photo_sync_app/features/gallery/presentation/bloc/register/register_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

final sl = GetIt.instance;

Future<void> init() async {
  //Bloc
  sl.registerFactory(
    () => ImageBloc(uploadImageUsecase: sl(), fetchImagesUsecase: sl()),
  );
  sl.registerFactory(
    () => PhotoMainBloc(fetchImageUsecase: sl()),
  );
  sl.registerLazySingleton<LogoutBloc>(
  () => LogoutBloc(logoutUsecase: sl()),
);
  sl.registerFactory(
    () => LoginBloc(loginUsecase: sl()),
  );
  sl.registerFactory(
    () => RegisterBloc(registerUsecase: sl()),
  );

  //use case
  sl.registerLazySingleton(() => UploadImageUsecase(sl()));
  sl.registerLazySingleton(
    () => SyncImageUsecase(repository: sl(), notificationService: sl()),
  );
  sl.registerLazySingleton(() => FetchImagesUsecase(sl()));
  sl.registerLazySingleton(() => FetchImageUsecase(sl()));
  sl.registerLazySingleton(() => LoginUsecase(sl()));
  sl.registerLazySingleton(() => LogoutUsecase(sl()));
  sl.registerLazySingleton(() => RegisterUsecase(sl()));

  //Remote Data Source
  sl.registerLazySingleton<GalleryRemoteDataSource>(
    () => GalleryRemoteDataSourceImpl(
      galleryLocalDataSource: sl(),
      dio: sl(),
      hashingService: sl(),
    ),
  );

  // Local Data Source
  sl.registerLazySingleton<GalleryLocalDataSource>(
    () => GalleryLocalDataSourceImpl(sharedPreferences: sl()),
  );

  // Repository
  sl.registerLazySingleton<GalleryRepository>(
    () => GalleryRepositoryImpl(
      galleryRemoteDataSource: sl(),
      networkInfo: sl(),
      galleryLocalDataSource: sl(),
    ),
  );

  //Core
  sl.registerLazySingleton<NetworkInfo>(
    () => NetworkInfoImpl(connectionChecker: sl()),
  );

  sl.registerLazySingleton<SyncNotificationService>(
    () => LocalSyncNotificationService(),
  );

  //External
  sl.registerLazySingleton(() => InternetConnectionChecker.createInstance());
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPreferences);
  sl.registerLazySingleton<FlutterLocalNotificationsPlugin>(
    () => FlutterLocalNotificationsPlugin(),
  );
  sl.registerLazySingleton<HashingService>(() => Sha256HashingService());
  // Dio
  sl.registerLazySingleton<Dio>(
    () => DioClient.create(
      localDataSource: sl(),
    ),
  );
}
