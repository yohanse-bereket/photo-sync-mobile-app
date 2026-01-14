class PresignedUrlResponse {
  final String url;
  final String photoId;

  PresignedUrlResponse({required this.url, required this.photoId});

  factory PresignedUrlResponse.fromJson(Map<String, dynamic> json) {
    return PresignedUrlResponse(
      url: json['upload_url'],
      photoId: json['photo_id'],
    );
  }
}
