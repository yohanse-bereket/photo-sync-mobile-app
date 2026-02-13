part of 'logout_bloc.dart';

sealed class LogoutState extends Equatable {
  const LogoutState();
  
  @override
  List<Object> get props => [];
}

final class LogoutInitial extends LogoutState {}

final class LogoutLoadingState extends LogoutState {}

final class LogoutSuccessState extends LogoutState {}

final class LogoutFailureState extends LogoutState {
  final String message;
  const LogoutFailureState(this.message);
  
  @override
  List<Object> get props => [message];
}