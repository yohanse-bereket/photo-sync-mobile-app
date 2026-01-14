import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:photo_sync_app/features/gallery/presentation/bloc/image/image_bloc.dart';
import 'package:photo_sync_app/features/gallery/presentation/bloc/photo%20main/image_bloc.dart';
import 'package:photo_sync_app/features/gallery/presentation/page/image_detail_page.dart';
import 'package:photo_sync_app/features/gallery/presentation/page/images_page.dart';
import 'package:photo_sync_app/injection.dart';

class PhotoSyncApp extends StatelessWidget {
  const PhotoSyncApp({super.key});

  @override
  Widget build(BuildContext context) {
    final GoRouter _router = GoRouter(
      navigatorKey: GlobalKey<NavigatorState>(),
      routes: [
        GoRoute(path: '/', builder: (context, state) => ImagesPage()),
        GoRoute(
          path: '/photo/:id',
          builder: (context, state) {
            return PhotoDetailsPage(photoId: state.pathParameters['id']!);
          },
        ),
      ],
    );
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => sl<ImageBloc>()),
        BlocProvider(create: (context) => sl<PhotoMainBloc>()),
      ],
      child: MaterialApp.router(
        debugShowCheckedModeBanner: false,
        routerConfig: _router,
      ),
    );
  }
}
