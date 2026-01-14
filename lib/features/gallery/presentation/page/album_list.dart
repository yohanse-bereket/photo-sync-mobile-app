import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:photo_sync_app/features/gallery/presentation/bloc/image%20manager/image_manager_bloc.dart';

class AlbumListPage extends StatelessWidget {
  const AlbumListPage({super.key});

  @override
  Widget build(BuildContext context) {
    context.read<ImageManagerBloc>().add(LoadAlbums());

    return Scaffold(
      appBar: AppBar(
        title: const Text("Albums"),
      ),
      body: BlocBuilder<ImageManagerBloc, ImageManagerState>(
        builder: (context, state) {
          if (state is ImageManagerLoadingState ||
              state is ImageManagerInitial) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is ImageManagerSuccessState) {
            final albums = state.albums;

            if (albums.isEmpty) {
              return const Center(child: Text("No Albums Found"));
            }

            return ListView.builder(
              itemCount: albums.length,
              itemBuilder: (_, index) {
                final album = albums[index];
                return ListTile(
                  title: Text(album.name),
                  subtitle: Text("items"),
                  onTap: () {
                    context.push('/images', extra: album);
                  },
                );
              },
            );
          }

          return const Center(child: Text("Failed to load albums"));
        },
      ),
    );
  }
}
