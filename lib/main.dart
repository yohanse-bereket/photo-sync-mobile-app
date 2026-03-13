import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:photo_sync_app/features/gallery/data/datasource/local_datasource.dart';
import 'package:photo_sync_app/features/gallery/domain/usecases/sync_image.dart';
import 'package:photo_sync_app/injection.dart';
import 'package:photo_sync_app/photo_sync.dart';
import 'package:workmanager/workmanager.dart';
import 'injection.dart' as di;

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    WidgetsFlutterBinding.ensureInitialized();
    await di.init();
    AwesomeNotifications().initialize('resource://drawable/ic_notification', [
      NotificationChannel(
        channelKey: 'photo_sync',
        channelName: 'Photo Sync',
        channelDescription: 'Photo upload progress',
        importance: NotificationImportance.Low,
        channelShowBadge: false,
        defaultColor: Colors.blue,
      ),
    ]);

    // Check login before doing anything
    final localDataSource = sl<GalleryLocalDataSource>();
    final accessToken = await localDataSource.getAccessToken();
    if (accessToken == null || accessToken.isEmpty) {
      print("User is not logged in — skipping background sync");
      return Future.value(true); // task completes without doing anything
    }

    print("1" * 70);
    print("Background task triggered: $task");
    if (task == "photoSyncTask") {
      print("Starting background photo sync task");
      try {
        // Retrieve the registered Use Case instance from the service locator
        final syncUseCase = sl<SyncImageUsecase>();

        // Execute the use case logic
        await syncUseCase.execute();
        print("Sync successful");
        // Return true to signal success (Workmanager stops retrying)
        return Future.value(true);
      } catch (e) {
        // If any exception occurs (including the SyncFailureException you threw),
        // return false to tell Workmanager to retry the task later.
        print("Background Sync Failed: $e");
        return Future.value(true);
      }
    }
    return Future.value(true);
  });
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await di.init();
  Workmanager().initialize(callbackDispatcher);
  Workmanager().registerPeriodicTask(
    "photoSyncTaskPeriodic", // unique name for the task
    "photoSyncTask",         // task name as defined in callbackDispatcher
    frequency: const Duration(hours: 4), // runs every 4 hours
    initialDelay: const Duration(minutes: 5), // optional: delay before first run
    constraints: Constraints(
      networkType: NetworkType.connected, // only run if network is available
      requiresBatteryNotLow: true,        // optional: skip if battery is low
    ),
    backoffPolicy: BackoffPolicy.linear, // retry strategy
    backoffPolicyDelay: const Duration(minutes: 15), // retry delay
  );
  runApp(const MaterialApp(home: PhotoSyncApp()));
}
