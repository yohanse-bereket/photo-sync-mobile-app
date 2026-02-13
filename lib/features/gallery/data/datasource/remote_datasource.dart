import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:photo_sync_app/core/error/exception.dart';
import 'package:photo_sync_app/core/response/page_result.dart';
import 'package:photo_sync_app/features/gallery/data/datasource/local_datasource.dart';
import 'package:photo_sync_app/features/gallery/data/models/photo_model.dart';
import 'package:photo_sync_app/features/gallery/data/models/thumbnail_model.dart';
import 'package:photo_sync_app/features/gallery/domain/services/hashing_service.dart';
import 'package:photo_sync_app/utilities/presigned_url_response.dart';

abstract class GalleryRemoteDataSource {
  GalleryLocalDataSource get galleryLocalDataSource;
  HashingService get hashingService;
  Dio get dio;

  Future<PagedResult<List<ThumbnailModel>>> fetchImages(String? nextCursor);
  Future<void> uploadImage(
    AssetEntity image,
    void Function(double progress) onProgress,
  );
  Future<PresignedUrlResponse> getPresignedUrl(
    int size,
    String? mimeType,
    String hash,
    String takenAt,
  );
  Future<PhotoModel> fetchImage(String photoID);
  Future<void> login(String email, String password);
  Future<void> register(String email, String password, String name);
  Future<void> logout();
}

class GalleryRemoteDataSourceImpl implements GalleryRemoteDataSource {

  @override
  final GalleryLocalDataSource galleryLocalDataSource;

  @override
  final Dio dio;

  @override
  final HashingService hashingService;

  GalleryRemoteDataSourceImpl({
    required this.galleryLocalDataSource,
    required this.dio,
    required this.hashingService,
  });

  // -------------------------------------------------------
  // FETCH IMAGES
  // -------------------------------------------------------
  @override
  Future<PagedResult<List<ThumbnailModel>>> fetchImages(
    String? nextCursor,
  ) async {
    try {
      String url = "/photos";
      if (nextCursor != null) {
        url = "$url&cursor=$nextCursor";
      }

      print("Fetching photos from: $url");
      final response = await dio.get(url);
      print("Response data: ${response.data}");
      final responseData = response.data;

      final List<Map<String, dynamic>> data =
          List<Map<String, dynamic>>.from(responseData['data']);

      final photos = data
          .map((photoJson) => ThumbnailModel.fromJson(photoJson))
          .toList();

      return PagedResult<List<ThumbnailModel>>(
        items: photos,
        hasMore: responseData['hasMore'],
        nextCursor: responseData['nextCursor'],
      );
    } on DioException catch (e) {
      throw ServerException(e.message ?? "Failed to fetch photos");
    }
  }

  // -------------------------------------------------------
  // UPLOAD IMAGE
  // -------------------------------------------------------
  @override
  Future<void> uploadImage(
    AssetEntity image,
    void Function(double progress) onProgress,
  ) async {
    final file = await image.file;
    if (file == null) {
      throw ServerException("Image file is null");
    }

    final data = await file.readAsBytes();
    final size = data.lengthInBytes;
    final takenAt = image.createDateTime.toUtc().toIso8601String();
    final hash = await hashingService.generateHash(data);

    try {
      final presignedUrlResponse = await getPresignedUrl(
        size,
        image.mimeType,
        hash,
        takenAt,
      );

      if (presignedUrlResponse.url.isEmpty) {
        // Image already exists
        return;
      }

      // Upload directly to S3 / MinIO
      await dio.put(
        presignedUrlResponse.url,
        data: data,
        options: Options(
          headers: {'Content-Type': image.mimeType},
        ),
        onSendProgress: (sent, total) {
          onProgress(sent / total);
        },
      );

      // Confirm upload
      await dio.post(
        '/photos/${presignedUrlResponse.photoId}/confirm',
      );
    } on DioException catch (e) {
      throw ServerException(e.message ?? "Upload failed");
    }
  }

  @override
  Future<PresignedUrlResponse> getPresignedUrl(
    int size,
    String? mimeType,
    String hash,
    String takenAt,
  ) async {
    final response = await dio.post(
      '/photos/upload-url',
      data: {
        'size': size,
        'mimeType': mimeType,
        'hash': hash,
        'takenAt': takenAt,
      },
    );

    return PresignedUrlResponse.fromJson(response.data);
  }

  // -------------------------------------------------------
  // FETCH SINGLE IMAGE
  // -------------------------------------------------------
  @override
  Future<PhotoModel> fetchImage(String photoID) async {
    try {
      final response = await dio.get(
        "/photos/$photoID/view",
      );

      return PhotoModel.fromJson(response.data);
    } on DioException catch (e) {
      throw ServerException(e.message ?? "Failed to fetch photo");
    }
  }

  // -------------------------------------------------------
  // LOGIN
  // -------------------------------------------------------
  @override
  Future<void> login(String email, String password) async {
    try {
      final response = await dio.post(
        '/auth/login',
        data: {
          'email': email,
          'password': password,
        },
      );

      final accessToken = response.data['accessToken'];
      final refreshToken = response.data['refreshToken'];

      await galleryLocalDataSource.setAccessToken(accessToken);
      await galleryLocalDataSource.setRefreshToken(refreshToken);
    } on DioException catch (e) {
      throw ServerException(e.message ?? "Login failed");
    }
  }

  // -------------------------------------------------------
  // REGISTER
  // -------------------------------------------------------
  @override
  Future<void> register(String email, String password, String name) async {
    try {
      await dio.post(
        '/users',
        data: {
          'email': email,
          'password': password,
          'name': name,
        },
      );
    } on DioException catch (e) {
      throw ServerException(e.message ?? "Registration failed");
    }
  }

  // -------------------------------------------------------
  // LOGOUT
  // -------------------------------------------------------
  @override
  Future<void> logout() async {
    try {
      final refreshToken = await galleryLocalDataSource.getRefreshToken();

      if (refreshToken != null) {
        await dio.post(
          '/auth/logout',
          data: {'refreshToken': refreshToken},
        );
      }
    } catch (_) {
      // ignore error
    } finally {
      await galleryLocalDataSource.clearTokens();
    }
  }
}
