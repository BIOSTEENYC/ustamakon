import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import '../models/guide.dart';
import '../services/pdf_service.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/services.dart';

class GuideViewerScreen extends StatefulWidget {
  final Guide guide;
  const GuideViewerScreen({super.key, required this.guide});

  @override
  State<GuideViewerScreen> createState() => _GuideViewerScreenState();
}

class _GuideViewerScreenState extends State<GuideViewerScreen> {
  Uint8List? _pdfBytes;
  String? _tempFilePath;
  bool _isLoading = true;
  String? _error;
  final GlobalKey<SfPdfViewerState> _pdfViewerKey = GlobalKey();
  late PdfViewerController _pdfViewerController;
  late FocusNode _focusNode;
  double? _firstPageWidth;
  double? _firstPageHeight;

  @override
  void initState() {
    super.initState();
    _pdfViewerController = PdfViewerController();
    _focusNode = FocusNode();
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
        _error = 'PDF yuklashda xato yuz berdi: e.toString()}';
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
    _pdfViewerController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final shortestSide = mediaQuery.size.shortestSide;
    final orientation = mediaQuery.orientation;
    final bool isWearOs = shortestSide < 350 && (mediaQuery.size.width / mediaQuery.size.height > 0.9 && mediaQuery.size.width / mediaQuery.size.height < 1.1);
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
      body: KeyboardListener(
        focusNode: _focusNode,
        autofocus: true,
        onKeyEvent: (KeyEvent event) {
          if (event is KeyDownEvent) {
            if (event.logicalKey == LogicalKeyboardKey.arrowLeft || event.logicalKey == LogicalKeyboardKey.keyA) {
              _pdfViewerController.previousPage();
            } else if (event.logicalKey == LogicalKeyboardKey.arrowRight || event.logicalKey == LogicalKeyboardKey.keyD) {
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
                    ? Stack(
                        children: [
                          SfPdfViewer.memory(
                            _pdfBytes!,
                            key: _pdfViewerKey,
                            controller: _pdfViewerController,
                            pageLayoutMode: pageLayoutMode,
                            scrollDirection: scrollDirection,
                            onDocumentLoaded: (details) {
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
                          if (pageLayoutMode == PdfPageLayoutMode.single && (kIsWeb || orientation == Orientation.landscape))
                            Positioned(
                              left: 10,
                              top: mediaQuery.size.height / 2 - 36,
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
                              top: mediaQuery.size.height / 2 - 36,
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
