import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:photo_sync_app/features/gallery/presentation/bloc/image/image_bloc.dart';
import 'package:photo_sync_app/features/gallery/presentation/bloc/login/login_bloc.dart';
import 'package:photo_sync_app/features/gallery/presentation/bloc/logout/logout_bloc.dart';
import 'package:photo_sync_app/features/gallery/presentation/bloc/photo%20main/image_bloc.dart';
import 'package:photo_sync_app/features/gallery/presentation/bloc/register/register_bloc.dart';
import 'package:photo_sync_app/features/gallery/presentation/page/image_detail_page.dart';
import 'package:photo_sync_app/features/gallery/presentation/page/images_page.dart';
import 'package:photo_sync_app/features/gallery/presentation/page/login_page.dart';
import 'package:photo_sync_app/features/gallery/presentation/page/register_page.dart';
import 'package:photo_sync_app/features/gallery/presentation/page/splash_page.dart';
import 'package:photo_sync_app/injection.dart';

class PhotoSyncApp extends StatelessWidget {
  const PhotoSyncApp({super.key});

  @override
  Widget build(BuildContext context) {
    final _rootNavigatorKey = GlobalKey<NavigatorState>();

    final GoRouter _router = GoRouter(
      navigatorKey: _rootNavigatorKey,
      initialLocation: '/',
      routes: [
        GoRoute(path: '/', builder: (context, state) => const SplashPage()),
        GoRoute(path: '/login', builder: (context, state) => LoginPage()),
        GoRoute(path: '/register', builder: (context, state) => RegisterPage()),
        GoRoute(path: '/images', builder: (context, state) => ImagesPage()),
        GoRoute(
          path: '/images/:id',
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
        BlocProvider(create: (context) => sl<LoginBloc>()),
        BlocProvider.value(value: sl<LogoutBloc>()),
        BlocProvider(create: (context) => sl<RegisterBloc>()),
      ],
      child: MaterialApp.router(
        debugShowCheckedModeBanner: false,
        routerConfig: _router,
        builder: (context, child) {
          // 🔹 Place the BlocListener here
          return BlocListener<LogoutBloc, LogoutState>(
            listener: (context, state) async {
              if (state is LogoutSuccessState) {
                await showDialog(
        context: context,
        barrierDismissible: false, // force the user to tap OK
        builder: (context) => AlertDialog(
          title: const Text("Session Expired"),
          content: const Text(
              "Your session has expired. Please log in again."),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(), // close dialog
              child: const Text("OK"),
            ),
          ],
        ),
      );
                _rootNavigatorKey.currentContext?.go('/login');
              } else if (state is LogoutFailureState) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Logout failed: ${state.message}")),
                );
              }
            },
            child: child!,
          );
        },
      ),
    );
  }
}

