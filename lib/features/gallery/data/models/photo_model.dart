import 'package:photo_sync_app/features/gallery/domain/entities/photo_entity.dart';


class PhotoModel extends PhotoEntity {
  const PhotoModel({
    required super.id,
    required super.takenAt,
    required super.viewURL,
    required super.fileSize,
    required super.mimeType,
  });

  factory PhotoModel.fromJson(Map<String, dynamic> json) {
    return PhotoModel(
      id: json['photo_id'],
      viewURL: json['view_url'],
      fileSize: (json['file_size'] as num).toDouble(),
      takenAt: json['taken_at'] != null? DateTime.parse(json['taken_at']): DateTime.now(),
      mimeType: json['mime_type'],
    );
  }
}
