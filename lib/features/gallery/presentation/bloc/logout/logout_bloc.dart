import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:photo_sync_app/features/gallery/domain/usecases/logout.dart';

part 'logout_event.dart';
part 'logout_state.dart';

class LogoutBloc extends Bloc<LogoutEvent, LogoutState> {
  final LogoutUsecase logoutUsecase;
  LogoutBloc({required this.logoutUsecase}) : super(LogoutInitial()) {
    on<LogoutEvent>(_logoutHandler);
  }
  _logoutHandler(LogoutEvent event, Emitter<LogoutState> emit) async {
    if (event is LogoutRequested) {
      emit(LogoutLoadingState());
      final result = await logoutUsecase(LogoutParams());
      result.fold(
        (failure) => emit(LogoutFailureState(failure.message)),
        (success) {
          emit(LogoutSuccessState());
          
        },
      );
    }
  }
}
