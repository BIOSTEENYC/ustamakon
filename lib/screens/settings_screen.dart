import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/theme_notifier.dart';
import 'design_customization_screen.dart';
import 'package:google_fonts/google_fonts.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sozlamalar', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Mavzu',
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Tungi rejim',
                        style: GoogleFonts.inter(fontSize: 16),
                      ),
                      Switch(
                        value: themeNotifier.isDarkMode,
                        onChanged: (value) {
                          themeNotifier.toggleTheme(value);
                        },
                        activeColor: Theme.of(context).colorScheme.secondary,
                        inactiveThumbColor: Theme.of(context).colorScheme.primary.withAlpha((255 * 0.5).round()),
                        inactiveTrackColor: Theme.of(context).colorScheme.primary.withAlpha((255 * 0.2).round()),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton.icon(
                    onPressed: () {
                      themeNotifier.setSystemTheme();
                    },
                    icon: const Icon(Icons.brightness_auto),
                    label: const Text('Tizim mavzusiga o\'tish'),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size.fromHeight(40),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Dizaynni moslashtirish',
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Bu yerda kelajakda ilova ranglari, shriftlari va boshqa vizual elementlarni o\'zgartirish imkoniyatlari qo\'shiladi. Hozircha asosiy rangni o\'zgartirishingiz mumkin.',
                    textAlign: TextAlign.justify,
                    style: GoogleFonts.inter(fontSize: 14, color: Theme.of(context).colorScheme.onSurface.withAlpha((255 * 0.7).round())),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const DesignCustomizationScreen()),
                      );
                    },
                    icon: const Icon(Icons.palette),
                    label: const Text('Asosiy rangni tanlash'),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size.fromHeight(40),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
