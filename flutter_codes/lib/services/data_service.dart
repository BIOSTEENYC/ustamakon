import 'dart:convert';
import 'package:flutter/foundation.dart' hide Category; // Category nomini yashiramiz
import 'package:hive_flutter/hive_flutter.dart';
import 'package:http/http.dart' as http;

import '../models/category.dart'; // Sizning Category modelingiz
import '../models/subject.dart';
import '../utils/constants.dart';

// Ma'lumotlarni boshqarish xizmati
class DataService {
  static final DataService _instance = DataService._internal();
  factory DataService() => _instance;
  DataService._internal();

  late Box<Subject> _subjectsBox;
  final String _subjectsJsonUrl = 'https://raw.githubusercontent.com/BIOSTEENYC/ustamakon/main/documents/subjects.json';

  Future<void> init() async {
    _subjectsBox = await Hive.openBox<Subject>(hiveSubjectsBoxName);
  }

  Future<List<Subject>> fetchSubjects({bool forceRefresh = false}) async {
    List<Subject> subjectsFromNetwork = [];
    try {
      if (kDebugMode) print('Fanlar internetdan yuklanmoqda: $_subjectsJsonUrl');
      final response = await http.get(Uri.parse(_subjectsJsonUrl));
      if (response.statusCode == 200) {
        final decodedBody = utf8.decode(response.bodyBytes);
        final dynamic decodedJson = json.decode(decodedBody);

        if (decodedJson is Map<String, dynamic> && decodedJson.containsKey('subjects')) {
          final List<dynamic>? subjectsDataList = decodedJson['subjects'] as List<dynamic>?;
          if (subjectsDataList != null) {
            for (var data in subjectsDataList) {
              if (data is Map<String, dynamic>) {
                final subject = Subject.fromJson(data);
                // Keshda mavjud bo'lsa, kategoriyalarni yangilash
                final existingSubject = _subjectsBox.get(subject.id);
                if (existingSubject != null) {
                  // isDownloaded holatini saqlash Guide darajasida bo'lishi kerak, Subjectda emas.
                  // Shuning uchun bu yerda existingSubject.categories ni yangilash kifoya.
                  subject.categories = existingSubject.categories;
                }
                if (subject.topicListUrl.isNotEmpty && subject.categories.isEmpty) {
                  subject.categories = await fetchCategoriesForSubject(subject, forceRefresh: true);
                }
                subjectsFromNetwork.add(subject);
              } else {
                throw Exception('Subject ma\'lumoti kutilgan Map formatida emas: $data');
              }
            }

            // Hive ni yangilash: barcha eski ma'lumotlarni o'chirish va yangilarini JSON tartibida saqlash
            await _subjectsBox.clear();
            for (final subject in subjectsFromNetwork) {
              await _subjectsBox.put(subject.id, subject);
            }

            if (kDebugMode) print('Fanlar internetdan yuklandi va Hive ga saqlandi (count: ${subjectsFromNetwork.length})');
            return subjectsFromNetwork; // JSON dagi asl tartibda qaytarish
          } else {
            throw Exception("'subjects' kaliti ostidagi ma'lumotlar ro'yxati topilmadi (null).");
          }
        } else {
          throw Exception('Kutilmagan JSON formati subjects.json uchun. Javob Map emas yoki "subjects" kaliti yo\'q. Kelgan tur: ${decodedJson.runtimeType}');
        }
      } else {
        throw Exception('Fanlarni yuklashda xatolik (${response.statusCode}): ${response.reasonPhrase}');
      }
    } catch (e) {
      if (kDebugMode) print('Fanlarni yuklashda xatolik: $e');
      // Xatolik yuz berganda keshdagi ma'lumotlarni qaytarish
      final List<Subject> cachedSubjects = _subjectsBox.values.toList();
      if (cachedSubjects.isNotEmpty) {
        if (kDebugMode) print('Xatolik yuz berdi, Hive dagi eski fanlar qaytarildi.');
        // Keshdagi fanlarni JSON dagi tartibga solishga urinish
        // Bu yerda JSON dan kelgan tartibni bilmaymiz, shuning uchun shunchaki keshdagini qaytaramiz
        // Agar JSONdan yuklash muvaffaqiyatli bo'lsa, keyingi safar tartib to'g'ri bo'ladi
        return cachedSubjects;
      }
      throw Exception('Fanlar yuklanmadi va keshda ham mavjud emas. Xatolik: $e');
    }
  }

  Future<List<Category>> fetchCategoriesForSubject(Subject subject, {bool forceRefresh = false}) async {
    if (subject.topicListUrl.isEmpty) return [];

    if (!forceRefresh && subject.isInBox && subject.categories.isNotEmpty) {
      bool allGuidesHaveUrls = true;
      for (var cat in subject.categories) {
        for (var guide in cat.guides) {
          if (guide.documentUrl.isEmpty) {
            allGuidesHaveUrls = false;
            break;
          }
        }
        if (!allGuidesHaveUrls) break;
      }
      if (allGuidesHaveUrls) {
        if (kDebugMode) print('"${subject.name}" uchun kategoriyalar Hive (Subject ichidan) dan olindi.');
        return subject.categories;
      } else {
        if (kDebugMode) print('"${subject.name}" uchun Hive (Subject ichidan) kategoriyalarida ayrim hujjat URLlari yetishmayapti. Yangilanmoqda...');
      }
    }

    try {
      if (kDebugMode) print('"${subject.name}" uchun kategoriyalar internetdan yuklanmoqda: ${subject.topicListUrl}');
      final response = await http.get(Uri.parse(subject.topicListUrl));
      if (response.statusCode == 200) {
        final List<dynamic> decodedData = json.decode(utf8.decode(response.bodyBytes));
        // Bu yerda List<dynamic> ni List<Category> ga to'g'ri o'zgartirish
        final List<Category> categories = decodedData.map((data) {
          if (data is Map<String, dynamic>) {
            return Category.fromJson(data);
          } else {
            throw Exception('Category ma\'lumoti kutilgan Map formatida emas: $data');
          }
        }).toList();

        if (kDebugMode) print('"${subject.name}" uchun kategoriyalar internetdan yuklandi (count: ${categories.length})');
        if (subject.isInBox) {
          subject.categories = categories;
          await subject.save();
        }
        return categories;
      } else {
        throw Exception('Kategoriyalarni yuklashda xatolik (${response.statusCode}): ${response.reasonPhrase} URL: ${subject.topicListUrl}');
      }
    } catch (e) {
      if (kDebugMode) print('Kategoriyalarni yuklashda xatolik ("${subject.name}"): $e');
      if (subject.isInBox && subject.categories.isNotEmpty) {
        if (kDebugMode) print('Xatolik yuz berdi, "${subject.name}" uchun Hive dagi eski kategoriyalar qaytarildi.');
        return subject.categories;
      }
      return [];
    }
  }
}