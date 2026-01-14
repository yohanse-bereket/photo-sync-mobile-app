part of 'image_bloc.dart';

sealed class PhotoMainState extends Equatable {
  const PhotoMainState();

  @override
  List<Object> get props => [];
}

final class PhotoMainInitial extends PhotoMainState {}

final class PhotoMainSuccessState extends PhotoMainState {
  final PhotoEntity photo;

  const PhotoMainSuccessState({required this.photo});
}

final class PhotoMainLoadingState extends PhotoMainState {}

final class PhotoMainErrorState extends PhotoMainState {
  final String message;

  const PhotoMainErrorState({required this.message});

  @override
  List<Object> get props => [message];
}
