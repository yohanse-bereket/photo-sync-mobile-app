import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:photo_sync_app/features/gallery/domain/entities/photo_entity.dart';
import 'package:photo_sync_app/features/gallery/domain/usecases/fetch_image.dart';

part 'image_event.dart';
part 'image_state.dart';

class PhotoMainBloc extends Bloc<PhotoMainEvent, PhotoMainState> {
  final FetchImageUsecase fetchImageUsecase;

  PhotoMainBloc({
    required this.fetchImageUsecase,
  }) : super(PhotoMainInitial()) {
    on<FetchImage>(_fetchImageHandler);
  }

  void _fetchImageHandler(FetchImage event, Emitter<PhotoMainState> emit) async {
    print("Fetching image with ID: ${event.photoID}");
    emit(PhotoMainLoadingState());
    final result = await fetchImageUsecase(FetchImageParams(photoID: event.photoID));
    result.fold(
      (failure) {
        print("Error fetching image: ${failure.message}");
        emit(PhotoMainErrorState(message: "Failed to load image"));
      },
      (photo) {
        print("Image fetched successfully: ${photo.viewURL}");
        emit(PhotoMainSuccessState(photo: photo));
      },
    );
  }
}
