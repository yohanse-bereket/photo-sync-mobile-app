part of 'image_manager_bloc.dart';

sealed class ImageManagerState extends Equatable {
  const ImageManagerState();

  @override
  List<Object> get props => [];
}

final class ImageManagerInitial extends ImageManagerState {}

class ImageManagerSuccessState extends ImageManagerState {
  final AssetPathEntity? currentAlbum;
  final List<AssetPathEntity> albums;
  final List<AssetEntity> medias;

  const ImageManagerSuccessState({
    required this.currentAlbum,
    required this.albums,
    required this.medias,
  });
}

class ImageManagerLoadingState extends ImageManagerState {}

class ImageManagerErrorState extends ImageManagerState {
  final String message;

  const ImageManagerErrorState({required this.message});
}
