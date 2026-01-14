import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:photo_sync_app/core/error/failure.dart';
import 'package:photo_sync_app/core/usecase/usecase.dart';
import 'package:photo_sync_app/features/gallery/domain/entities/photo_entity.dart';
import 'package:photo_sync_app/features/gallery/domain/repository/gallery.dart';

class FetchImageUsecase extends Usecase<PhotoEntity, FetchImageParams> {
  final GalleryRepository repository;

  FetchImageUsecase(this.repository);

  @override
  Future<Either<Failure, PhotoEntity>> call(FetchImageParams params) {
    return repository.fetchImage(params.photoID);
  }
}

class FetchImageParams extends Equatable {
  final String photoID;
  const FetchImageParams({required this.photoID});

  @override
  List<Object?> get props => [photoID];
}