import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:photo_sync_app/core/error/failure.dart';
import 'package:photo_sync_app/core/response/page_result.dart';
import 'package:photo_sync_app/core/usecase/usecase.dart';
import 'package:photo_sync_app/features/gallery/domain/entities/thumbnail_entity.dart';
import 'package:photo_sync_app/features/gallery/domain/repository/gallery.dart';

class FetchImagesUsecase extends Usecase<PagedResult<List<ThumbnailEntity>>, FetchImagesParams> {
  final GalleryRepository repository;

  FetchImagesUsecase(this.repository);

  @override
  Future<Either<Failure, PagedResult<List<ThumbnailEntity>>>> call(FetchImagesParams params) {
    return repository.fetchImages(params.nextCursor);
  }
}

class FetchImagesParams extends Equatable {
  final String? nextCursor;
  const FetchImagesParams({required this.nextCursor});

  @override
  List<Object?> get props => [nextCursor];
}