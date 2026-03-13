part of 'login_bloc.dart';

sealed class LoginEvent extends Equatable {
  const LoginEvent();

  @override
  List<Object> get props => [];
}

final class LoginRequested extends LoginEvent {
  final String email;
  final String password;

  const LoginRequested({required this.email, required this.password});

  @override
  List<Object> get props => [email, password];
}

final class LoginWithGoogleRequested extends LoginEvent {
  final String idToken;

  const LoginWithGoogleRequested({required this.idToken});

  @override
  List<Object> get props => [idToken];
}
