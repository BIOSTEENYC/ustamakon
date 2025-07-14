import 'dart:convert';
import 'dart:io';
// ignore: unnecessary_import
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'package:http/http.dart' as http;

import '../models/guide.dart';
import '../utils/constants.dart';
import '../utils/obfuscation_utils.dart';


// PDF xizmati
class PdfService {
  static final PdfService _instance = PdfService._internal();
  factory PdfService() => _instance;
  PdfService._internal();

  late Box<Uint8List> _pdfBox;

  Future<void> init() async {
    _pdfBox = await Hive.openBox<Uint8List>(hivePdfBoxName);
  }

  String _generateKey(String url) => md5.convert(utf8.encode(url)).toString();

  Future<File> _getPdfCacheFile(String url) async {
    final dir = await getPdfCacheDirectory();
    final fileName = '${_generateKey(url)}.pdfenc';
    return File('${dir.path}/$fileName');
  }

  // PDF ni yuklash va saqlash/qaytarish
  Future<Uint8List?> loadPdfBytes(String url, {bool forceRefresh = false}) async {
    if (url.isEmpty) {
      if (kDebugMode) print('PDF URL bo\'sh, yuklash bekor qilindi.');
      return null;
    }
    final String key = _generateKey(url);
    final File cacheFile = await _getPdfCacheFile(url);

    // Keshdan yuklashga urinish
    if (!forceRefresh) {
      final obfuscatedBytesFromHive = _pdfBox.get(key);
      if (obfuscatedBytesFromHive != null) {
        if (kDebugMode) print('PDF Hive dan (obfuskatsiya qilingan) yuklandi: $url');
        return xorBytes(obfuscatedBytesFromHive);
      }

      if (await cacheFile.exists()) {
        try {
          final obfuscatedBytesFromFile = await cacheFile.readAsBytes();
          if (obfuscatedBytesFromFile.isNotEmpty) {
            if (kDebugMode) print('PDF fayl keshidan (obfuskatsiya qilingan) yuklandi: $url');
            await _pdfBox.put(key, obfuscatedBytesFromFile); // Hive ga ham saqlash
            return xorBytes(obfuscatedBytesFromFile);
          } else {
            if (kDebugMode) print('PDF fayl keshidagi fayl bo\'sh: ${cacheFile.path}, o\'chirib tashlanmoqda.');
            await cacheFile.delete();
          }
        } catch (e) {
          if (kDebugMode) print('PDF fayl keshidan o\'qishda xatolik ($url): $e, fayl o\'chirilmoqda.');
          try { await cacheFile.delete(); } catch (_) {}
        }
      }
    }

    // Internetdan yuklash
    try {
      if (kDebugMode) print('PDF (obfuskatsiya qilingan) internetdan yuklanmoqda: $url');
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final obfuscatedBytesFromServer = response.bodyBytes;

        if (obfuscatedBytesFromServer.isEmpty) {
          if (kDebugMode) print('PDF internetdan bo\'sh baytlar bilan keldi: $url');
          throw Exception('Serverdan bo\'sh PDF fayl keldi.');
        }

        await cacheFile.writeAsBytes(obfuscatedBytesFromServer);
        await _pdfBox.put(key, obfuscatedBytesFromServer);
        if (kDebugMode) print('PDF (obfuskatsiya qilingan) internetdan yuklandi va keshga/Hive ga saqlandi: $url');
        return xorBytes(obfuscatedBytesFromServer);
      } else {
        throw Exception('PDF yuklashda xatolik (${response.statusCode}): ${response.reasonPhrase} URL: $url');
      }
    } catch (e) {
      if (kDebugMode) print('PDF yuklashda xatolik ($url): $e');
      return null;
    }
  }

  // PDF ni oflayn saqlash (layk bosish)
  Future<void> savePdfForOffline(Guide guide) async {
    if (guide.documentUrl.isEmpty) {
      if (kDebugMode) print('PDF URL bo\'sh, oflayn saqlash bekor qilindi.');
      return;
    }
    try {
      await loadPdfBytes(guide.documentUrl, forceRefresh: true); // PDF ni majburiy yuklash
      guide.isDownloaded = true;
      if (guide.isInBox) {
        await guide.save(); // Guide holatini yangilash
      } else {
        // Agar guide Hive da bo'lmasa, uni saqlash kerak bo'lishi mumkin.
        // Hozirda guide Category ichida saqlanadi, shuning uchun Category ni yangilash kerak.
        // Bu yerda Category ni topish va uni saqlash biroz murakkabroq bo'lishi mumkin.
        // Oddiylik uchun, Guide ob'ekti doimiy Hive ob'ekti bo'lishi kerak deb hisoblaymiz.
        // Agar Guide to'g'ridan-to'g'ri Hive ob'ekti bo'lmasa, uni parent Category orqali saqlash kerak.
        // Misol uchun:
        // final parentCategory = await _subjectsBox.values.expand((s) => s.categories).firstWhere((c) => c.guides.contains(guide));
        // await parentCategory.save();
      }
      if (kDebugMode) print('PDF oflayn saqlash uchun belgilandi: ${guide.title}');
    } catch (e) {
      if (kDebugMode) print('PDF ni oflayn saqlashda xatolik: $e');
    }
  }

  // PDF ni oflayndan o'chirish (laykni bekor qilish)
  Future<void> removePdfFromOffline(Guide guide) async {
    if (guide.documentUrl.isEmpty) return;
    final String key = _generateKey(guide.documentUrl);
    final File cacheFile = await _getPdfCacheFile(guide.documentUrl);
    try {
      if (_pdfBox.containsKey(key)) {
        await _pdfBox.delete(key);
      }
      if (await cacheFile.exists()) {
        await cacheFile.delete();
      }
      guide.isDownloaded = false;
      if (guide.isInBox) {
        await guide.save();
      }
      if (kDebugMode) print('PDF oflayndan o\'chirildi: ${guide.title}');
    } catch (e) {
      if (kDebugMode) print('PDF ni oflayndan o\'chirishda xatolik: $e');
    }
  }
}