import 'package:flutter/material.dart';

import '../models/category.dart';
import '../models/guide.dart';
import '../utils/responsive_utils.dart';
import '../widgets/guide_list_card.dart';
import 'about_screen.dart';


// Qo'llanmalar ro'yxati ekrani
class GuideListScreen extends StatefulWidget {
  final Category category;
  final bool offlineMode;
  const GuideListScreen({super.key, required this.category, required this.offlineMode});

  @override
  State<GuideListScreen> createState() => _GuideListScreenState();
}

class _GuideListScreenState extends State<GuideListScreen> {
  late List<Guide> _displayedGuides;

  @override
  void initState() {
    super.initState();
    _filterGuides();
  }

  @override
  void didUpdateWidget(covariant GuideListScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.offlineMode != widget.offlineMode || oldWidget.category != widget.category) {
      _filterGuides();
    }
  }

  void _filterGuides() {
    if (widget.offlineMode) {
      _displayedGuides = widget.category.guides.where((guide) => guide.isDownloaded).toList();
    } else {
      _displayedGuides = widget.category.guides;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.category.name),
      ),
      body: Container( // Container qo'shildi
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/background.png'), // Orqa fon rasmi
            fit: BoxFit.cover,
          ),
        ),
        child: _displayedGuides.isEmpty
            ? Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.book_outlined, size: responsiveSize(context, 80.0), color: Colors.grey),
              SizedBox(height: responsiveSize(context, 16.0)),
              Text(
                widget.offlineMode
                    ? 'Oflayn rejimda mavjud qo\'llanmalar topilmadi. Onlayn rejimga o\'ting yoki darsliklarni yuklab oling.'
                    : 'Qo\'llanmalar mavjud emas.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: responsiveTextSize(context, 18.0), color: Colors.grey),
              ),
            ],
          ),
        )
            : ListView.builder(
          padding: EdgeInsets.all(responsiveSize(context, 8.0)),
          itemCount: _displayedGuides.length,
          itemBuilder: (context, index) {
            final guide = _displayedGuides[index];
            return GuideListCard(guide: guide, offlineMode: widget.offlineMode);
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const AboutScreen()));
        },
        child: const Icon(Icons.phone),
      ),
    );
  }
}