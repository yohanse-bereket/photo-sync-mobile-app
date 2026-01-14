import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:photo_sync_app/features/gallery/presentation/bloc/image%20manager/image_manager_bloc.dart';


class ImageListPage extends StatelessWidget {
  final AssetPathEntity album;

  const ImageListPage({super.key, required this.album});

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<ImageManagerBloc>();

    bloc.add(LoadMedias(
      currentAlbum: album,
      albums: const [], // albums not needed here
    ));

    return Scaffold(
      appBar: AppBar(
        title: Text(album.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            onPressed: () => context.pop(),
          ),
        ],
      ),
      body: BlocBuilder<ImageManagerBloc, ImageManagerState>(
        builder: (context, state) {
          if (state is ImageManagerLoadingState) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is ImageManagerSuccessState) {
            final medias = state.medias;

            if (medias.isEmpty) {
              return const Center(child: Text("No Media Found"));
            }

            return GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
              ),
              itemCount: medias.length,
              itemBuilder: (_, index) {
                final media = medias[index];

                return FutureBuilder<Uint8List?>(
                  future: media.thumbnailData,
                  builder: (_, snapshot) {
                    if (!snapshot.hasData) {
                      return Container(color: Colors.grey.shade300);
                    }

                    return Image.memory(
                      snapshot.data!,
                      fit: BoxFit.cover,
                    );
                  },
                );
              },
            );
          }

          return const Center(child: Text("Error loading media"));
        },
      ),
    );
  }
}
