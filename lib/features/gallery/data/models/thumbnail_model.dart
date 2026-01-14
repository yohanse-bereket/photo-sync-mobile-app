import 'package:photo_sync_app/features/gallery/domain/entities/thumbnail_entity.dart';


class ThumbnailModel extends ThumbnailEntity {
  const ThumbnailModel({
    required super.id,
    required super.thumbnailUrl,
    required super.takenAt
  });

  factory ThumbnailModel.fromJson(Map<String, dynamic> json) {
    return ThumbnailModel(
      id: json['id'],
      thumbnailUrl: json['thumbnail_url'],
      takenAt: DateTime.parse(json['takenAt']),
    );
  }
}
