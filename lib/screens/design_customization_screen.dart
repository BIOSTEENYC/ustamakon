import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/theme_notifier.dart';
import 'package:google_fonts/google_fonts.dart';

class DesignCustomizationScreen extends StatelessWidget {
  const DesignCustomizationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context, listen: false);
    final List<Color> primaryColors = [
      Colors.deepPurple,
      Colors.blue,
      Colors.green,
      Colors.red,
      Colors.orange,
      Colors.pink,
      Colors.teal,
      Colors.brown,
    ];
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dizaynni moslash', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Asosiy rangni tanlang:',
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 1,
                ),
                itemCount: primaryColors.length,
                itemBuilder: (context, index) {
                  final color = primaryColors[index];
                  return GestureDetector(
                    onTap: () {
                      themeNotifier.setCustomPrimaryColor(color);
                      Navigator.pop(context);
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: themeNotifier.customPrimaryColor == color
                              ? Theme.of(context).colorScheme.secondary
                              : Colors.transparent,
                          width: 3,
                        ),
                        boxShadow: [
                          BoxShadow(
                            // ignore: deprecated_member_use
                            color: Color.fromRGBO(0, 0, 0, 0.2),
                            spreadRadius: 1,
                            blurRadius: 5,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Center(
                        child: themeNotifier.customPrimaryColor == color
                            ? Icon(
                                Icons.check,
                                color: color.computeLuminance() > 0.5 ? Colors.black : Colors.white,
                                size: 40,
                              )
                            : null,
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () {
                themeNotifier.setSystemTheme();
                Navigator.pop(context);
              },
              icon: const Icon(Icons.color_lens_outlined),
              label: const Text('Asl ranglarga qaytish'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(40),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
