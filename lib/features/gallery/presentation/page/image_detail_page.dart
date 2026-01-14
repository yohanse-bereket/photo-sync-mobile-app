import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:photo_sync_app/features/gallery/presentation/bloc/photo%20main/image_bloc.dart';

class PhotoDetailsPage extends StatelessWidget {
  final String photoId;

  const PhotoDetailsPage({super.key, required this.photoId});

  @override
  Widget build(BuildContext context) {
    context.read<PhotoMainBloc>().add(FetchImage(photoID: photoId));
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white,),
          onPressed: () => context.pop(),
        ),
      ),
      body: BlocBuilder<PhotoMainBloc, PhotoMainState>(
        builder: (context, state) {
          if (state is! PhotoMainSuccessState) {
            return const Center(child: CircularProgressIndicator());
          }

          final photo = state.photo;
          print(photo.viewURL);
          print("--" * 100);

          return Center(
            child: CachedNetworkImage(
              imageUrl: photo.viewURL,
              fit: BoxFit.contain,
              placeholder: (_, __) => const CircularProgressIndicator(),
              errorWidget: (_, __, ___) =>
                  const Icon(Icons.error, color: Colors.white),
            ),
          );
        },
      ),
    );
  }
}
