import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:photo_sync_app/features/gallery/domain/usecases/register.dart';

part 'register_event.dart';
part 'register_state.dart';

class RegisterBloc extends Bloc<RegisterEvent, RegisterState> {
  final RegisterUsecase registerUsecase;
  RegisterBloc({
    required this.registerUsecase
  }) : super(RegisterInitial()) {
    on<RegisterRequested>(_registerRequestedHandler);
  }

  void _registerRequestedHandler(RegisterRequested event, Emitter<RegisterState> emit) async {
    emit(RegisterLoadingState());
    final result = await registerUsecase(RegisterParams(email: event.email, password: event.password, name: event.name));
    result.fold(
      (failure) => emit(RegisterFailureState(failure.message)),
      (success) => emit(RegisterSuccessState()),
    );
  }
}
