
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'package:photo_sync_app/features/gallery/domain/services/hashing_service.dart';

class Sha256HashingService implements HashingService {
  @override
  Future<String> generateHash(Uint8List image) async {
    return sha256.convert(image).toString();
  }
}
