import 'dart:async';

import 'package:dio/dio.dart';
import 'package:photo_sync_app/features/gallery/data/datasource/local_datasource.dart';

class AuthInterceptor extends Interceptor {
  final Dio dio;
  final GalleryLocalDataSource localDataSource;

  final StreamController<void> logoutController = StreamController.broadcast();

  bool _isRefreshing = false;

  AuthInterceptor({
    required this.dio,
    required this.localDataSource,
  });

  bool _isAuthEndpoint(String path) {
    return path.contains("/auth/login") ||
        path.contains("/users") ||
        path.contains("/auth/refresh") ||
        path.contains("/auth/logout");
  }

  // ---------------------------
  // Attach Access Token
  // ---------------------------
  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    if (!_isAuthEndpoint(options.path)) {
      final token = await localDataSource.getAccessToken();
      if (token != null) {
        options.headers['Authorization'] = 'Bearer $token';
      }
    }

    handler.next(options);
  }

  // ---------------------------
  // Handle 401
  // ---------------------------
  @override
  void onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final requestPath = err.requestOptions.path;

    // If it's auth endpoint → don't refresh
    if (_isAuthEndpoint(requestPath)) {
      return handler.next(err);
    }

    if (err.response?.statusCode == 401) {
      final refreshToken = await localDataSource.getRefreshToken();

      if (refreshToken == null) {
        await localDataSource.clearTokens();
        return handler.next(err);
      }

      if (!_isRefreshing) {
        _isRefreshing = true;

        try {
          final response = await dio.post(
            "/auth/refresh",
            data: {'refreshToken': refreshToken},
          );

          final newAccessToken = response.data['accessToken'];

          await localDataSource.setAccessToken(newAccessToken);

          _isRefreshing = false;

          // Retry original request
          final options = err.requestOptions;
          options.headers['Authorization'] =
              'Bearer $newAccessToken';

          final cloneReq = await dio.fetch(options);
          return handler.resolve(cloneReq);
        } catch (e) {
          _isRefreshing = false;
          await localDataSource.clearTokens();
          print("Token refresh failed: $e");
          logoutController.add(null);
          print("🔥 Logout event emitted");
          return handler.next(err);
        }
      }
    }

    handler.next(err);
  }
}
