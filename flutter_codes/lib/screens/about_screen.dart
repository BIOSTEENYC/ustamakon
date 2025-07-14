import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart'; // << qo‘shildi

import '../utils/responsive_utils.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  // URL ochish funksiyasi
  void _launchURL(String url) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw 'URL ochib bo\'lmadi: $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Ilova haqida"),
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/background.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Material(
          color: Colors.black54,
          child: Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(responsiveSize(context, 24.0)),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/images/icon.png',
                    width: responsiveSize(context, 100.0),
                    height: responsiveSize(context, 100.0),
                  ),
                  SizedBox(height: responsiveSize(context, 24.0)),
                  Text(
                    "UstaMakon",
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold, color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: responsiveSize(context, 16.0)),
                  Text(
                    "Bu ilova turli sohalardagi qo'llanmalarni oson topish va o'qish uchun mo'ljallangan.",
                    style: Theme.of(context)
                        .textTheme
                        .bodyLarge
                        ?.copyWith(color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: responsiveSize(context, 24.0)),
                  Text(
                    "Tuzuvchi:",
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold, color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: responsiveSize(context, 8.0)),
                  Text(
                    "Biosteenyc | Abdulhakim Xayitboyev",
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.bold, color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: responsiveSize(context, 24.0)),
                  Text(
                    "Aloqa",
                    style: Theme.of(context)
                        .textTheme
                        .bodyLarge
                        ?.copyWith(color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: responsiveSize(context, 24.0)),

                  // Aloqa tugmalari
                  Wrap(
                    spacing: 16.0,
                    runSpacing: 10.0,
                    alignment: WrapAlignment.center,
                    children: [
                      ElevatedButton.icon(
                        onPressed: () {
                          _launchURL("https://biosteenyc.github.io"); // Web sayt
                        },
                        icon: const Icon(Icons.language),
                        label: const Text("Bizning sayt"),
                      ),
                      ElevatedButton.icon(
                        style: ButtonStyle(
                          backgroundColor: WidgetStateProperty.all<Color>(
                              Colors.redAccent),
                        ),
                        onPressed: () {
                          _launchURL("https://youtube.com/@biosteenyc"); // YouTube
                        },
                        icon: const Icon(Icons.video_library,color: Colors.white,),
                        label: const Text("YouTube",style: TextStyle(color: Colors.white),),
                      ),
                      ElevatedButton.icon(
                        style: ButtonStyle(
                          backgroundColor: WidgetStateProperty.all<Color>(
                              Colors.blueAccent),
                        ),
                        onPressed: () {
                          _launchURL("https://t.me/biosteenyc"); // Telegram
                        },
                        icon: const Icon(Icons.send,color: Colors.white,),
                        label: const Text("Telegram",style: TextStyle(color: Colors.white),),
                      ),
                      ElevatedButton.icon(
                        style: ButtonStyle(
                          backgroundColor: WidgetStateProperty.all<Color>(
                            const Color.fromARGB(255, 18, 148, 72),
                          ),
                        ),
                        onPressed: () {
                          _launchURL("https://play.google.com/store/apps/dev?id=7419772761516862615"); // Play Market
                        },
                        icon: const Icon(Icons.apps, color: Colors.white,),
                        label: const Text("Play Market", style: TextStyle(color: Colors.white),),
                      )
                    ],
                  ),

                  SizedBox(height: responsiveSize(context, 32.0)),
                  Text(
                    "Versiya: 2.2.0",
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(color: const Color.fromARGB(255, 233, 232, 232)),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
