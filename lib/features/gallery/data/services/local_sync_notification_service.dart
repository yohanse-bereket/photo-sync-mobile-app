import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:photo_sync_app/features/gallery/domain/services/notification_service.dart';

class LocalSyncNotificationService implements SyncNotificationService {
  static const _channelKey = 'photo_sync';
  static const _notificationId = 1001;

  @override
  Future<void> showSyncStarted() async {
    print('Showing sync started notification');

    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: _notificationId,
        channelKey: _channelKey,
        title: 'Photo Sync',
        body: 'Syncing photos…',
        notificationLayout: NotificationLayout.ProgressBar,
        progress: 0,
        locked: true, // ongoing
        autoDismissible: false,
      ),
    );
  }

  @override
  Future<void> updateProgress({
    required int current,
    required int total,
    required double fileProgress,
  }) async {
    final progressValue = (current + fileProgress);

    print(
      'Updating notification: current=$current, total=$total, '
      'fileProgress=$fileProgress, progressValue=$progressValue',
    );

    if (progressValue >= total) {
      await showSyncCompleted();
      return;
    }

    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: _notificationId,
        channelKey: _channelKey,
        title: 'Photo Sync',
        body: 'Uploading $current of $total photos',
        notificationLayout: NotificationLayout.ProgressBar,
        progress: progressValue,
        locked: true,
        autoDismissible: false,
      ),
    );
  }

  @override
  Future<void> showSyncCompleted() async {
    print('Showing sync completed notification');

    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: _notificationId,
        channelKey: _channelKey,
        title: 'Photo Sync',
        body: 'Sync completed',
        locked: false,
        autoDismissible: true,
      ),
    );
  }
}
