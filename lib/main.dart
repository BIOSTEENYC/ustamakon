import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'theme/theme_notifier.dart';
import 'theme/themes.dart';
import 'screens/subject_list_screen.dart';

import 'models/subject.dart';
import 'models/category.dart';
import 'models/guide.dart';
import 'services/data_service.dart';
import 'services/pdf_service.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
// ignore: unnecessary_import
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart' show kIsWeb;


// --- Asosiy Ilova (Main Application) ---

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => ThemeNotifier(),
      child: const UstaMakonApp(),
    ),
  );
}

class UstaMakonApp extends StatelessWidget {
  const UstaMakonApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    return MaterialApp(
      title: 'UstaMakon',
      theme: lightTheme(context, customPrimary: themeNotifier.customPrimaryColor),
      darkTheme: darkTheme(context, customPrimary: themeNotifier.customPrimaryColor),
      themeMode: themeNotifier.themeMode,
      debugShowCheckedModeBanner: false,
      home: const SubjectListScreen(),
      routes: {
        '/settings': (context) => const SettingsScreen(),
      },
    );
  }
}


// Screens and logic are now split into separate files for maintainability.

/// Mavzular ro'yxatini ko'rsatuvchi ekran
class CategoryListScreen extends StatefulWidget {
  final Subject subject;
  const CategoryListScreen({super.key, required this.subject});

  @override
  State<CategoryListScreen> createState() => _CategoryListScreenState();
}

class _CategoryListScreenState extends State<CategoryListScreen> {
  late Future<List<Category>> _categoriesFuture;

  @override
  void initState() {
    super.initState();
    _categoriesFuture = DataService.fetchCategories(widget.subject.topicListUrl);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.subject.name, style: const TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: FutureBuilder<List<Category>>(
        future: _categoriesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Mavzularni yuklashda xato yuz berdi: ${snapshot.error}',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Theme.of(context).colorScheme.error, fontSize: 16),
                ),
              ),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Hech qanday mavzu topilmadi.'));
          } else {
            return ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final category = snapshot.data![index];
                return _buildCategoryCard(context, category, index); // index'ni qo'shdik
              },
            );
          }
        },
      ),
    );
  }

  Widget _buildCategoryCard(BuildContext context, Category category, int index) { // index parametrini qo'shdik
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      // CardTheme'dan kelgan elevation va shape ishlatiladi
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            PageRouteBuilder(
              transitionDuration: const Duration(milliseconds: 400),
              pageBuilder: (context, animation, secondaryAnimation) =>
                  GuideListScreen(category: category),
              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                const begin = Offset(1.0, 0.0);
                const end = Offset.zero;
                const curve = Curves.easeOutCubic;

                var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

                return SlideTransition(
                  position: animation.drive(tween),
                  child: child,
                );
              },
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Hero( // Animatsiya uchun Hero widget
                tag: 'category-emoji-${category.categoryName}-$index', // index'ni tag'ga qo'shdik
                child: Text(
                  category.iconEmoji,
                  style: const TextStyle(fontSize: 36),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  category.categoryName,
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ),
              Icon(Icons.arrow_forward_ios, color: Theme.of(context).colorScheme.onSurface.withAlpha((255 * 0.6).round())),
            ],
          ),
        ),
      ),
    );
  }
}

/// Qo'llanmalar ro'yxatini ko'rsatuvchi ekran
class GuideListScreen extends StatelessWidget {
  final Category category;
  const GuideListScreen({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(category.categoryName, style: const TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: category.guides.length,
        itemBuilder: (context, index) {
          final guide = category.guides[index];
          return _buildGuideCard(context, guide, index); // index'ni qo'shdik
        },
      ),
    );
  }

