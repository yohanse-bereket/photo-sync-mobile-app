import 'package:equatable/equatable.dart';

class ThumbnailEntity extends Equatable {
  final String id;
  final String thumbnailUrl;
  final DateTime takenAt;

  const ThumbnailEntity({
    required this.id,
    required this.thumbnailUrl,
    required this.takenAt,
  });

  @override
  List<Object?> get props => [id, thumbnailUrl, takenAt];
}
