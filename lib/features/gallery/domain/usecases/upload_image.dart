import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:photo_sync_app/core/error/failure.dart';
import 'package:photo_sync_app/core/usecase/usecase.dart';
import 'package:photo_sync_app/features/gallery/domain/repository/gallery.dart';

class UploadImageUsecase extends Usecase<void, UploadImageParams> {
  final GalleryRepository repository;

  UploadImageUsecase(this.repository);

  @override
  Future<Either<Failure, void>> call(UploadImageParams params) {
    return repository.uploadImage(params.image, params.onProgress);
  }
}

class UploadImageParams extends Equatable {
  final AssetEntity image;
  final void Function(double progress) onProgress;
  const UploadImageParams(
    {
      required this.image,
      required this.onProgress,
    }
  );

  @override
  List<Object?> get props => [image, onProgress];
}