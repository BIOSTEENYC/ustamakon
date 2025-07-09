import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart' show kDebugMode;
import '../models/subject.dart';
import '../models/category.dart';

class DataService {
  static const String mainSubjectsJsonUrl = 'https://raw.githubusercontent.com/BIOSTEENYC/ustamakon/main/documents/subjects.json';

  static Future<List<Subject>> fetchSubjects() async {
    try {
      final response = await http.get(Uri.parse(mainSubjectsJsonUrl));
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(utf8.decode(response.bodyBytes));
        final List<dynamic> subjectsJson = data['subjects'];
        return subjectsJson.map((json) => Subject.fromJson(json)).toList();
      } else {
        throw Exception('Fanlar yuklanmadi: {response.statusCode}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Fanlar yuklashda xato: $e');
      }
      throw Exception('Fanlar yuklashda xato: $e');
    }
  }

  static Future<List<Category>> fetchCategories(String url) async {
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final dynamic data = json.decode(utf8.decode(response.bodyBytes));
        List<dynamic> categoriesJson;
        if (data is List) {
          categoriesJson = data;
        } else {
          throw Exception('JSON formatida xato: Mavzular topilmadi');
        }
        return categoriesJson.map((json) => Category.fromJson(json)).toList();
      } else {
        throw Exception('Mavzular yuklanmadi: {response.statusCode}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Mavzular yuklashda xato: $e');
      }
      throw Exception('Mavzular yuklashda xato: $e');
    }
  }
}
