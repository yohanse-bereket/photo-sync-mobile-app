import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:photo_sync_app/features/gallery/data/datasource/local_datasource.dart';
import 'package:photo_sync_app/injection.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    final token = await sl<GalleryLocalDataSource>().getAccessToken();

    if (!mounted) return; 

    if (token != null && token.isNotEmpty) {
      context.go('/images'); // Safe now
    } else {
      context.go('/login'); // Safe now
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}

