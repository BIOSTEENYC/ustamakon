import 'package:flutter/material.dart';

import '../models/category.dart';
import '../screens/guide_list_screen.dart';
import '../utils/responsive_utils.dart';

// Kategoriya kartochkasi
class CategoryCard extends StatelessWidget {
  final Category category;
  final bool offlineMode;
  const CategoryCard({super.key, required this.category, required this.offlineMode});

  @override
  Widget build(BuildContext context) {
    // Agar oflayn rejimda bo'lib, hech qanday yuklangan guide bo'lmasa, kartochka disabled
    final bool isDisabled = offlineMode && category.guides.every((g) => !g.isDownloaded);
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
              builder: (context) => GuideListScreen(category: category, offlineMode: offlineMode),
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
                SizedBox(
                  height: responsiveSize(context, 60.0),
                  child: FittedBox(
                    fit: BoxFit.contain,
                    child: Text(
                      category.iconEmoji,
                      style: TextStyle(fontSize: responsiveTextSize(context, 60.0)),
                    ),
                  ),
                ),
                SizedBox(height: responsiveSize(context, 16.0)),
                Align(
                  alignment: Alignment.center,
                  child: Text(
                    category.name,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: textColor),
                    // maxLines va overflow olib tashlandi
                  ),
                ),
                SizedBox(height: responsiveSize(context, 8.0)),
                Text(
                  "${category.guides.length} qo'llanma",
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