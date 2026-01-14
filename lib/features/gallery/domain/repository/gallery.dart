import 'package:dartz/dartz.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:photo_sync_app/core/error/failure.dart';
import 'package:photo_sync_app/core/response/page_result.dart';
import 'package:photo_sync_app/features/gallery/domain/entities/photo_entity.dart';
import 'package:photo_sync_app/features/gallery/domain/entities/thumbnail_entity.dart';

abstract class GalleryRepository {
  Future<Either<Failure, PagedResult<List<ThumbnailEntity>>>> fetchImages(String? nextCursor);
  Future<Either<Failure, void>> uploadImage(AssetEntity image, void Function(double progress) onProgress);
  Future<List<AssetEntity>> getNewImages();
  Future<Either<Failure, PhotoEntity>> fetchImage(String photoID);
}