part of 'image_bloc.dart';

sealed class ImageEvent extends Equatable {
  const ImageEvent();

  @override
  List<Object> get props => [];
}


class FetchImages extends ImageEvent {
  final String? cursor;

  const FetchImages({required this.cursor});
}

class UploadImage extends ImageEvent {
  final AssetEntity image;

  const UploadImage({required this.image});

  @override
  List<Object> get props => [image];
}