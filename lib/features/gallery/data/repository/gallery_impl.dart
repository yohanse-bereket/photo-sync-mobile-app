import 'package:dartz/dartz.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:photo_sync_app/core/error/failure.dart';
import 'package:photo_sync_app/core/network/network.dart';
import 'package:photo_sync_app/core/response/page_result.dart';
import 'package:photo_sync_app/features/gallery/data/datasource/local_datasource.dart';
import 'package:photo_sync_app/features/gallery/data/datasource/remote_datasource.dart';
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
  Future<Either<Failure, PagedResult<List<ThumbnailEntity>>>> fetchImages(
    String? nextCursor,
  ) async {
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
  Future<Either<Failure, void>> uploadImage(
    AssetEntity image,
    void Function(double progress) onProgress,
  ) async {
    print("Inside repository upload image");
    if (await networkInfo.isConnected) {
      try {
        print("Before calling remote data source upload image");
        final ans = await galleryRemoteDataSource.uploadImage(
          image,
          onProgress,
        );
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
    final filter = FilterOptionGroup(
      orders: [const OrderOption(type: OrderOptionType.createDate, asc: false)],
    );

    // 1. Get all asset paths of type image
    final pathList = await PhotoManager.getAssetPathList(
      type: RequestType.image,
      hasAll: true,
      filterOption: filter,
    );

    if (pathList.isEmpty) {
      throw Exception("No image paths found");
    }

    // 2. Find the main 'All Photos' path
    final AssetPathEntity allPhotosPath = pathList.firstWhere(
      (path) => path.isAll,
      orElse: () => throw Exception("No 'All Photos' directory found."),
    );

    // 3. Fetch the most recent 30 assets
    // Order by creation date descending (newest first)

    final recentAssets = await allPhotosPath.getAssetListRange(
      start: 0,
      end: 30,
    );

    return recentAssets;
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

  @override
  Future<Either<Failure, void>> login(String email, String password) async {
    if (await networkInfo.isConnected) {
      try {
        final ans = galleryRemoteDataSource.login(email, password);
        return Right(ans);
      } catch (e) {
        return const Left(ServerFailure("Server not working properly."));
      }
    } else {
      return const Left(ServerFailure("Netwrok error."));
    }
  }

  @override
  Future<Either<Failure, void>> register(
    String email,
    String password,
    String name,
  ) async {
    if (await networkInfo.isConnected) {
      try {
        final ans = galleryRemoteDataSource.register(email, password, name);
        return Right(ans);
      } catch (e) {
        return const Left(ServerFailure("Server not working properly."));
      }
    } else {
      return const Left(ServerFailure("Netwrok error."));
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    if (await networkInfo.isConnected) {
      try {
        final ans = galleryRemoteDataSource.logout();
        return Right(ans);
      } catch (e) {
        return const Left(ServerFailure("Server not working properly."));
      }
    } else {
      return const Left(ServerFailure("Netwrok error."));
    }
  }
}