  Widget _buildGuideCard(BuildContext context, Guide guide, int index) { // index parametrini qo'shdik
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      // CardTheme'dan kelgan elevation va shape ishlatiladi
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            PageRouteBuilder(
              transitionDuration: const Duration(milliseconds: 400),
              pageBuilder: (context, animation, secondaryAnimation) =>
                  GuideViewerScreen(guide: guide),
              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                const begin = Offset(1.0, 0.0);
                const end = Offset.zero;
                const curve = Curves.easeOutCubic;

                var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

                return SlideTransition(
                  position: animation.drive(tween),
                  child: child,
                );
              },
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Hero( // Animatsiya uchun Hero widget
                tag: 'guide-emoji-${guide.title}-$index', // index'ni tag'ga qo'shdik
                child: Text(
                  guide.iconEmoji,
                  style: const TextStyle(fontSize: 30),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  guide.title,
                  style: GoogleFonts.inter(
                    fontSize: 17,
                    fontWeight: FontWeight.w400,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ),
              Icon(Icons.picture_as_pdf, color: Theme.of(context).colorScheme.secondary),
            ],
          ),
        ),
      ),
    );
  }
}

/// PDF qo'llanmani ko'rsatuvchi ekran
class GuideViewerScreen extends StatefulWidget {
  final Guide guide;
  const GuideViewerScreen({super.key, required this.guide});

  @override
  State<GuideViewerScreen> createState() => _GuideViewerScreenState();
}

class _GuideViewerScreenState extends State<GuideViewerScreen> {
  Uint8List? _pdfBytes;
  String? _tempFilePath; // Vaqtincha fayl yo'li (faqat mobil/desktop uchun)
  bool _isLoading = true;
  String? _error;
  final GlobalKey<SfPdfViewerState> _pdfViewerKey = GlobalKey();
  
  // SfPdfViewerController'ni qayta ishga tushiramiz
  late PdfViewerController _pdfViewerController; // To'g'ri nom: PdfViewerController
  late FocusNode _focusNode; // Klaviatura inputi uchun FocusNode

  // Sahifa o'lchamlarini saqlash uchun o'zgaruvchilar
  double? _firstPageWidth;
  double? _firstPageHeight;

  @override
  void initState() {
    super.initState();
    _pdfViewerController = PdfViewerController(); // Controller'ni initsializatsiya qildik
    _focusNode = FocusNode(); // FocusNode'ni initsializatsiya qildik
    _loadPdf();
  }

  Future<void> _loadPdf() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final obfuscatedBytes = await PdfService.loadObfuscatedPdfBytes(widget.guide.documentUrl);
      final deObfuscatedBytes = PdfService.xorBytes(obfuscatedBytes);

      if (!kIsWeb) {
        _tempFilePath = await PdfService.saveDeobfuscatedPdfTemporarily(deObfuscatedBytes);
      }

