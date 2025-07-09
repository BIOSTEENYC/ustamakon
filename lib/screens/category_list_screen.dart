// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';

import 'package:glassmorphism/glassmorphism.dart';
import 'package:lottie/lottie.dart';
import '../models/subject.dart';
import '../models/category.dart';
import '../services/data_service.dart';
import 'guide_list_screen.dart';
import 'package:google_fonts/google_fonts.dart';

class CategoryListScreen extends StatefulWidget {
  final Subject subject;
  const CategoryListScreen({super.key, required this.subject});

  @override
  State<CategoryListScreen> createState() => _CategoryListScreenState();
}

class _CategoryListScreenState extends State<CategoryListScreen> {
  late Future<List<Category>> _categoriesFuture;

  @override
  void initState() {
    super.initState();
    _categoriesFuture = DataService.fetchCategories(widget.subject.topicListUrl);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(widget.subject.name, style: GoogleFonts.montserrat(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        elevation: 12,
        child: const Icon(Icons.add, size: 32),
      ),
      body: Stack(
        children: [
          // Gradient + Lottie background
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFa8edea), Color(0xFFfed6e3), Color(0xFFfcb69f)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          Positioned.fill(
              child: Align(
                alignment: Alignment.topCenter,
                child: Lottie.asset(
                  'assets/lottie/party.json',
                  height: 180,
                  fit: BoxFit.cover,
                  repeat: true,
                ),
              ),
          ),
          // Glassmorphism list
          FutureBuilder<List<Category>>(
            future: _categoriesFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      'Mavzularni yuklashda xato yuz berdi: ${snapshot.error}',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Theme.of(context).colorScheme.error, fontSize: 16),
                    ),
                  ),
                );
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(child: Text('Hech qanday mavzu topilmadi.'));
              } else {
                return ListView.builder(
                  padding: const EdgeInsets.only(top: 200, left: 16, right: 16, bottom: 32),
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    final category = snapshot.data![index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12.0),
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => GuideListScreen(category: category),
                            ),
                          );
                        },
                          child: GlassmorphicContainer(
                            width: double.infinity,
                            height: 100,
                            borderRadius: 24,
                            blur: 20,
                            alignment: Alignment.center,
                            border: 2,
                            linearGradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Color.fromRGBO(255, 255, 255, 0.25),
                                Color.fromRGBO(255, 255, 255, 0.05),
                              ],
                              stops: const [0.1, 1],
                            ),
                            borderGradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Color.fromRGBO(255, 64, 129, 0.5),
                                Color.fromRGBO(68, 138, 255, 0.5),
                              ],
                            ),
                            child: ListTile(
                              trailing: const Icon(Icons.arrow_forward_ios_rounded, color: Colors.purpleAccent),
                              leading: Hero(
                                tag: 'cat_icon_${(category.id != null && category.id!.isNotEmpty) ? category.id : (category.categoryName.isNotEmpty ? category.categoryName : (category.name?.isNotEmpty == true ? category.name : category.hashCode))}',
                                child: CircleAvatar(
                                  backgroundColor: Color.fromRGBO(255, 255, 255, 0.7),
                                  radius: 28,
                                  child: const Icon(Icons.category, color: Colors.purpleAccent, size: 32),
                                ),
                              ),
                              title: Text(
                                category.name ?? category.categoryName,
                                style: GoogleFonts.montserrat(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                              subtitle: Text(
                                category.description ?? '',
                                style: GoogleFonts.montserrat(
                                  fontSize: 14,
                                  color: Colors.black54,
                                ),
                              ),
                            ),
                          ),
                      ),
                    );
                  },
                );
              }
            },
          ),
        ],
      ),
      bottomNavigationBar: _buildAnimatedBottomBar(),
    );
  }

  Widget _buildAnimatedBottomBar() {
    return Container(
      decoration: BoxDecoration(
        color: Color.fromRGBO(255, 255, 255, 0.1),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        boxShadow: [
          BoxShadow(
            color: Color.fromRGBO(0, 0, 0, 0.1),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Bosh sahifa'),
          BottomNavigationBarItem(icon: Icon(Icons.star), label: 'Sevimlilar'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Sozlamalar'),
        ],
        currentIndex: 0,
        onTap: (i) {},
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
    );
  }
}
