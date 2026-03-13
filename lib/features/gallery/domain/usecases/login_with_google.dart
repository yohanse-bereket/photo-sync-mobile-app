import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:photo_sync_app/core/error/failure.dart';
import 'package:photo_sync_app/core/usecase/usecase.dart';
import 'package:photo_sync_app/features/gallery/domain/repository/gallery.dart';

class LoginWithGoogleUsecase extends Usecase<void, LoginWithGoogleParams> {
  final GalleryRepository repository;

  LoginWithGoogleUsecase(this.repository);

  @override
  Future<Either<Failure, void>> call(LoginWithGoogleParams params) {
    return repository.loginWithGoogle(params.idToken);
  }
}

class LoginWithGoogleParams extends Equatable {
  final String idToken;
  const LoginWithGoogleParams(
      {required this.idToken});
    
  @override
  List<Object?> get props => [idToken];
}
