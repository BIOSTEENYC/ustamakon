// =============================================================================
// FILE START: lib/features/remote/presentation/screens/remote_splash_screen.dart
// =============================================================================
import 'package:kompyuter_sirlari/imports.dart';

/// 1-bosqich: intro video / brend splash.
class RemoteSplashScreen extends StatelessWidget {
  const RemoteSplashScreen({
    super.key,
    required this.isFirstRun,
    required this.videoController,
    required this.lang,
  });

  final bool isFirstRun;
  final VideoPlayerController? videoController;
  final String lang;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 0, 0, 0),
      body: Stack(
        children: [
          if (isFirstRun &&
              videoController != null &&
              videoController!.value.isInitialized)
            Center(
              child: AspectRatio(
                aspectRatio: videoController!.value.aspectRatio,
                child: VideoPlayer(videoController!),
              ),
            )
          else
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/icon.png',
                    width: 120,
                    height: 120,
                    errorBuilder: (context, error, stackTrace) => Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: colorScheme.primaryContainer,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.auto_awesome_rounded,
                        size: 50,
                        color: colorScheme.primary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    AppMeta.brandName,
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                      letterSpacing: 2,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    tr(lang, 'brand_desc'),
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Center(
              child: CircularProgressIndicator(color: colorScheme.primary),
            ),
          ),
        ],
      ),
    );
  }
}
// =============================================================================
// FILE END: lib/features/remote/presentation/screens/remote_splash_screen.dart
// =============================================================================