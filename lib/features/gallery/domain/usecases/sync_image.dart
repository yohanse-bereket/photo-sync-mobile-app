import 'package:photo_sync_app/features/gallery/domain/repository/gallery.dart';
import 'package:photo_sync_app/features/gallery/domain/services/notification_service.dart';

class SyncImageUsecase {
  final GalleryRepository repository;
  final SyncNotificationService notificationService;

  SyncImageUsecase({required this.repository, required this.notificationService});

  Future<void> execute() async {
    try {
      final newAssets = await repository.getNewImages();
      print("2" * 70);
      print('Number of new assets to sync: ${newAssets.length}');
      notificationService.showSyncStarted();
      int completed = 0;
      for (final asset in newAssets) {
        print('New asset to sync: ${asset.id}, ${asset.title}');
        final file = await asset.file;
        if (file == null) {
          print('Failed to get file for asset: ${asset.id}');
        } else {
          print('Got file for asset: ${asset.id}, path: ${file.path}');

          final result = await repository.uploadImage(
            asset,
            (progress) {
              notificationService.updateProgress(
                current: completed,
                total: newAssets.length,
                fileProgress: progress,
              );
            }
          );
          result.fold(
            (failure) => print(
              'Failed to upload image: ${file.path}, error: ${failure}',
            ),
            (_) {
              print('Successfully uploaded image: ${file.path}');
              completed += 1;},
          );
        }
      }
      notificationService.showSyncCompleted();
    } catch (e) {
      print('Error during sync: $e');
    }
  }
}
