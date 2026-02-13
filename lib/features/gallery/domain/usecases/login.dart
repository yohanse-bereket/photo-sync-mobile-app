import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:photo_sync_app/core/error/failure.dart';
import 'package:photo_sync_app/core/usecase/usecase.dart';
import 'package:photo_sync_app/features/gallery/domain/repository/gallery.dart';

class LoginUsecase extends Usecase<void, LoginParams> {
  final GalleryRepository repository;

  LoginUsecase(this.repository);

  @override
  Future<Either<Failure, void>> call(LoginParams params) {
    return repository.login(params.email, params.password);
  }
}

class LoginParams extends Equatable {
  final String email, password;
  const LoginParams(
      {required this.email, required this.password});
    
  @override
  List<Object?> get props => [email, password];
}
