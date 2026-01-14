import 'package:equatable/equatable.dart';

class PhotoEntity extends Equatable {
  final String id;
  final String viewURL;
  final double fileSize;
  final DateTime takenAt;
  final String mimeType;

  const PhotoEntity({
    required this.id,
    required this.viewURL,
    required this.fileSize,
    required this.takenAt,
    required this.mimeType,
  });

  @override
  List<Object?> get props => [id, viewURL, fileSize, takenAt, mimeType];
}
