import 'dart:typed_data';

abstract class HashingService {
  Future<String> generateHash(Uint8List image);
}
