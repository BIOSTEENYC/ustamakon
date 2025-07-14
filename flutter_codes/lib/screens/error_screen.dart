import 'package:flutter/material.dart';

import '../services/preload_manager.dart';
import '../utils/responsive_utils.dart';
import 'about_screen.dart';

// Xato ekrani
class ErrorScreen extends StatelessWidget {
  final PreloadManager preloadManager;
  final VoidCallback onRetry;
  const ErrorScreen({super.key, required this.preloadManager, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Xatolik")),
      body: Container( // Container qo'shildi
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/background.png'), // Orqa fon rasmi
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(responsiveSize(context, 16.0)),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, color: Colors.red, size: responsiveSize(context, 60.0)), // Responsive size
                SizedBox(height: responsiveSize(context, 24.0)), // Responsive spacing
                Text(
                  preloadManager.error.value ?? "Noma'lum xatolik yuz berdi.",
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                SizedBox(height: responsiveSize(context, 24.0)), // Responsive spacing
                ElevatedButton.icon(
                  icon: const Icon(Icons.refresh),
                  label: const Text("Qayta yuklash"),
                  onPressed: onRetry,
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const AboutScreen()));
        },
        child: const Icon(Icons.info_outline),
      ),
    );
  }
}