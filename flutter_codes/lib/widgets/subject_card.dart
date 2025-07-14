import 'package:flutter/material.dart';

import '../models/subject.dart';
import '../screens/category_list_screen.dart';
import '../utils/responsive_utils.dart';

// Fan kartochkasi
class SubjectCard extends StatelessWidget {
  final Subject subject;
  final bool offlineMode;
  const SubjectCard({super.key, required this.subject, required this.offlineMode});

  @override
  Widget build(BuildContext context) {
    // Agar topicListUrl bo'sh bo'lsa, kartochka disabled holatda bo'ladi
    // Yoki oflayn rejimda bo'lib, hech qanday yuklangan guide bo'lmasa
    final bool isDisabled = subject.topicListUrl.isEmpty || (offlineMode && subject.categories.every((c) => c.guides.every((g) => !g.isDownloaded)));
    final Color cardColor = isDisabled ? Colors.grey.shade200 : Theme.of(context).cardColor;
    final Color textColor = isDisabled ? Colors.grey.shade500 : Theme.of(context).textTheme.titleMedium!.color!;
    final Color subtitleColor = isDisabled ? Colors.grey.shade400 : Colors.grey.shade600;

    return Card(
      color: cardColor,
      child: InkWell(
        borderRadius: BorderRadius.circular(responsiveSize(context, 12.0)),
        onTap: isDisabled
            ? null
            : () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CategoryListScreen(subject: subject, offlineMode: offlineMode),
            ),
          );
        },
        child: Opacity(
          opacity: isDisabled ? 0.6 : 1.0,
          child: Padding(
            padding: EdgeInsets.all(responsiveSize(context, 16.0)),
            child: Column(
              mainAxisSize: MainAxisSize.min, // Column minimal balandlikni egallaydi
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Ikonka yoki emoji
                SizedBox(
                  height: responsiveSize(context, 60.0),
                  child: subject.emoji.isNotEmpty
                      ? FittedBox(
                    fit: BoxFit.contain,
                    child: Text(subject.emoji, style: TextStyle(fontSize: responsiveTextSize(context, 40.0))),
                  )
                      : (subject.iconUrl.isNotEmpty && Uri.tryParse(subject.iconUrl)?.isAbsolute == true
                      ? Image.network(
                    subject.iconUrl,
                    width: responsiveSize(context, 60.0),
                    height: responsiveSize(context, 60.0),
                    errorBuilder: (c, e, s) => Icon(Icons.broken_image, size: responsiveSize(context, 60.0), color: Colors.grey),
                  )
                      : Icon(Icons.school, size: responsiveSize(context, 60.0), color: Colors.blue)),
                ),
                SizedBox(height: responsiveSize(context, 16.0)),
                // Fan nomi
                Align(
                  alignment: Alignment.center,
                  child: Text(
                    subject.name,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: textColor),
                    // maxLines va overflow olib tashlandi
                  ),
                ),
                SizedBox(height: responsiveSize(context, 8.0)),
                // Kategoriyalar soni
                Text(
                  "${subject.categories.length} kategoriya",
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(color: subtitleColor),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}