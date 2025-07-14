import 'package:flutter/material.dart';

import '../models/guide.dart';
import '../services/pdf_service.dart';
import '../screens/pdf_viewer_screen.dart';
import '../utils/responsive_utils.dart';

// Qo'llanma ro'yxat kartochkasi
class GuideListCard extends StatefulWidget {
  final Guide guide;
  final bool offlineMode;
  const GuideListCard({super.key, required this.guide, required this.offlineMode});

  @override
  State<GuideListCard> createState() => _GuideListCardState();
}

class _GuideListCardState extends State<GuideListCard> {
  final PdfService _pdfService = PdfService();

  @override
  Widget build(BuildContext context) {
    final bool isDisabled = widget.offlineMode && !widget.guide.isDownloaded;
    final Color cardColor = isDisabled ? Colors.grey.shade200 : Theme.of(context).cardColor;
    final Color textColor = isDisabled ? Colors.grey.shade500 : Theme.of(context).textTheme.titleMedium!.color!;
    final Color subtitleColor = isDisabled ? Colors.grey.shade400 : Colors.grey.shade600;

    return Card(
      color: cardColor,
      margin: EdgeInsets.symmetric(vertical: responsiveSize(context, 8.0), horizontal: responsiveSize(context, 8.0)),
      child: InkWell(
        onTap: isDisabled
            ? null
            : () {
          if (widget.guide.documentUrl.isNotEmpty) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PdfViewerScreen(pdfUrl: widget.guide.documentUrl, guideTitle: widget.guide.title),
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text("Bu qo'llanma uchun PDF fayl mavjud emas: ${widget.guide.title}"),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: Opacity(
          opacity: isDisabled ? 0.6 : 1.0,
          child: Padding(
            padding: EdgeInsets.all(responsiveSize(context, 16.0)),
            child: Row(
              children: [
                Text(
                  widget.guide.iconEmoji,
                  style: TextStyle(fontSize: responsiveTextSize(context, 30.0)),
                ),
                SizedBox(width: responsiveSize(context, 16.0)),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.guide.title,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: textColor),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: responsiveSize(context, 4.0)),
                      Text(
                        widget.guide.documentUrl.isNotEmpty ? "Hujjat mavjud" : "Hujjat yo'q",
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: subtitleColor,
                        ),
                      ),
                    ],
                  ),
                ),
                if (widget.guide.documentUrl.isNotEmpty && !widget.offlineMode) // Faqat onlayn rejimda ko'rinadi
                  IconButton(
                    icon: Icon(
                      widget.guide.isDownloaded ? Icons.favorite : Icons.favorite_border,
                      color: widget.guide.isDownloaded ? Colors.red : Colors.grey,
                    ),
                    onPressed: () async {
                      if (widget.guide.isDownloaded) {
                        await _pdfService.removePdfFromOffline(widget.guide);
                      } else {
                        await _pdfService.savePdfForOffline(widget.guide);
                      }
                      setState(() {
                        // Guide ob'ektini yangilash kerak, chunki isDownloaded o'zgardi
                        // Hive ob'ekti bo'lgani uchun, u avtomatik yangilanishi kerak
                      });
                    },
                  ),
                Icon(Icons.arrow_forward_ios, size: responsiveSize(context, 18.0), color: isDisabled ? Colors.grey.shade400 : Colors.grey),
              ],
            ),
          ),
        ),
      ),
    );
  }
}