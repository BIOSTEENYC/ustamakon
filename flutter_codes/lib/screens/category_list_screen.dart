import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

import '../models/category.dart';
import '../models/subject.dart';
import '../utils/responsive_utils.dart';
import '../widgets/category_card.dart';
import 'about_screen.dart';


// Kategoriyalar ro'yxati ekrani
class CategoryListScreen extends StatefulWidget {
  final Subject subject;
  final bool offlineMode;
  const CategoryListScreen({super.key, required this.subject, required this.offlineMode});

  @override
  State<CategoryListScreen> createState() => _CategoryListScreenState();
}

class _CategoryListScreenState extends State<CategoryListScreen> {
  late List<Category> _displayedCategories;

  @override
  void initState() {
    super.initState();
    _filterCategories();
  }

  @override
  void didUpdateWidget(covariant CategoryListScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.offlineMode != widget.offlineMode || oldWidget.subject != widget.subject) {
      _filterCategories();
    }
  }

  void _filterCategories() {
    if (widget.offlineMode) {
      _displayedCategories = widget.subject.categories.where((category) =>
          category.guides.any((guide) => guide.isDownloaded)).toList();
    } else {
      _displayedCategories = widget.subject.categories;
    }
  }

  @override
  Widget build(BuildContext context) {
    final shortestSide = MediaQuery.of(context).size.shortestSide;
    final crossAxisCount = shortestSide < 600 ? 2 : (shortestSide < 900 ? 3 : 4);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.subject.name),
      ),
      body: Container( // Container qo'shildi
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/background.png'), // Orqa fon rasmi
            fit: BoxFit.cover,
          ),
        ),
        child: _displayedCategories.isEmpty
            ? Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.category_outlined, size: responsiveSize(context, 80.0), color: Colors.grey),
              SizedBox(height: responsiveSize(context, 16.0)),
              Text(
                widget.offlineMode
                    ? 'Oflayn rejimda mavjud kategoriyalar topilmadi. Onlayn rejimga o\'ting yoki darsliklarni yuklab oling.'
                    : 'Kategoriyalar mavjud emas.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: responsiveTextSize(context, 18.0), color: Colors.grey),
              ),
            ],
          ),
        )
            : MasonryGridView.builder(
          padding: EdgeInsets.all(responsiveSize(context, 16.0)),
          gridDelegate: SliverSimpleGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
          ),
          mainAxisSpacing: responsiveSize(context, 16.0),
          crossAxisSpacing: responsiveSize(context, 16.0),
          itemCount: _displayedCategories.length,
          itemBuilder: (context, index) {
            final category = _displayedCategories[index];
            return CategoryCard(category: category, offlineMode: widget.offlineMode);
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const AboutScreen()));
        },
        child: const Icon(Icons.language),
      ),
    );
  }
}