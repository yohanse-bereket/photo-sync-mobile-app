part of 'image_bloc.dart';

sealed class PhotoMainEvent extends Equatable {
  const PhotoMainEvent();

  @override
  List<Object> get props => [];
}


class FetchImage extends PhotoMainEvent {
  final String photoID;

  const FetchImage({required this.photoID});
}