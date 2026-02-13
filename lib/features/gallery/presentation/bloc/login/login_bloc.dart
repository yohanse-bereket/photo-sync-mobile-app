import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:photo_sync_app/features/gallery/domain/usecases/login.dart';

part 'login_event.dart';
part 'login_state.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final LoginUsecase loginUsecase;
  LoginBloc({required this.loginUsecase}) : super(LoginInitial()) {
    on<LoginEvent>(_loginHandler);
  }

  _loginHandler(LoginEvent event, Emitter<LoginState> emit) async {
    if (event is LoginRequested) {
      emit(LoginLoadingState());
      final result = await loginUsecase(LoginParams(email: event.email, password: event.password));
      result.fold(
        (failure) => emit(LoginFailureState(failure.message)),
        (success) => emit(LoginSuccessState()),
      );
    }
  }
}
