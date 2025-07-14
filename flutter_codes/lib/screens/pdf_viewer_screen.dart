// ignore: unnecessary_import
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

import '../services/pdf_service.dart';
import '../utils/responsive_utils.dart';

// PDF ko'rish ekrani
class PdfViewerScreen extends StatefulWidget {
  final String pdfUrl;
  final String guideTitle;

  const PdfViewerScreen({super.key, required this.pdfUrl, required this.guideTitle});

  @override
  State<PdfViewerScreen> createState() => _PdfViewerScreenState();
}

class _PdfViewerScreenState extends State<PdfViewerScreen> {
  final PdfService _pdfService = PdfService();
  Future<Uint8List?>? _pdfBytesFuture;
  bool _isLoading = true;
  String? _errorMessage;
  final GlobalKey<SfPdfViewerState> _pdfViewerKey = GlobalKey();

  final ValueNotifier<double> _pdfProgress = ValueNotifier(0.0);
  final ValueNotifier<String> _pdfStatus = ValueNotifier("PDF yuklanmoqda...");


  @override
  void initState() {
    super.initState();
    _loadPdf();
  }

  Future<void> _loadPdf({bool forceRefresh = false}) async {
    if(mounted) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
        _pdfProgress.value = 0.0;
        _pdfStatus.value = "PDF yuklanmoqda...";
      });
    }
    try {
      _pdfProgress.value = 0.1;
      _pdfStatus.value = "Fayl keshini tekshirilmoqda...";
      await Future.delayed(const Duration(milliseconds: 300));

      final bytes = await _pdfService.loadPdfBytes(widget.pdfUrl, forceRefresh: forceRefresh);

      _pdfProgress.value = 0.7;
      _pdfStatus.value = "Fayl yuklandi. Ko'rsatishga tayyorlanmoqda...";
      await Future.delayed(const Duration(milliseconds: 300));

      if (bytes != null && bytes.isNotEmpty) {
        _pdfBytesFuture = Future.value(bytes);
        _pdfProgress.value = 1.0;
        _pdfStatus.value = "Tayyor!";
      } else {
        throw Exception("Internetni yoqib qayta yuklashni bosing");
      }
    } catch (e) {
      _pdfBytesFuture = Future.value(null);
      if(mounted) {
        _errorMessage = e.toString();
        _pdfProgress.value = 0.0;
        _pdfStatus.value = "Xatolik yuz berdi!";
      }
      if (kDebugMode) print('Error loading PDF bytes for ${widget.pdfUrl}: $e');
    } finally {
      if(mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.guideTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _loadPdf(forceRefresh: true),
            tooltip: "PDFni qayta yuklash",
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
        child: Center(
          child: _isLoading
              ? Padding(
            padding: EdgeInsets.all(responsiveSize(context, 20.0)),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                SizedBox(
                  width: responsiveSize(context, 60.0),
                  height: responsiveSize(context, 60.0),
                  child: const CircularProgressIndicator(),
                ),
                SizedBox(height: responsiveSize(context, 20.0)),
                ValueListenableBuilder<String>(
                  valueListenable: _pdfStatus,
                  builder: (context, status, child) {
                    return Text(status, textAlign: TextAlign.center, style: Theme.of(context).textTheme.titleMedium);
                  },
                ),
                SizedBox(height: responsiveSize(context, 10.0)),
                ValueListenableBuilder<double>(
                  valueListenable: _pdfProgress,
                  builder: (context, progress, child) {
                    return LinearProgressIndicator(
                      value: progress,
                      minHeight: responsiveSize(context, 8.0),
                      borderRadius: BorderRadius.circular(responsiveSize(context, 4.0)),
                    );
                  },
                ),
              ],
            ),
          )
              : (_errorMessage != null
              ? Padding(
            padding: EdgeInsets.all(responsiveSize(context, 16.0)),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, color: Colors.red, size: responsiveSize(context, 48.0)),
                SizedBox(height: responsiveSize(context, 16.0)),
                Text(
                  "PDFni yuklashda xatolik yuz berdi:",
                  style: Theme.of(context).textTheme.titleLarge,
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: responsiveSize(context, 8.0)),
                Text(
                  _errorMessage!,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.red.shade700, fontSize: responsiveTextSize(context, 14.0)),
                ),
                SizedBox(height: responsiveSize(context, 20.0)),
                ElevatedButton.icon(
                  icon: const Icon(Icons.refresh),
                  label: const Text("Qayta urinish"),
                  onPressed: () => _loadPdf(forceRefresh: true),
                ),
              ],
            ),
          )
              : FutureBuilder<Uint8List?>(
            future: _pdfBytesFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const CircularProgressIndicator();
              } else if (snapshot.hasError || snapshot.data == null || snapshot.data!.isEmpty) {
                return Padding(
                  padding: EdgeInsets.all(responsiveSize(context, 16.0)),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.picture_as_pdf_outlined, color: Colors.grey, size: responsiveSize(context, 48.0)),
                      SizedBox(height: responsiveSize(context, 16.0)),
                      Text(
                        "PDF faylini ko'rsatib bo'lmadi.",
                        style: Theme.of(context).textTheme.titleMedium,
                        textAlign: TextAlign.center,
                      ),
                      if (snapshot.hasError) ...[
                        SizedBox(height: responsiveSize(context, 8.0)),
                        Text(
                          snapshot.error.toString(),
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.orange, fontSize: responsiveTextSize(context, 14.0)),
                        ),
                      ],
                      SizedBox(height: responsiveSize(context, 20.0)),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.refresh),
                        label: const Text("Qayta yuklash"),
                        onPressed: () => _loadPdf(forceRefresh: true),
                      ),
                    ],
                  ),
                );
              }
              // PDF muvaffaqiyatli yuklandi
              return AspectRatio(
                aspectRatio: 9/16,
                child: SfPdfViewer.memory(
                  snapshot.data!,
                  key: _pdfViewerKey,
                ),
              );
            },
          )),
        ),
      ),
    );
  }
}