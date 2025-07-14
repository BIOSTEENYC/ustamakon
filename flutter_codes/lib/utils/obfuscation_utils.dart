import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

import 'constants.dart';

// Baytlarni XOR operatsiyasi bilan obfuskatsiya qilish
Uint8List xorBytes(Uint8List bytes) {
  final result = Uint8List(bytes.length);
  for (int i = 0; i < bytes.length; i++) {
    result[i] = bytes[i] ^ obfuscationKey;
  }
  return result;
}

// PDF kesh katalogini olish
Future<Directory> getPdfCacheDirectory() async {
  final tempDir = await getTemporaryDirectory();
  final pdfCacheDir = Directory('${tempDir.path}/pdf_cache_v2');
  if (!await pdfCacheDir.exists()) {
    await pdfCacheDir.create(recursive: true);
  }
  return pdfCacheDir;
}