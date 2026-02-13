import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:photo_sync_app/core/error/failure.dart';
import 'package:photo_sync_app/core/usecase/usecase.dart';
import 'package:photo_sync_app/features/gallery/domain/repository/gallery.dart';

class RegisterUsecase extends Usecase<void, RegisterParams> {
  final GalleryRepository repository;

  RegisterUsecase(this.repository);

  @override
  Future<Either<Failure, void>> call(RegisterParams params) {
    return repository.register(params.email, params.password, params.name);
  }
}

class RegisterParams extends Equatable {
  final String email, password, name;
  const RegisterParams(
      {required this.email, required this.password, required this.name});
    
  @override
  List<Object?> get props => [email, password, name];
}
