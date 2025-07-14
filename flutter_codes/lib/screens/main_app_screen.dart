import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../models/subject.dart';
import '../services/data_service.dart';
import '../utils/constants.dart';
import '../utils/responsive_utils.dart';
import '../widgets/subject_card.dart';
import 'about_screen.dart';


// Asosiy ilova ekrani (Fanlar ro'yxati)
class MainAppScreen extends StatefulWidget {
  const MainAppScreen({super.key});

  @override
  State<MainAppScreen> createState() => _MainAppScreenState();
}

class _MainAppScreenState extends State<MainAppScreen> {
  bool _offlineMode = false;

  @override
  void initState() {
    super.initState();
    _loadOfflineModeSetting();
  }

  Future<void> _loadOfflineModeSetting() async {
    final settingsBox = Hive.box(hiveSettingsBoxName);
    setState(() {
      _offlineMode = settingsBox.get(offlineModeKey, defaultValue: false);
    });
  }

  Future<void> _toggleOfflineMode(bool value) async {
    final settingsBox = Hive.box(hiveSettingsBoxName);
    await settingsBox.put(offlineModeKey, value);
    setState(() {
      _offlineMode = value;
    });
    // Agar oflayn rejim yoqilgan bo'lsa, yuklangan PDFlarni qayta yuklash kerak bo'lishi mumkin
    // yoki aksincha, agar o'chirilgan bo'lsa, barcha PDFlarni yuklashni to'xtatish kerak
    // Hozircha bu yerda hech narsa qilmaymiz, chunki PreloadManager faqat liked PDFlarni yuklaydi
  }

  @override
  Widget build(BuildContext context) {
    final dataService = DataService();
    final shortestSide = MediaQuery.of(context).size.shortestSide;
    final crossAxisCount = shortestSide < 600 ? 2 : (shortestSide < 900 ? 3 : 4);

    return Scaffold(
      appBar: AppBar(
        title: const Text('UstaMakon'),
        actions: [
          Row(
            children: [
              Text("Oflayn rejim", style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white)),
              Switch(
                value: _offlineMode,
                onChanged: _toggleOfflineMode,
                activeColor: Colors.white,
                inactiveThumbColor: Colors.grey.shade400,
                inactiveTrackColor: Colors.grey.shade600,
              ),
            ],
          ),
        ],
      ),
      body: Container( // Container qo'shildi
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/background.png'), // Orqa fon rasmi
            fit: BoxFit.cover,
          ),
        ),
        child: FutureBuilder<List<Subject>>(
          future: dataService.fetchSubjects(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Ma\'lumotlarni yuklashda xatolik: ${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.folder_off, size: responsiveSize(context, 80.0), color: Colors.grey),
                    SizedBox(height: responsiveSize(context, 16.0)),
                    Text(
                      'Fanlar mavjud emas.',
                      style: TextStyle(fontSize: responsiveTextSize(context, 18.0), color: Colors.grey),
                    ),
                  ],
                ),
              );
            }

            final subjects = snapshot.data!;
            // Oflayn rejim yoqilgan bo'lsa, faqat kategoriyalari bo'lgan fanlarni ko'rsatamiz
            final displayedSubjects = _offlineMode
                ? subjects.where((s) => s.categories.isNotEmpty && s.categories.any((c) => c.guides.any((g) => g.isDownloaded))).toList()
                : subjects;


            if (displayedSubjects.isEmpty && _offlineMode) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.wifi_off, size: responsiveSize(context, 80.0), color: const Color.fromARGB(255, 255, 255, 255)),
                    SizedBox(height: responsiveSize(context, 16.0)),
                    Text(
                      'Oflayn rejimda yuklangan darsliklar topilmadi. Onlayn rejimga o\'ting va darsliklarni yuklab oling.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: responsiveTextSize(context, 16.0), color: const Color.fromARGB(255, 255, 255, 255,),fontWeight: FontWeight.bold,),
                    ),
                  ],
                ),
              );
            } else if (displayedSubjects.isEmpty && !_offlineMode) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.folder_off, size: responsiveSize(context, 80.0), color: Colors.grey),
                    SizedBox(height: responsiveSize(context, 16.0)),
                    Text(
                      'Fanlar mavjud emas.',
                      style: TextStyle(fontSize: responsiveTextSize(context, 18.0), color: Colors.grey),
                    ),
                  ],
                ),
              );
            }


            return MasonryGridView.builder(
              padding: EdgeInsets.all(responsiveSize(context, 16.0)),
              gridDelegate: SliverSimpleGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
              ),
              mainAxisSpacing: responsiveSize(context, 16.0),
              crossAxisSpacing: responsiveSize(context, 16.0),
              itemCount: displayedSubjects.length,
              itemBuilder: (context, index) {
                final subject = displayedSubjects[index];
                return SubjectCard(subject: subject, offlineMode: _offlineMode);
              },
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.black,
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const AboutScreen()));
        },
        child: const Icon(Icons.play_circle,color: Colors.white,),
      ),
    );
  }
}