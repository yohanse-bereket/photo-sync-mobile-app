import 'package:shared_preferences/shared_preferences.dart';

abstract class GalleryLocalDataSource {
  SharedPreferences get sharedPreferences;
  Future<DateTime?> getLastSyncTime();
  Future<void> setLastSyncTime(DateTime time);
  Future<void> setAccessToken(String token);
  Future<String?> getAccessToken();
  Future<void> setRefreshToken(String token);
  Future<String?> getRefreshToken();
  Future<void> clearTokens();
}

class GalleryLocalDataSourceImpl implements GalleryLocalDataSource {
  @override
  final SharedPreferences sharedPreferences;
  static const _lastSyncTimeKey = 'last_sync_time';
  static const _accessTokenKey = 'access_token';
  static const _refreshTokenKey = 'refresh_token';

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
  
  @override
  Future<String?> getAccessToken() async {
    final token = sharedPreferences.getString(_accessTokenKey);
    if (token != null) {
      return Future.value(token);
    }
    return Future.value(null);
  }
  
  @override
  Future<String?> getRefreshToken() {
    final token = sharedPreferences.getString(_refreshTokenKey);
    if (token != null) {
      return Future.value(token);
    }
    return Future.value(null);
  }
  
  @override
  Future<void> setAccessToken(String token) async {
    await sharedPreferences.setString(_accessTokenKey, token);
  }
  
  @override
  Future<void> setRefreshToken(String token) async {
    await sharedPreferences.setString(_refreshTokenKey, token);
  }
  
  @override
  Future<void> clearTokens() {
    sharedPreferences.remove(_accessTokenKey);
    sharedPreferences.remove(_refreshTokenKey);
    return Future.value();
  }
}
