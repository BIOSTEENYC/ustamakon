import 'package:flutter/material.dart';

import '../services/preload_manager.dart';
import '../utils/responsive_utils.dart';
import 'about_screen.dart';

// Splash Screen (Yuklash ekrani)
class SplashScreen extends StatelessWidget {
  final PreloadManager preloadManager;
  final VoidCallback onRetry;
  const SplashScreen({super.key, required this.preloadManager, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container( // Container qo'shildi
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/background.png'), // Orqa fon rasmi
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(responsiveSize(context, 20.0)),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                // Lottie animatsiyasi qo'shish mumkin
                SizedBox(
                  width: responsiveSize(context, 60.0), // Responsive size
                  height: responsiveSize(context, 60.0), // Responsive size
                  child: const CircularProgressIndicator(),
                ),
                SizedBox(height: responsiveSize(context, 20.0)), // Responsive spacing
                ValueListenableBuilder<String>(
                  valueListenable: preloadManager.status,
                  builder: (context, status, child) {
                    return Text(
                      status,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleMedium,
                    );
                  },
                ),
                SizedBox(height: responsiveSize(context, 10.0)), // Responsive spacing
                ValueListenableBuilder<double>(
                  valueListenable: preloadManager.progress,
                  builder: (context, progress, child) {
                    return LinearProgressIndicator(
                      value: progress,
                      minHeight: responsiveSize(context, 8.0), // Responsive height
                      borderRadius: BorderRadius.circular(responsiveSize(context, 4.0)), // Responsive border radius
                    );
                  },
                ),
                SizedBox(height: responsiveSize(context, 20.0)), // Responsive spacing
                ValueListenableBuilder<String?>(
                  valueListenable: preloadManager.error,
                  builder: (context, error, child) {
                    if (error != null) {
                      return Column(
                        children: [
                          Text(
                            error,
                            style: TextStyle(color: Colors.red, fontSize: responsiveTextSize(context, 14.0)), // Responsive text size
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: responsiveSize(context, 10.0)), // Responsive spacing
                          ElevatedButton(onPressed: onRetry, child: const Text("Qayta urinish"))
                        ],
                      );
                    }
                    return const SizedBox.shrink();
                  },
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