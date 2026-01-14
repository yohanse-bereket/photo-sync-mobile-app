import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:photo_sync_app/features/gallery/domain/entities/gallery_entity.dart';
import 'package:photo_sync_app/features/gallery/domain/entities/thumbnail_entity.dart';
import 'package:photo_sync_app/features/gallery/domain/usecases/fetch_images.dart';
import 'package:photo_sync_app/features/gallery/domain/usecases/upload_image.dart';

part 'image_event.dart';
part 'image_state.dart';

class ImageBloc extends Bloc<ImageEvent, ImageState> {
  final FetchImagesUsecase fetchImagesUsecase;
  final UploadImageUsecase uploadImageUsecase;

  ImageBloc({
    required this.fetchImagesUsecase,
    required this.uploadImageUsecase,
  }) : super(ImageInitial()) {
    // on<UploadImage>(_uploadImageHandler);
    on<FetchImages>(_fetchImagesHandler);
  }

  void _fetchImagesHandler(FetchImages event, Emitter<ImageState> emit) async {
    bool _isSameDay(DateTime a, DateTime b) {
      return a.year == b.year && a.month == b.month && a.day == b.day;
    }

    if (state is ImageLoadingState || state is ImageAddLoadingState) return;

    List<GalleryEntity> previousGalleries = [];
    String? nextCursor;
    bool? hasMore;

    if (state is ImageSuccessState) {
      previousGalleries = (state as ImageSuccessState).galleries;
      nextCursor = (state as ImageSuccessState).nextCursor;
      hasMore = (state as ImageSuccessState).hasMore;
    }

    if (state is ImageErrorState) {
      if ((state as ImageErrorState).galleries != null) {
        previousGalleries = (state as ImageErrorState).galleries!;
      }
      nextCursor = (state as ImageErrorState).nextCursor;
      hasMore = (state as ImageErrorState).hasMore;
    }

    if (hasMore == false) {
      print(
        'No More images to load but triggered ----------------------------------------------------',
      );
      print(DateTime.now());
      print("*" * 100);
      return;
    }

    if (previousGalleries.isEmpty) {
      emit(ImageLoadingState());
    } else {
      emit(
        ImageAddLoadingState(
          galleries: previousGalleries,
          hasMore: hasMore,
          nextCursor: nextCursor,
        ),
      );
    }

    print(hasMore);
    print("Fetching images with cursor: $nextCursor");
    final result = await fetchImagesUsecase(
      FetchImagesParams(nextCursor: nextCursor),
    );

    result.fold(
      (failure) {
        emit(
          ImageErrorState(
            message: failure.message,
            galleries: previousGalleries,
            nextCursor: nextCursor,
            hasMore: hasMore,
          ),
        );
      },
      (pagedResult) {
        final List<ThumbnailEntity> newPhotos = pagedResult.items;
        for (ThumbnailEntity photo in newPhotos) {
          if (previousGalleries.isEmpty) {
            previousGalleries.add(
              GalleryEntity(takenAtDay: photo.takenAt, photos: [photo]),
            );
          } else {
            if (_isSameDay(previousGalleries.last.takenAtDay, photo.takenAt)) {
              previousGalleries.last.photos.add(photo);
            } else {
              previousGalleries.add(
                GalleryEntity(takenAtDay: photo.takenAt, photos: [photo]),
              );
            }
          }
        }

        emit(
          ImageSuccessState(
            galleries: previousGalleries,
            hasMore: pagedResult.hasMore,
            nextCursor: pagedResult.nextCursor,
          ),
        );
      },
    );
  }
}
