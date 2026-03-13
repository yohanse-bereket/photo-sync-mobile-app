import 'package:dio/dio.dart';
import 'package:photo_sync_app/core/network/auth_interceptor.dart';
import 'package:photo_sync_app/features/gallery/data/datasource/local_datasource.dart';
import 'package:photo_sync_app/features/gallery/presentation/bloc/logout/logout_bloc.dart';
import 'package:photo_sync_app/injection.dart';

class DioClient {
  static Dio create({required GalleryLocalDataSource localDataSource}) {
    final dio = Dio(BaseOptions(baseUrl: "https://api.bereket.us/api"));

    final authInterceptor = AuthInterceptor(
      dio: dio,
      localDataSource: localDataSource,
    );

    authInterceptor.logoutController.stream.listen((_) {
      sl<LogoutBloc>().add(LogoutRequested());
    });

    dio.interceptors.add(authInterceptor);

    return dio;
  }
}
