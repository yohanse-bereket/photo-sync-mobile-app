import 'package:equatable/equatable.dart';
import 'package:photo_sync_app/features/gallery/domain/entities/thumbnail_entity.dart';

class GalleryEntity extends Equatable {
  final List<ThumbnailEntity> photos;
  final DateTime takenAtDay;

  const GalleryEntity({
    required this.photos,
    required this.takenAtDay,
  });

  @override
  List<Object?> get props => [photos, takenAtDay];
}