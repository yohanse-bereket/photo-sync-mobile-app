import 'package:shared_preferences/shared_preferences.dart';

abstract class GalleryLocalDataSource {
  SharedPreferences get sharedPreferences;
  Future<DateTime?> getLastSyncTime();
  Future<void> setLastSyncTime(DateTime time);
}

class GalleryLocalDataSourceImpl implements GalleryLocalDataSource {
  @override
  final SharedPreferences sharedPreferences;
  static const _lastSyncTimeKey = 'last_sync_time';

  GalleryLocalDataSourceImpl({required this.sharedPreferences});

  @override
  Future<DateTime?> getLastSyncTime() async {
    final millis = sharedPreferences.getInt(_lastSyncTimeKey);
    if (millis != null) {
      return Future.value(DateTime.fromMillisecondsSinceEpoch(millis).toUtc());
    }
    return Future.value(null);
  }

  @override
  Future<void> setLastSyncTime(DateTime time) async {
    await sharedPreferences.setInt(
      _lastSyncTimeKey,
      time.millisecondsSinceEpoch,
    );
  }
}