      setState(() {
        _pdfBytes = deObfuscatedBytes;
      });
    } catch (e) {
      setState(() {
        _error = 'PDF yuklashda xato yuz berdi: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    if (!kIsWeb) {
      PdfService.deleteTemporaryPdf(_tempFilePath);
    }
    _pdfViewerController.dispose(); // Controller'ni dispose qildik
    _focusNode.dispose(); // FocusNode'ni dispose qildik
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final shortestSide = mediaQuery.size.shortestSide;
    final orientation = mediaQuery.orientation;

    final bool isWearOs = shortestSide < 350 && (mediaQuery.size.width / mediaQuery.size.height > 0.9 && mediaQuery.size.width / mediaQuery.size.height < 1.1);

    // PDF sahifa ko'rinishi va aylantirish yo'nalishini aniqlash
    PdfPageLayoutMode pageLayoutMode = PdfPageLayoutMode.continuous;
    PdfScrollDirection scrollDirection = PdfScrollDirection.vertical;
    final double? currentPageWidth = _firstPageWidth;
    final double? currentPageHeight = _firstPageHeight;
    if (kIsWeb || orientation == Orientation.landscape) {
      pageLayoutMode = PdfPageLayoutMode.single;
      scrollDirection = PdfScrollDirection.horizontal;
    } else if (isWearOs) {
      if (currentPageWidth != null && currentPageHeight != null) {
        final double aspectRatio = currentPageWidth / currentPageHeight;
        if (aspectRatio > 1.1) {
          pageLayoutMode = PdfPageLayoutMode.single;
          scrollDirection = PdfScrollDirection.horizontal;
        } else {
          pageLayoutMode = PdfPageLayoutMode.continuous;
          scrollDirection = PdfScrollDirection.vertical;
        }
      } else {
        pageLayoutMode = PdfPageLayoutMode.continuous;
        scrollDirection = PdfScrollDirection.vertical;
      }
    } else {
      pageLayoutMode = PdfPageLayoutMode.continuous;
      scrollDirection = PdfScrollDirection.vertical;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.guide.title, style: const TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: KeyboardListener( // Klaviatura inputini tinglash uchun (RawKeyboardListener o'rniga)
        focusNode: _focusNode,
        autofocus: true, // Ekran ochilganda avtomatik fokusni olish
        onKeyEvent: (KeyEvent event) {
          if (event is KeyDownEvent) {
            // "A" yoki chap strelka tugmasi bosilganda oldingi sahifaga o'tish
            if (event.logicalKey == LogicalKeyboardKey.arrowLeft || event.logicalKey == LogicalKeyboardKey.keyA) {
              _pdfViewerController.previousPage();
            }
            // "D" yoki o'ng strelka tugmasi bosilganda keyingi sahifaga o'tish
            else if (event.logicalKey == LogicalKeyboardKey.arrowRight || event.logicalKey == LogicalKeyboardKey.keyD) {
              _pdfViewerController.nextPage();
            }
          }
        },
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        _error!,
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Theme.of(context).colorScheme.error, fontSize: 16),
                      ),
                    ),
                  )
                : _pdfBytes != null
                    ? Stack( // Tugmalarni PDF ustiga joylashtirish uchun Stack
                        children: [
                          SfPdfViewer.memory(
                            _pdfBytes!,
                            key: _pdfViewerKey,
                            controller: _pdfViewerController, // Controller'ni PDF viewerga berdik
                            pageLayoutMode: pageLayoutMode,
                            scrollDirection: scrollDirection,
                            onDocumentLoaded: (details) {
                              // PDF yuklangandan so'ng birinchi sahifa o'lchamlarini saqlaymiz
                              if (details.document.pages.count > 0) {
                                setState(() {
                                  _firstPageWidth = details.document.pages[0].size.width;
                                  _firstPageHeight = details.document.pages[0].size.height;
                                });
                              }
                            },
                            canShowScrollHead: true,
                            enableTextSelection: true,
                          ),
                          // Faqat desktop/web yoki landshaft rejimida ko'rinadigan tugmalar
                          if (pageLayoutMode == PdfPageLayoutMode.single && (kIsWeb || orientation == Orientation.landscape))
                            Positioned(
                              left: 10,
                              top: mediaQuery.size.height / 2 - 36, // Kattaroq tugma uchun markazlash
                              child: SizedBox(
                                width: 64,
                                height: 64,
                                child: FloatingActionButton(
                                  heroTag: 'prevBtn',
                                  onPressed: () {
                                    _pdfViewerController.previousPage();
                                  },
                                  backgroundColor: Theme.of(context).colorScheme.secondary.withAlpha((255 * 0.8).round()),
                                  foregroundColor: Theme.of(context).colorScheme.onSecondary,
                                  shape: const CircleBorder(),
                                  elevation: 8,
                                  child: const Icon(Icons.arrow_back_ios, size: 36),
                                ),
                              ),
                            ),
                          if (pageLayoutMode == PdfPageLayoutMode.single && (kIsWeb || orientation == Orientation.landscape))
                            Positioned(
                              right: 10,
                              top: mediaQuery.size.height / 2 - 36, // Kattaroq tugma uchun markazlash
                              child: SizedBox(
                                width: 64,
                                height: 64,
                                child: FloatingActionButton(
                                  heroTag: 'nextBtn',
                                  onPressed: () {
                                    _pdfViewerController.nextPage();
                                  },
                                  backgroundColor: Theme.of(context).colorScheme.secondary.withAlpha((255 * 0.8).round()),
                                  foregroundColor: Theme.of(context).colorScheme.onSecondary,
                                  shape: const CircleBorder(),
                                  elevation: 8,
                                  child: const Icon(Icons.arrow_forward_ios, size: 36),
                                ),
                              ),
                            ),
                        ],
                      )
                    : const Center(child: Text('PDF fayl topilmadi.')),
      ),
    );
  }
}

