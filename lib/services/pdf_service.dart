import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;
import 'dart:io' show File;
import 'package:path_provider/path_provider.dart';

class PdfService {
  static const int _obfuscationKey = 0x5A;

  static Uint8List _xorBytes(Uint8List bytes) {
    final resultBytes = Uint8List.fromList(bytes);
    for (int i = 0; i < resultBytes.length; i++) {
      resultBytes[i] = resultBytes[i] ^ _obfuscationKey;
    }
    return resultBytes;
  }

  static Future<Uint8List> loadObfuscatedPdfBytes(String pdfUrl) async {
    try {
      final response = await http.get(Uri.parse(pdfUrl));
      if (response.statusCode == 200) {
        return response.bodyBytes;
      } else {
        throw Exception('PDF yuklanmadi: {response.statusCode}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('PDF yuklashda xato: $e');
      }
      throw Exception('PDF yuklashda xato: $e');
    }
  }

  static Future<String?> saveDeobfuscatedPdfTemporarily(Uint8List deobfuscatedBytes) async {
    if (kIsWeb) {
      return null;
    }
    try {
      final directory = await getTemporaryDirectory();
      final filePath = '${directory.path}/${DateTime.now().microsecondsSinceEpoch}.pdf';
      final file = File(filePath);
      await file.writeAsBytes(deobfuscatedBytes);
      return filePath;
    } catch (e) {
      if (kDebugMode) {
        print('De-obfuskatsiya qilingan PDF faylni vaqtincha saqlashda xato: $e');
      }
      return null;
    }
  }

  static Future<void> deleteTemporaryPdf(String? filePath) async {
    if (kIsWeb || filePath == null) {
      return;
    }
    try {
      final file = File(filePath);
      if (await file.exists()) {
        await file.delete();
        if (kDebugMode) {
          print('Vaqtincha PDF fayl o\'chirildi: $filePath');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Vaqtincha PDF faylni o\'chirishda xato: $e');
      }
    }
  }

  static Uint8List xorBytes(Uint8List bytes) => _xorBytes(bytes);
}
