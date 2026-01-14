abstract class SyncNotificationService {
  void showSyncStarted();
  void updateProgress({
    required int current,
    required int total,
    required double fileProgress,
  });
  void showSyncCompleted();
}