// --- Sozlamalar Ekrani (Settings Screen) ---
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sozlamalar', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          Card(
            // CardTheme'dan kelgan elevation va shape ishlatiladi
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Mavzu',
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Tungi rejim',
                        style: GoogleFonts.inter(fontSize: 16),
                      ),
                      Switch(
                        value: themeNotifier.isDarkMode,
                        onChanged: (value) {
                          themeNotifier.toggleTheme(value);
                        },
                        activeColor: Theme.of(context).colorScheme.secondary,
                        inactiveThumbColor: Theme.of(context).colorScheme.primary.withAlpha((255 * 0.5).round()),
                        inactiveTrackColor: Theme.of(context).colorScheme.primary.withAlpha((255 * 0.2).round()),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton.icon(
                    onPressed: () {
                      themeNotifier.setSystemTheme();
                    },
                    icon: const Icon(Icons.brightness_auto),
                    label: const Text('Tizim mavzusiga o\'tish'),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size.fromHeight(40), // Tugmani to'liq kenglikda qilish
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Card(
            // CardTheme'dan kelgan elevation va shape ishlatiladi
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Dizaynni moslashtirish',
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Bu yerda kelajakda ilova ranglari, shriftlari va boshqa vizual elementlarni o\'zgartirish imkoniyatlari qo\'shiladi. Hozircha asosiy rangni o\'zgartirishingiz mumkin.',
                    textAlign: TextAlign.justify,
                    style: GoogleFonts.inter(fontSize: 14, color: Theme.of(context).colorScheme.onSurface.withAlpha((255 * 0.7).round())),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const DesignCustomizationScreen()),
                      );
                    },
                    icon: const Icon(Icons.palette),
                    label: const Text('Asosiy rangni tanlash'),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size.fromHeight(40),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// --- Dizaynni moslashtirish ekrani (Design Customization Screen) ---
class DesignCustomizationScreen extends StatelessWidget {
  const DesignCustomizationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context, listen: false);

    // Tanlash uchun ranglar palitrasi
    final List<Color> primaryColors = [
      Colors.deepPurple,
      Colors.blue,
      Colors.green,
      Colors.red,
      Colors.orange,
      Colors.pink,
      Colors.teal,
      Colors.brown,
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dizaynni moslash', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Asosiy rangni tanlang:',
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4, // 4 ta ustun
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 1, // Kvadrat shakl
                ),
                itemCount: primaryColors.length,
                itemBuilder: (context, index) {
                  final color = primaryColors[index];
                  return GestureDetector(
                    onTap: () {
                      themeNotifier.setCustomPrimaryColor(color);
                      // Rang tanlangandan keyin orqaga qaytish
                      Navigator.pop(context);
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: themeNotifier.customPrimaryColor == color
                              ? Theme.of(context).colorScheme.secondary
                              : Colors.transparent,
                          width: 3,
                        ),
                        boxShadow: [
                          BoxShadow(
                            // ignore: deprecated_member_use
                            color: Color.fromRGBO(0, 0, 0, 0.2),
                            spreadRadius: 1,
                            blurRadius: 5,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Center(
                        child: themeNotifier.customPrimaryColor == color
                            ? Icon(
                                Icons.check,
                                color: color.computeLuminance() > 0.5 ? Colors.black : Colors.white,
                                size: 40,
                              )
                            : null,
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () {
                themeNotifier.setSystemTheme(); // Tizim ranglariga qaytish
                Navigator.pop(context); // Orqaga qaytish
              },
              icon: const Icon(Icons.color_lens_outlined),
              label: const Text('Asl ranglarga qaytish'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(40),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
