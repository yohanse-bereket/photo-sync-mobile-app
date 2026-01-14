import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:photo_sync_app/features/gallery/domain/entities/gallery_entity.dart';
import 'package:photo_sync_app/features/gallery/presentation/bloc/image/image_bloc.dart';

class ImagesPage extends StatefulWidget {
  const ImagesPage({super.key});

  @override
  State<ImagesPage> createState() => _ImagesPageState();
}

class _ImagesPageState extends State<ImagesPage> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ImageBloc>().add(FetchImages(cursor: null));
    });

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        context.read<ImageBloc>().add(FetchImages(cursor: null));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 36, 34, 34),
      appBar: AppBar(
        title: const Text("Images"),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<ImageBloc>().add(FetchImages(cursor: null));
            },
          ),
        ],
      ),
      body: BlocBuilder<ImageBloc, ImageState>(
        builder: (context, state) {
          // 🔹 Skeleton for full page loading
          if (state is ImageLoadingState) {
            return ListView.builder(
              padding: const EdgeInsets.only(top: 30),
              itemCount: 3,
              itemBuilder: (context, _) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Skeleton date header
                    Container(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      height: 20,
                      width: 120,
                      color: Colors.grey.shade700,
                    ),
                    // Skeleton grid
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      itemCount: 6,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        mainAxisSpacing: 4,
                        crossAxisSpacing: 4,
                        childAspectRatio: 0.6,
                      ),
                      itemBuilder: (_, __) => _imageSkeleton(),
                    ),
                  ],
                );
              },
            );
          }

          if (state is ImageSuccessState ||
              state is ImageAddLoadingState ||
              state is ImageErrorState) {
            List<GalleryEntity> photosByDate = [];
            if (state is ImageSuccessState) {
              photosByDate = state.galleries;
            } else if (state is ImageAddLoadingState) {
              photosByDate = state.galleries ?? [];
            } else if (state is ImageErrorState) {
              photosByDate = state.galleries ?? [];
            }

            return ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.only(top: 30),
              itemCount: photosByDate.length + 1,
              itemBuilder: (context, index) {
                if (index < photosByDate.length) {
                  final dayEntry = photosByDate[index];
                  final date = dayEntry.takenAtDay;
                  final images = dayEntry.photos;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Date header
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16.0,
                          vertical: 8,
                        ),
                        child: Text(
                          "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      // Grid of images
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          mainAxisSpacing: 4,
                          crossAxisSpacing: 4,
                          childAspectRatio: 0.6,
                        ),
                        itemCount: images.length,
                        itemBuilder: (context, imgIndex) {
                          final photo = images[imgIndex];

                          return GestureDetector(
                            onTap: () {
                              // 🔹 Navigate to /photo/:id
                              context.push('/photo/${photo.id}');
                            },
                            child: CachedNetworkImage(
                              imageUrl: photo.thumbnailUrl,
                              fit: BoxFit.contain,
                              placeholder: (_, __) => _imageSkeleton(),
                              errorWidget: (_, __, ___) =>
                                  Container(
                                    color: Colors.grey[300],
                                    child: const Icon(Icons.error),
                                  ),
                            ),
                          );
                        },
                      ),
                    ],
                  );
                } 
                else if (state is ImageAddLoadingState) {
                  // Skeleton for bottom loading indicator
                  return Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      itemCount: 8,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                          mainAxisSpacing: 4,
                          crossAxisSpacing: 4,
                          childAspectRatio: 0.6,
                      ),
                      itemBuilder: (_, __) => _imageSkeleton(),
                    ),
                  );
                }
              },
            );
          }

          return const Center(child: Text("No images found."));
        },
      ),
    );
  }

  // 🔹 Skeleton widget
  Widget _imageSkeleton() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade800,
        borderRadius: BorderRadius.circular(6),
      ),
    );
  }
}

