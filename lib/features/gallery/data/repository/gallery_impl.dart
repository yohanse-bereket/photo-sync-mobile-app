import 'package:dartz/dartz.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:photo_sync_app/core/error/failure.dart';
import 'package:photo_sync_app/core/network/network.dart';
import 'package:photo_sync_app/core/response/page_result.dart';
import 'package:photo_sync_app/features/gallery/data/datasource/local_datasource.dart';
import 'package:photo_sync_app/features/gallery/data/datasource/remote_datasource.dart';
import 'package:photo_sync_app/features/gallery/data/models/thumbnail_model.dart';
import 'package:photo_sync_app/features/gallery/domain/entities/photo_entity.dart';
import 'package:photo_sync_app/features/gallery/domain/entities/thumbnail_entity.dart';
import 'package:photo_sync_app/features/gallery/domain/repository/gallery.dart';

class GalleryRepositoryImpl implements GalleryRepository {
  final GalleryRemoteDataSource galleryRemoteDataSource;
  final GalleryLocalDataSource galleryLocalDataSource;
  final NetworkInfo networkInfo;

  GalleryRepositoryImpl({
    required this.galleryRemoteDataSource,
    required this.networkInfo,
    required this.galleryLocalDataSource,
  });

  @override
  Future<Either<Failure, PagedResult<List<ThumbnailEntity>>>> fetchImages(String? nextCursor) async {
    if (await networkInfo.isConnected) {
      try {
        final ans = await galleryRemoteDataSource.fetchImages(nextCursor);
        return Right(ans);
      } catch (e) {
        return const Left(ServerFailure("Server not working properly."));
      }
    } else {
      return const Left(ServerFailure("Netwrok error."));
    }
  }

  @override
  Future<Either<Failure, void>> uploadImage(AssetEntity image, void Function(double progress) onProgress) async {
    print("Inside repository upload image");
    if (await networkInfo.isConnected) {
      try {
        print("Before calling remote data source upload image");
        final ans = await galleryRemoteDataSource.uploadImage(image, onProgress);
        print("After calling remote data source upload image");
        return Right(ans);
      } catch (e) {
        print(e);
      rethrow;
      }
    } else {
      return const Left(ServerFailure("Netwrok error."));
    }
  }


@override
  Future<List<AssetEntity>> getNewImages() async {
    final lastSyncTime = await galleryLocalDataSource.getLastSyncTime();

    // test purpose
    DateTime now = DateTime.now();
    DateTime twoHoursBefore = now.subtract(Duration(hours: 4));
    // 2. Define the Date Filter: Only assets created AFTER the last sync time
    final filter = FilterOptionGroup(
      createTimeCond: DateTimeCond(
        min: twoHoursBefore,
        max: DateTime.now(),
      ),
      orders: [const OrderOption(type: OrderOptionType.createDate, asc: true)],
    );

    // 3. Get the list of asset paths, ensuring the 'All Photos' path is included
    final pathList = await PhotoManager.getAssetPathList(
      type: RequestType.image,
      filterOption: filter,
      hasAll: true,
    );
    print(pathList.length);

    // 4. Find the main 'All Photos' path entity
    final AssetPathEntity allPhotosPath;
    try {
      allPhotosPath = pathList.firstWhere(
        (path) => path.isAll,
        orElse: () {
          print("3" * 70);
          throw Exception("No 'All Photos' directory found.");
        },
      );
    } catch (e) {
      print("4" * 70);
      return throw Exception("No 'All Photos' directory found.");
    }

    // 5. Fetch the new assets that match the time filter
    final newAssets = await allPhotosPath.getAssetListPaged(
      page: 0,
      size: await allPhotosPath.assetCountAsync,
    );

    return newAssets;
  }


  @override
  Future<Either<Failure, PhotoEntity>> fetchImage(String photoID) async {
    if (await networkInfo.isConnected) {
      try {
        final ans = await galleryRemoteDataSource.fetchImage(photoID);
        return Right(ans);
      } catch (e) {
        return const Left(ServerFailure("Server not working properly."));
      }
    } else {
      return const Left(ServerFailure("Netwrok error."));
    }
  }

}
