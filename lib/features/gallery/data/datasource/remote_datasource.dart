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
    String userId,
    int size,
    String? mimeType,
    String hash,
    String takenAt,
  );
  Future<PhotoModel> fetchImage(String photoID);
}

class GalleryRemoteDataSourceImpl implements GalleryRemoteDataSource {
  final String baseUrl = "http://192.168.43.57:9090/api";
  final String staticUrl = "http://192.168.43.57:9090";
  final String userId = "baf499f4-09b6-45b7-88d5-2b556fa2ebc9";

  @override
  final GalleryLocalDataSource galleryLocalDataSource;
  final Dio dio;
  final HashingService hashingService;

  GalleryRemoteDataSourceImpl({
    required this.galleryLocalDataSource,
    required this.dio,
    required this.hashingService,
  });

  @override
  Future<PagedResult<List<ThumbnailModel>>> fetchImages(
    String? nextCursor,
  ) async {
    print(
      "GalleryRemoteDataSourceImpl: fetchImages called with nextCursor: $nextCursor",
    );
    try {
      String url = "$baseUrl/photos?userId=$userId";
      if (nextCursor != null) {
        url = "$baseUrl/photos?userId=$userId&cursor=$nextCursor";
      }
      print("Fetching images from URL: $url");
      final response = await dio.get(url);
      print("Response status code: ${response.statusCode}");
      if (response.statusCode == 200) {
        final responseData = response.data;
        print("Response data received: $responseData");

        final List<Map<String, dynamic>> data = List<Map<String, dynamic>>.from(
          responseData['data'],
        );
        print("Response data: $data");

        final List<ThumbnailModel> photos = data
            .map((photoJson) => ThumbnailModel.fromJson(photoJson))
            .toList();
        print("Fetched ${photos.length} photos from remote data source.");

        return PagedResult<List<ThumbnailModel>>(
          items: photos,
          hasMore: responseData['hasMore'],
          nextCursor: responseData['nextCursor'],
        );
      } else {
        throw ServerException('Failed to fetch photos: ${response.statusCode}');
      }
    } on DioException catch (e) {
      print("DioException occurred: ${e.message}");
      throw ServerException('DioError: ${e.message}');
    }
  }

  @override
  Future<void> uploadImage(
    AssetEntity image,
    void Function(double progress) onProgress,
  ) async {
    final data = await image.file.then((file) => file!.readAsBytes());
    final size = data.lengthInBytes;
    final takenAtDate = image.createDateTime;
    final takenAt = takenAtDate.toUtc().toIso8601String();

    String hash = await hashingService.generateHash(data);
    try {
      print('Requesting presigned URL for image upload...');

      final PresignedUrlResponse presignedUrlResponse = await getPresignedUrl(
        userId,
        size,
        image.mimeType,
        hash,
        takenAt,
      );

      print('Uploading image to URL: ${presignedUrlResponse.url}');
      if (presignedUrlResponse.url.isEmpty) {
        print("Presigned URL is empty, and the image is already uploaded.");
        return;
      }

      await dio.put(
        presignedUrlResponse.url,
        data: data,
        onSendProgress: (sent, total) {
          onProgress(sent / total);
          print('Upload progress: ${(sent / total * 100).toStringAsFixed(2)}%');
        },
      );
      print('Image upload completed successfully.');
      print("photoId: ${presignedUrlResponse.photoId}");
      print("Confirming upload for photoId: ${presignedUrlResponse.photoId}");
      await dio.post('$baseUrl/photos/${presignedUrlResponse.photoId}/confirm');
    } on DioException catch (_) {
      rethrow;
    }
  }

  @override
  Future<PresignedUrlResponse> getPresignedUrl(
    String userId,
    int size,
    String? mimeType,
    String hash,
    String takenAt,
  ) async {
    final response = await dio.post(
      '$baseUrl/photos/upload-url',
      options: Options(headers: {'Content-Type': 'application/json'}),
      data: jsonEncode({
        'userId': userId,
        'size': size,
        'mimeType': mimeType,
        'hash': hash,
        'takenAt': takenAt,
      }),
    );

    return PresignedUrlResponse.fromJson(response.data);
  }

  @override
  Future<PhotoModel> fetchImage(String photoID) async {
    print(
      "GalleryRemoteDataSourceImpl: fetchImages called with nextCursor: $photoID",
    );
    try {
      String url = "$baseUrl/photos/$photoID/view";
      print("Fetching images from URL: $url");
      final response = await dio.get(url);
      print("Response status code: ${response.statusCode}");
      if (response.statusCode == 200) {
        final responseData = response.data;
        print("Response data received: $responseData");

        final PhotoModel photo = PhotoModel.fromJson(responseData);
        print("Fetched photo from remote data source: ${photo.id}");
        return photo;
      } else {
        throw ServerException('Failed to fetch photos: ${response.statusCode}');
      }
    } on DioException catch (e) {
      print("DioException occurred: ${e.message}");
      throw ServerException('DioError: ${e.message}');
    }
  }
}
