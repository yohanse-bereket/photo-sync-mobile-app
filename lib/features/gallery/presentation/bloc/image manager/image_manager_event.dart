part of 'image_manager_bloc.dart';

sealed class ImageManagerEvent extends Equatable {
  const ImageManagerEvent();

  @override
  List<Object> get props => [];
}

// class UpdateSelectedMedias extends ImageManagerEvent {}

class LoadAlbums extends ImageManagerEvent {}

class LoadMedias extends ImageManagerEvent {
  final AssetPathEntity currentAlbum;
  final List<AssetPathEntity> albums;
  const LoadMedias(
      {required this.albums, required this.currentAlbum});
}