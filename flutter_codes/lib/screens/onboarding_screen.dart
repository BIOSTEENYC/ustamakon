import 'package:flutter/material.dart';

import '../utils/responsive_utils.dart';


// Onboarding ekrani
class OnboardingScreen extends StatefulWidget {
  final VoidCallback onDone;
  const OnboardingScreen({super.key, required this.onDone});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Widget> _pages = [
    const OnboardingPage(
      title: "Xush kelibsiz!",
      description: "UstaMakon ilovasi orqali turli sohalardagi qo'llanmalarni toping.",
      iconData: Icons.school_outlined,
    ),
    const OnboardingPage(
      title: "Oson Foydalanish",
      description: "Kerakli fan yoki mavzuni tanlang va PDF hujjatlarni o'qing.",
      iconData: Icons.picture_as_pdf_outlined,
    ),
    const OnboardingPage(
      title: "Offline Rejim",
      description: "Muhim darsliklarni oflaynga saqlash uchun ❤️layk bosing.", // Yangilangan matn
      iconData: Icons.cloud_download_outlined,
    ),
  ];

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
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: PageView(
                  controller: _pageController,
                  onPageChanged: (int page) {
                    setState(() {
                      _currentPage = page;
                    });
                  },
                  children: _pages,
                ),
              ),
              Padding(
                padding: EdgeInsets.all(responsiveSize(context, 24.0)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List<Widget>.generate(_pages.length, (int index) {
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          height: responsiveSize(context, 10.0),
                          width: (index == _currentPage) ? responsiveSize(context, 30.0) : responsiveSize(context, 10.0),
                          margin: EdgeInsets.symmetric(horizontal: responsiveSize(context, 5.0)),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(responsiveSize(context, 5.0)),
                              color: (index == _currentPage)
                                  ? Theme.of(context).primaryColor
                                  : const Color.fromARGB(255, 226, 226, 226)),
                        );
                      }),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        if (_currentPage < _pages.length - 1) {
                          _pageController.nextPage(
                            duration: const Duration(milliseconds: 400),
                            curve: Curves.easeInOut,
                          );
                        } else {
                          widget.onDone();
                        }
                      },
                      child: Text(
                          _currentPage < _pages.length - 1 ? "Keyingisi" : "Boshlash"),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Onboarding sahifasi
class OnboardingPage extends StatelessWidget {
  final String title;
  final String description;
  final IconData iconData;

  const OnboardingPage({
    super.key,
    required this.title,
    required this.description,
    required this.iconData,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.all(responsiveSize(context, 40.0)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Icon(
              iconData,
              size: responsiveSize(context, 120.0),
              color: Colors.white,
            ),
            SizedBox(height: responsiveSize(context, 40.0)),
            Text(
              title,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold, color: Colors.white),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: responsiveSize(context, 20.0)),
            Text(
              description,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}