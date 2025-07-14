import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';

// import '../models/category.dart'; // Bu qatorni o'chirildi - endi foydalanilmaydi
import '../models/guide.dart';
import '../models/subject.dart';
import '../utils/constants.dart';
import 'data_service.dart';
import 'pdf_service.dart';

// Ma'lumotlarni oldindan yuklash menejeri
class PreloadManager {
  final ValueNotifier<double> progress = ValueNotifier(0.0);
  final ValueNotifier<String> status = ValueNotifier("Tayyorlanmoqda...");
  final ValueNotifier<String?> error = ValueNotifier(null);

  Future<void> preloadAllData({bool forceRefresh = false}) async {
    try {
      error.value = null;
      status.value = "Fanlar ro'yxati yuklanmoqda...";
      progress.value = 0.05;

      final dataService = DataService();
      final pdfService = PdfService();
      final settingsBox = Hive.box(hiveSettingsBoxName);
      final bool offlineModeEnabled = settingsBox.get(offlineModeKey, defaultValue: false);

      await Future.delayed(const Duration(milliseconds: 100));

      List<Subject> subjects = await dataService.fetchSubjects(forceRefresh: forceRefresh);
      progress.value = 0.25;

      if (subjects.isEmpty && !forceRefresh) {
        status.value = "Kesh bo'sh. Majburiy yangilanmoqda...";
        await Future.delayed(const Duration(milliseconds: 100));
        subjects = await dataService.fetchSubjects(forceRefresh: true);
        progress.value = 0.35;
      }

      if (subjects.isEmpty) {
        throw Exception("Fanlar topilmadi. Internet aloqasini tekshiring yoki keyinroq urinib ko'ring.");
      }
      status.value = "Fanlar yuklandi. Kategoriyalar tekshirilmoqda...";

      List<Guide> allGuides = [];
      for (int i = 0; i < subjects.length; i++) {
        final subject = subjects[i];
        if (subject.categories.isEmpty && subject.topicListUrl.isNotEmpty) {
          status.value = "'${subject.name}' uchun kategoriyalar yuklanmoqda...";
          subject.categories = await dataService.fetchCategoriesForSubject(subject, forceRefresh: forceRefresh);
          if(subject.isInBox) await subject.save();
        }
        allGuides.addAll(subject.categories.expand((cat) => cat.guides));
        progress.value = 0.35 + (0.2 * ((i + 1) / subjects.length));
      }

      if (allGuides.isNotEmpty && offlineModeEnabled) { // Faqat oflayn rejim yoqilgan bo'lsa yuklaymiz
        status.value = "Layk bosilgan qo'llanmalar (PDF) yuklanmoqda...";
        await Future.delayed(const Duration(milliseconds: 100));
        progress.value = 0.55;

        final List<Guide> likedGuides = allGuides.where((guide) => guide.isDownloaded).toList();
        int totalLikedGuides = likedGuides.length;
        int loadedGuides = 0;

        for (int i = 0; i < totalLikedGuides; i++) {
          final guide = likedGuides[i];
          status.value = "PDF yuklanmoqda: ${loadedGuides + 1}/$totalLikedGuides ('${guide.title.substring(0, guide.title.length > 20 ? 20 : guide.title.length)}...')";
          if (guide.documentUrl.isNotEmpty) {
            await pdfService.loadPdfBytes(guide.documentUrl, forceRefresh: forceRefresh);
          }
          loadedGuides++;
          progress.value = 0.55 + (0.40 * (loadedGuides / totalLikedGuides));
        }
      } else if (allGuides.isNotEmpty && !offlineModeEnabled) {
        status.value = "Oflayn rejim o'chiq. PDFlar yuklanmaydi.";
        progress.value = 0.95; // Tezroq tugatish
      }


      progress.value = 1.0;
      status.value = "Barcha ma'lumotlar yuklandi!";
      await Hive.box(hiveSettingsBoxName).put(lastSuccessfulPreloadKey, DateTime.now().toIso8601String());

    } catch (e) {
      if (kDebugMode) print("Ma'lumotlarni oldindan yuklashda xatolik:");
      error.value = "Xatolik: \nIltimos, internet aloqangizni tekshiring va qayta urinib ko'ring.";
      progress.value = 0.0;
    }
  }
}