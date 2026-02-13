part of 'register_bloc.dart';

sealed class RegisterEvent extends Equatable {
  const RegisterEvent();

  @override
  List<Object> get props => [];
}

final class RegisterRequested extends RegisterEvent {
  final String email, password, name;
  const RegisterRequested({required this.email, required this.password, required this.name});
  
  @override
  List<Object> get props => [email, password, name];
}