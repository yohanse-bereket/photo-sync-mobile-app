import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:photo_sync_app/core/error/failure.dart';
import 'package:photo_sync_app/core/usecase/usecase.dart';
import 'package:photo_sync_app/features/gallery/domain/repository/gallery.dart';

class LogoutUsecase extends Usecase<void, LogoutParams> {
  final GalleryRepository repository;

  LogoutUsecase(this.repository);

  @override
  Future<Either<Failure, void>> call(LogoutParams params) {
    return repository.logout();
  }
}

class LogoutParams extends Equatable {
  const LogoutParams();
    
  @override
  List<Object?> get props => [];
}
