part of 'image_bloc.dart';

sealed class ImageState extends Equatable {
  const ImageState();

  @override
  List<Object> get props => [];
}

final class ImageInitial extends ImageState {}

final class ImageSuccessState extends ImageState {
  final bool? hasMore;
  final String? nextCursor;
  final List<GalleryEntity> galleries;

  const ImageSuccessState({
    required this.galleries,
    this.hasMore,
    this.nextCursor,
  });
}

final class ImageLoadingState extends ImageState {}

final class ImageAddLoadingState extends ImageState {
  final List<GalleryEntity>? galleries;
  final bool? hasMore;
  final String? nextCursor;


  const ImageAddLoadingState({required this.galleries, required this.hasMore, required this.nextCursor});
}

final class ImageErrorState extends ImageState {
  final List<GalleryEntity>? galleries;
  final String? nextCursor;
  final bool? hasMore;
  final String message;

  const ImageErrorState({
    required this.message,
    required this.galleries,
    required this.nextCursor,
    required this.hasMore,
  });
}
