import 'package:flutter/material.dart';
import '../models/category.dart';
import '../models/guide.dart';
import 'guide_viewer_screen.dart';
import 'package:google_fonts/google_fonts.dart';

class GuideListScreen extends StatelessWidget {
  final Category category;
  const GuideListScreen({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(category.categoryName, style: const TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: category.guides.length,
        itemBuilder: (context, index) {
          final guide = category.guides[index];
          return _buildGuideCard(context, guide, index);
        },
      ),
    );
  }

  Widget _buildGuideCard(BuildContext context, Guide guide, int index) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => GuideViewerScreen(guide: guide),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Hero(
                tag: 'guide-emoji-guide.title}-$index',
                child: Text(
                  guide.iconEmoji,
                  style: const TextStyle(fontSize: 30),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  guide.title,
                  style: GoogleFonts.inter(
                    fontSize: 17,
                    fontWeight: FontWeight.w400,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ),
              Icon(Icons.picture_as_pdf, color: Theme.of(context).colorScheme.secondary),
            ],
          ),
        ),
      ),
    );
  }
}
