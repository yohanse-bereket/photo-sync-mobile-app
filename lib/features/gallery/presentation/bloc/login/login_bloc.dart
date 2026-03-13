import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:photo_sync_app/features/gallery/domain/usecases/login.dart';
import 'package:photo_sync_app/features/gallery/domain/usecases/login_with_google.dart';

part 'login_event.dart';
part 'login_state.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final LoginUsecase loginUsecase;
  final LoginWithGoogleUsecase loginWithGoogleUsecase;
  LoginBloc({required this.loginUsecase, required this.loginWithGoogleUsecase}) : super(LoginInitial()) {
    on<LoginRequested>(_loginHandler);
    on<LoginWithGoogleRequested>(_loginWithGoogleHandler);
  }

  _loginHandler(LoginRequested event, Emitter<LoginState> emit) async {
    emit(LoginLoadingState());
    final result = await loginUsecase(
      LoginParams(email: event.email, password: event.password),
    );
    result.fold(
      (failure) => emit(LoginFailureState(failure.message)),
      (success) => emit(LoginSuccessState()),
    );
  }

  _loginWithGoogleHandler(
    LoginWithGoogleRequested event,
    Emitter<LoginState> emit,
  ) async {
    emit(LoginLoadingState());
    final result = await loginWithGoogleUsecase(LoginWithGoogleParams(idToken: event.idToken));
    result.fold(
      (failure) => emit(LoginFailureState(failure.message)),
      (success) => emit(LoginSuccessState()),
    );
  }
}
