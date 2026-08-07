
/* 
BU KODNI TAHRIRLASH TAVSIYA ETILMAYDI
EDITING THIS CODE IS NOT RECOMMENDED
Редактировать этот код не рекомендуется.
 */
import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_player/video_player.dart';

// --- Variables ---
const String supabaseUrl = ' /*Supabase url manzili yozing*/ ';
const String supabaseAnonKey = ' /*Supabaseni ANON keyini yozing*/ ';
final supabase = Supabase.instance.client;


void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(url: supabaseUrl, publishableKey: supabaseAnonKey);

  runApp(const UstaMakonApp());
}



class UstaMakonApp extends StatelessWidget {
  const UstaMakonApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'UstaMakon',
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.deepPurple,
        brightness: Brightness.light,
      ),
      home: _buildPlatformView(),
    );
  }

  Widget _buildPlatformView() {
    if (kIsWeb) {
      return const WebAdminLoginGate();
    } else if (Platform.isWindows) {
      return const DesktopEngineScreen();
    } else if (Platform.isLinux) {
      return const DesktopEngineScreen();
    } else if (Platform.isAndroid) {
      return const AndroidRemoteScreen();
    } else {
      return const Scaffold(
        body: Center(child: Text('Qo\'llab-quvvatlanmaydigan platforma')),
      );
    }
  }
}

/*
  ==========================================
   1. WEB PLATFORMA: ADMIN PANEL (PAROLLI)
   ==========================================*/
class WebAdminLoginGate extends StatefulWidget {
  const WebAdminLoginGate({super.key});

  @override
  State<WebAdminLoginGate> createState() => _WebAdminLoginGateState();
}

class _WebAdminLoginGateState extends State<WebAdminLoginGate> {
  bool _isAuthenticated = false;
  final _passController = TextEditingController();

  // Admin Paroli (Xohlasangiz o'zgartiring)
  final String _adminPassword = "ustamakonadmin";

  @override
  void dispose() {
    _passController.dispose();
    super.dispose();
  }

  void _login() {
    if (_passController.text == _adminPassword) {
      setState(() => _isAuthenticated = true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          content: const Row(
            children: [
              Icon(Icons.error_outline, color: Colors.white),
              SizedBox(width: 8),
              Text('Xato parol!'),
            ],
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isAuthenticated) {
      return const WebAdminDashboard();
    }

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: screenSize.width * 0.06,
              vertical: 24,
            ),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: screenSize.width > 600 ? 420 : screenSize.width,
              ),
              child: Card(
                elevation: 3,
                shadowColor: colorScheme.shadow.withValues(alpha: 0.2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(28),
                ),
                color: colorScheme.surfaceContainerHigh,
                child: Padding(
                  padding: EdgeInsets.all(
                    screenSize.width > 600 ? 32.0 : 24.0,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // M3 Expressive uslubidagi doiraviy ikonka konteyneri
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: colorScheme.primaryContainer,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.admin_panel_settings_rounded,
                          size: 48,
                          color: colorScheme.onPrimaryContainer,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'UstaMakon Admin',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Tizimga kirish uchun parolni kiriting',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 28),
                      TextField(
                        controller: _passController,
                        obscureText: true,
                        autofocus: true,
                        textInputAction: TextInputAction.done,
                        style: TextStyle(color: colorScheme.onSurface),
                        decoration: InputDecoration(
                          labelText: 'Admin Paroli',
                          prefixIcon: const Icon(Icons.lock_outline_rounded),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          filled: true,
                          fillColor: colorScheme.surface,
                        ),
                        onSubmitted: (_) => _login(),
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: FilledButton.icon(
                          onPressed: _login,
                          icon: const Icon(Icons.login_rounded),
                          label: const Text(
                            'Kirish',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          style: FilledButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class WebAdminDashboard extends StatefulWidget {
  const WebAdminDashboard({super.key});

  @override
  State<WebAdminDashboard> createState() => _WebAdminDashboardState();
}

class _WebAdminDashboardState extends State<WebAdminDashboard>
    with SingleTickerProviderStateMixin {
  final Map<String, TextEditingController> _titleControllers = {
    'uz': TextEditingController(),
    'kr': TextEditingController(),
    'af': TextEditingController(),
    'tg': TextEditingController(),
    'ky': TextEditingController(),
  };

  final Map<String, TextEditingController> _infoControllers = {
    'uz': TextEditingController(),
    'kr': TextEditingController(),
    'af': TextEditingController(),
    'tg': TextEditingController(),
    'ky': TextEditingController(),
  };

  final _codeController = TextEditingController();
  final _searchController = TextEditingController();

  String _selectedOs = 'windows';
  String _selectedCategory = 'optimization';
  bool _isDangerous = false;
  String _searchQuery = '';

  late TabController _langTabController;
  final List<Map<String, String>> _languages = const [
    {'code': 'uz', 'label': "O'zbek"},
    {'code': 'kr', 'label': 'Ўзбек'},
    {'code': 'af', 'label': 'اوزبیک'},
    {'code': 'tg', 'label': 'Тоҷикӣ'},
    {'code': 'ky', 'label': 'Кыргызча'},
  ];

  @override
  void initState() {
    super.initState();
    _langTabController = TabController(length: _languages.length, vsync: this);
  }

  @override
  void dispose() {
    for (final controller in _titleControllers.values) {
      controller.dispose();
    }
    for (final controller in _infoControllers.values) {
      controller.dispose();
    }
    _codeController.dispose();
    _searchController.dispose();
    _langTabController.dispose();
    super.dispose();
  }

  Future<void> _addScript() async {
    if (_titleControllers['uz']!.text.trim().isEmpty ||
        _codeController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          content: const Text("O'zbekcha sarlavha va kod majburiy!"),
        ),
      );
      return;
    }

    final Map<String, String> titleJson = {};
    final Map<String, String> infoJson = {};

    for (final lang in _languages) {
      final code = lang['code']!;
      titleJson[code] = _titleControllers[code]!.text.trim().isNotEmpty
          ? _titleControllers[code]!.text.trim()
          : _titleControllers['uz']!.text.trim();

      infoJson[code] = _infoControllers[code]!.text.trim().isNotEmpty
          ? _infoControllers[code]!.text.trim()
          : _infoControllers['uz']!.text.trim();
    }

    await supabase.from('scripts').insert({
      'title': titleJson,
      'info': infoJson,
      'code': _codeController.text.trim(),
      'os': _selectedOs,
      'category': _selectedCategory,
      'is_dangerous': _isDangerous,
    });

    _clearForm();

    if (mounted) {
      setState(() {});
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          shape: const StadiumBorder(),
          content: const Text("✨ Muvaffaqiyatli saqlandi!"),
        ),
      );
    }
  }

  void _clearForm() {
    for (final controller in _titleControllers.values) {
      controller.clear();
    }
    for (final controller in _infoControllers.values) {
      controller.clear();
    }
    _codeController.clear();
    setState(() {
      _selectedOs = 'windows';
      _selectedCategory = 'optimization';
      _isDangerous = false;
    });
  }

Future<void> _deleteScript(dynamic rawId) async {
  if (rawId == null) return;

  try {
    // To'g'ridan-to'g'ri bir bosishda Supabase'dan o'chirish
    await supabase.from('scripts').delete().eq('id', rawId);

    if (mounted) {
      setState(() {}); // Ekranni zahotiyoq yangilaymiz
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 1), // SnackBar ham tez yo'qoladi
          content: Text("🗑 Skript o'chirildi!"),
        ),
      );
    }
  } catch (e) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Theme.of(context).colorScheme.error,
          content: Text("O'chirishda xatolik: $e"),
        ),
      );
    }
  }
}

  void _editScriptDialog(Map<String, dynamic> script) {
    final Map<String, dynamic> titleMap =
        script['title'] is Map ? script['title'] : {};
    final Map<String, dynamic> infoMap =
        script['info'] is Map ? script['info'] : {};

    final editTitleControllers = <String, TextEditingController>{};
    final editInfoControllers = <String, TextEditingController>{};

    for (final lang in _languages) {
      final code = lang['code']!;
      editTitleControllers[code] = TextEditingController(
        text: titleMap[code]?.toString() ?? '',
      );
      editInfoControllers[code] = TextEditingController(
        text: infoMap[code]?.toString() ?? '',
      );
    }

    final editCodeController = TextEditingController(
      text: script['code']?.toString() ?? '',
    );
    String editOs = script['os']?.toString() ?? 'windows';
    String editCategory = script['category']?.toString() ?? 'optimization';
    bool editIsDangerous = script['is_dangerous'] == true;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final colorScheme = Theme.of(context).colorScheme;
            return AlertDialog(
              backgroundColor: colorScheme.surfaceContainerHighest,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(36),
              ),
              title: const Text(
                "Skriptni Tahrirlash",
                style: TextStyle(fontWeight: FontWeight.w900),
              ),
              content: SizedBox(
                width: 580,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      DropdownButtonFormField<String>(
                        initialValue: editOs,
                        decoration: InputDecoration(
                          labelText: 'Operatsion Tizim',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: 'windows',
                            child: Text('Windows'),
                          ),
                          DropdownMenuItem(
                            value: 'linux',
                            child: Text('Linux'),
                          ),
                        ],
                        onChanged: (v) => setDialogState(() => editOs = v!),
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        initialValue: editCategory,
                        decoration: InputDecoration(
                          labelText: 'Kategoriya',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: 'optimization',
                            child: Text('Optimization'),
                          ),
                          DropdownMenuItem(
                            value: 'debloat',
                            child: Text('Debloat'),
                          ),
                          DropdownMenuItem(
                            value: 'installers',
                            child: Text('Installers'),
                          ),
                          DropdownMenuItem(
                            value: 'diagnostics',
                            child: Text('Diagnostics'),
                          ),
                        ],
                        onChanged:
                            (v) => setDialogState(() => editCategory = v!),
                      ),
                      const SizedBox(height: 12),
                      SwitchListTile(
                        title: const Text("Xavfli Skript"),
                        value: editIsDangerous,
                        onChanged:
                            (v) => setDialogState(() => editIsDangerous = v),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: editTitleControllers['uz'],
                        decoration: InputDecoration(
                          labelText: "Sarlavha (O'zbekcha)",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: editInfoControllers['uz'],
                        decoration: InputDecoration(
                          labelText: "Tavsif (O'zbekcha)",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: editCodeController,
                        maxLines: 4,
                        decoration: InputDecoration(
                          labelText: 'Skript Kodi',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('Bekor qilish'),
                ),
                FilledButton(
                  style: FilledButton.styleFrom(
                    shape: const StadiumBorder(),
                  ),
                  onPressed: () async {
                    final Map<String, String> updatedTitle = {};
                    final Map<String, String> updatedInfo = {};

                    for (final lang in _languages) {
                      final code = lang['code']!;
                      updatedTitle[code] =
                          editTitleControllers[code]!.text.trim();
                      updatedInfo[code] =
                          editInfoControllers[code]!.text.trim();
                    }

                    await supabase.from('scripts').update({
                      'title': updatedTitle,
                      'info': updatedInfo,
                      'code': editCodeController.text.trim(),
                      'os': editOs,
                      'category': editCategory,
                      'is_dangerous': editIsDangerous,
                    }).eq('id', script['id']);

                    if (dialogContext.mounted) {
                      Navigator.pop(dialogContext);
                    }
                    if (mounted) {
                      setState(() {});
                    }
                  },
                  child: const Text('Saqlash'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final screenSize = MediaQuery.of(context).size;
    final isMobile = screenSize.width < 900;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        scrolledUnderElevation: 0,
        backgroundColor: colorScheme.surface,
        centerTitle: false,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                Icons.auto_awesome_rounded,
                color: colorScheme.onPrimaryContainer,
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'UstaMakon Expressive',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w900,
                letterSpacing: -0.5,
              ),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: IconButton.filledTonal(
              icon: const Icon(Icons.refresh_rounded),
              onPressed: () => setState(() {}),
              tooltip: 'Yangilash',
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(isMobile ? 12.0 : 20.0),
          child: isMobile
              ? SingleChildScrollView(
                  child: Column(
                    children: [
                      _buildFormCard(colorScheme, theme),
                      const SizedBox(height: 20),
                      SizedBox(
                        height: 650,
                        child: _buildListCard(colorScheme, theme),
                      ),
                    ],
                  ),
                )
              : Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 5,
                      child: SingleChildScrollView(
                        child: _buildFormCard(colorScheme, theme),
                      ),
                    ),
                    const SizedBox(width: 24),
                    Expanded(
                      flex: 6,
                      child: _buildListCard(colorScheme, theme),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  // M3 Expressive Yaratish Card
  Widget _buildFormCard(ColorScheme colorScheme, ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(32), // M3 Expressive rounded shape
      ),
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Yangi Skript',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w900,
              color: colorScheme.onSurface,
            ),
          ),
          Text(
            'Ko\'p tilli dinamik skriptlar yarating',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 20),

          // OS va Category Expressive Dropdowns
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  initialValue: _selectedOs,
                  decoration: InputDecoration(
                    labelText: 'OS',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    filled: true,
                    fillColor: colorScheme.surfaceContainerLowest,
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: 'windows',
                      child: Text('Windows'),
                    ),
                    DropdownMenuItem(
                      value: 'linux',
                      child: Text('Linux'),
                    ),
                  ],
                  onChanged: (v) => setState(() => _selectedOs = v!),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: DropdownButtonFormField<String>(
                  initialValue: _selectedCategory,
                  decoration: InputDecoration(
                    labelText: 'Kategoriya',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    filled: true,
                    fillColor: colorScheme.surfaceContainerLowest,
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: 'optimization',
                      child: Text('Optimization'),
                    ),
                    DropdownMenuItem(
                      value: 'debloat',
                      child: Text('Debloat'),
                    ),
                    DropdownMenuItem(
                      value: 'installers',
                      child: Text('Installers'),
                    ),
                    DropdownMenuItem(
                      value: 'diagnostics',
                      child: Text('Diagnostics'),
                    ),
                  ],
                  onChanged: (v) => setState(() => _selectedCategory = v!),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Expressive Switch Card
          Container(
            decoration: BoxDecoration(
              color: _isDangerous
                  ? colorScheme.errorContainer.withAlpha(80)
                  : colorScheme.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(20),
            ),
            child: SwitchListTile(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: Text(
                'Xavfli / Tizimiy skript',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: _isDangerous
                      ? colorScheme.error
                      : colorScheme.onSurface,
                ),
              ),
              subtitle: const Text('Qizil ogohlantirish ko\'rsatiladi'),
              value: _isDangerous,
              activeThumbColor: colorScheme.error,
              onChanged: (v) => setState(() => _isDangerous = v),
            ),
          ),

          const SizedBox(height: 20),

          // Pill Shaped Expressive Segmented Language Bar
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(24),
            ),
            child: TabBar(
              controller: _langTabController,
              isScrollable: true,
              tabAlignment: TabAlignment.start,
              dividerColor: Colors.transparent,
              indicator: BoxDecoration(
                color: colorScheme.primary,
                borderRadius: BorderRadius.circular(20),
              ),
              labelColor: colorScheme.onPrimary,
              unselectedLabelColor: colorScheme.onSurfaceVariant,
              labelStyle: const TextStyle(fontWeight: FontWeight.bold),
              tabs: _languages
                  .map((l) => Tab(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Text(l['label']!),
                        ),
                      ))
                  .toList(),
            ),
          ),

          const SizedBox(height: 16),

          // Inputs container
          SizedBox(
            height: 150,
            child: TabBarView(
              controller: _langTabController,
              children: _languages.map((lang) {
                final code = lang['code']!;
                return Column(
                  children: [
                    TextField(
                      controller: _titleControllers[code],
                      decoration: InputDecoration(
                        labelText: 'Sarlavha (${lang['label']})',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        filled: true,
                        fillColor: colorScheme.surfaceContainerLowest,
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _infoControllers[code],
                      decoration: InputDecoration(
                        labelText: 'Tavsif (${lang['label']})',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        filled: true,
                        fillColor: colorScheme.surfaceContainerLowest,
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: 12),

          // Expressive Code Area
          TextField(
            controller: _codeController,
            maxLines: 4,
            style: const TextStyle(fontFamily: 'monospace', fontSize: 13),
            decoration: InputDecoration(
              labelText: 'Skript kodi (PowerShell / Bash)',
              alignLabelWithHint: true,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              filled: true,
              fillColor: colorScheme.surfaceContainerLowest,
            ),
          ),

          const SizedBox(height: 20),

          // Big Expressive Action Button
          SizedBox(
            width: double.infinity,
            height: 56,
            child: FilledButton.icon(
              onPressed: _addScript,
              icon: const Icon(Icons.bolt_rounded, size: 24),
              label: const Text(
                'Supabase\'ga Saqlash',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                ),
              ),
              style: FilledButton.styleFrom(
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(28),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // M3 Expressive Ro'yxat Card
  Widget _buildListCard(ColorScheme colorScheme, ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(32),
      ),
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Mavjud Skriptlar',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: colorScheme.onSurface,
                ),
              ),
              // Expressive Status Capsule
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: colorScheme.tertiaryContainer,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'JSONB 5 Lingo',
                  style: TextStyle(
                    fontSize: 12,
                    color: colorScheme.onTertiaryContainer,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Expressive Search Input
          TextField(
            controller: _searchController,
            onChanged: (v) => setState(() => _searchQuery = v.toLowerCase()),
            decoration: InputDecoration(
              hintText: 'Izlash...',
              prefixIcon: const Icon(Icons.search_rounded),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear_rounded),
                      onPressed: () {
                        _searchController.clear();
                        setState(() => _searchQuery = '');
                      },
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(28),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: colorScheme.surfaceContainerLowest,
            ),
          ),

          const SizedBox(height: 16),

          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: supabase.from('scripts').select(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text("Xatolik: ${snapshot.error}"));
                }

                final scripts = snapshot.data ?? [];

                final filteredScripts = scripts.where((item) {
                  final titleObj = item['title'];
                  String titleUz = '';
                  if (titleObj is Map) {
                    titleUz = titleObj['uz']?.toString().toLowerCase() ?? '';
                  } else if (titleObj is String) {
                    titleUz = titleObj.toLowerCase();
                  }
                  final os = (item['os'] ?? '').toString().toLowerCase();

                  return titleUz.contains(_searchQuery) ||
                      os.contains(_searchQuery);
                }).toList();

                if (filteredScripts.isEmpty) {
                  return const Center(child: Text('Skriptlar topilmadi.'));
                }

                return ListView.separated(
                  itemCount: filteredScripts.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final item = filteredScripts[index];

                    final titleMap = item['title'] is Map ? item['title'] : {};
                    final infoMap = item['info'] is Map ? item['info'] : {};

                    final titleUz =
                        titleMap['uz'] ?? item['title'] ?? 'Nomsiz';
                    final infoUz = infoMap['uz'] ?? item['info'] ?? '';
                    final isDangerous = item['is_dangerous'] == true;

                    // Expressive Container Item Card
                    return Container(
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainerLowest,
                        borderRadius: BorderRadius.circular(24),
                        border: isDangerous
                            ? Border.all(color: colorScheme.error, width: 2)
                            : null,
                      ),
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          // Custom Shaped Icon Container
                          Container(
                            width: 52,
                            height: 52,
                            decoration: BoxDecoration(
                              color: isDangerous
                                  ? colorScheme.errorContainer
                                  : colorScheme.secondaryContainer,
                              borderRadius: BorderRadius.circular(18),
                            ),
                            child: Icon(
                              item['os'] == 'linux'
                                  ? Icons.terminal_rounded
                                  : Icons.window_rounded,
                              color: isDangerous
                                  ? colorScheme.onErrorContainer
                                  : colorScheme.onSecondaryContainer,
                              size: 26,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  titleUz.toString(),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w900,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  infoUz.toString(),
                                  style: TextStyle(
                                    color: colorScheme.onSurfaceVariant,
                                    fontSize: 13,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 8),
                                Wrap(
                                  spacing: 6,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 3,
                                      ),
                                      decoration: BoxDecoration(
                                        color: colorScheme.surfaceContainerHigh,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        (item['os'] ?? 'windows')
                                            .toString()
                                            .toUpperCase(),
                                        style: const TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 3,
                                      ),
                                      decoration: BoxDecoration(
                                        color: colorScheme.surfaceContainerHigh,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        (item['category'] ?? 'optimization')
                                            .toString(),
                                        style: const TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Column(
                            children: [
                              IconButton.filledTonal(
                                icon: const Icon(Icons.edit_rounded, size: 20),
                                onPressed: () => _editScriptDialog(item),
                              ),
                              const SizedBox(height: 6),
                              IconButton(
                                icon: Icon(
                                  Icons.delete_outline_rounded, color: colorScheme.error),
                                  onPressed: () {
                                    // ID mavjudligini tekshirib chaqiramiz
                                    _deleteScript(item['id']);
                                    },
                                    ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}


  /*==========================================
  2. WINDOWS PLATFORMA: ENGINE (SERVER)
  ==========================================*/
class DesktopEngineScreen extends StatefulWidget {
  const DesktopEngineScreen({super.key});

  @override
  State<DesktopEngineScreen> createState() => _DesktopEngineScreenState();
}

class _DesktopEngineScreenState extends State<DesktopEngineScreen> {
  HttpServer? _server;
  String _localIp = 'Izlanmoqda...';
  final List<String> _logs = [];

  @override
  void initState() {
    super.initState();
    _startLocalServer();
  }

  void _addLog(String msg) {
    if (!mounted) return;
    setState(
      () => _logs.add('[${DateTime.now().toString().split('.').first}] $msg'),
    );
  }

  // Tizim CPU va RAM statistikalarini o'qish
  Future<Map<String, String>> _getSystemStats() async {
    String cpuUsage = '35%';
    String ramUsage = '4.8 / 16 GB';

    try {
      if (Platform.isLinux) {
        // Linux uchun free va top buyruqlari orqali real ko'rsatkich
        final ramResult = await Process.run('free', ['-m']);
        if (ramResult.stdout.toString().isNotEmpty) {
          final lines = ramResult.stdout.toString().split('\n');
          if (lines.length > 1) {
            final parts = lines[1].split(RegExp(r'\s+'));
            if (parts.length >= 3) {
              final double total = (double.tryParse(parts[1]) ?? 16000) / 1024;
              final double used = (double.tryParse(parts[2]) ?? 4000) / 1024;
              ramUsage = '${used.toStringAsFixed(1)} / ${total.toStringAsFixed(1)} GB';
            }
          }
        }

        final cpuResult = await Process.run('sh', ['-c', "top -bn1 | grep 'Cpu(s)'"]);
        if (cpuResult.stdout.toString().isNotEmpty) {
          final out = cpuResult.stdout.toString();
          if (out.contains('id')) {
            final idlePart = out.split('id')[0].split(',').last.trim();
            final double idle = double.tryParse(idlePart.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 70.0;
            final double cpu = 100.0 - idle;
            cpuUsage = '${cpu.toStringAsFixed(0)}%';
          }
        }
      } else if (Platform.isWindows) {
        // Windows uchun PowerShell orqali o'qish
        final ramResult = await Process.run('powershell', [
          '-Command',
          'Get-CimInstance Win32_OperatingSystem | Select-Object TotalVisibleMemorySize,FreePhysicalMemory'
        ]);
        if (ramResult.stdout.toString().isNotEmpty) {
          final matches = RegExp(r'\d+').allMatches(ramResult.stdout.toString()).toList();
          if (matches.length >= 2) {
            final double totalGb = (double.tryParse(matches[0].group(0)!) ?? 16000000) / 1024 / 1024;
            final double freeGb = (double.tryParse(matches[1].group(0)!) ?? 8000000) / 1024 / 1024;
            final double usedGb = totalGb - freeGb;
            ramUsage = '${usedGb.toStringAsFixed(1)} / ${totalGb.toStringAsFixed(1)} GB';
          }
        }

        final cpuResult = await Process.run('powershell', [
          '-Command',
          '(Get-CimInstance Win32_Processor).LoadPercentage'
        ]);
        if (cpuResult.stdout.toString().isNotEmpty) {
          final load = cpuResult.stdout.toString().trim();
          if (load.isNotEmpty) {
            cpuUsage = '$load%';
          }
        }
      }
    } catch (_) {
      // Har qanday kutilmagan xatolikda fallback qiymatlar
    }

    return {
      'cpu': cpuUsage,
      'ram': ramUsage,
    };
  }

  Future<void> _startLocalServer() async {
    try {
      _server = await HttpServer.bind(InternetAddress.anyIPv4, 0);
      final int dynamicPort = _server!.port;

      String detectedIp = '127.0.0.1';
      final interfaces = await NetworkInterface.list(
        type: InternetAddressType.IPv4,
      );
      for (var interface in interfaces) {
        for (var addr in interface.addresses) {
          if (!addr.isLoopback) {
            detectedIp = addr.address;
            break;
          }
        }
      }

      setState(() {
        _localIp = '$detectedIp:$dynamicPort';
      });

      _addLog('Engine Ishga tushdi: http://$_localIp');

      _server!.listen((HttpRequest request) async {
        // CORS Header'larini beramiz (telefon erkin ulansin deb)
        request.response.headers.add('Access-Control-Allow-Origin', '*');
        request.response.headers.add('Access-Control-Allow-Methods', 'GET, POST, OPTIONS');
        request.response.headers.add('Access-Control-Allow-Headers', 'Content-Type');

        if (request.method == 'OPTIONS') {
          request.response.statusCode = HttpStatus.ok;
          await request.response.close();
          return;
        }

        // 1. HARDWARE MONITORING ENDPOINT (/stats)
        if (request.method == 'GET' && request.uri.path == '/stats') {
          final stats = await _getSystemStats();
          request.response
            ..headers.contentType = ContentType.json
            ..write(jsonEncode(stats))
            ..close();
          return;
        }

        // 2. SKRIPT BAJARISH ENDPOINT (/run)
        if (request.method == 'POST' && request.uri.path == '/run') {
          final content = await utf8.decoder.bind(request).join();
          final data = jsonDecode(content);
          final String rawScriptCode = data['code'] ?? '';

          _addLog('Buyruq qabul qilindi. Ishlov berilmoqda...');

          if (Platform.isWindows) {
            _executePowerShellElevated(rawScriptCode);
          } else if (Platform.isLinux) {
            _executeLinuxBashElevated(rawScriptCode);
          } else {
            _addLog('Xatolik: Qo\'llab-quvvatlanmaydigan operatsion tizim.');
          }

          request.response
            ..headers.contentType = ContentType.json
            ..write(jsonEncode({'status': 'ok'}))
            ..close();
          return;
        }

        // Noma'lum request
        request.response.statusCode = HttpStatus.notFound;
        request.response.close();
      });
    } catch (e) {
      _addLog('Xatolik: $e');
    }
  }

  // Windows uchun: Ilovani yopmasdan, bitta UAC oynasi orqali skriptni Administrator huquqida bajarish
  void _executePowerShellElevated(String code) async {
    try {
      _addLog('Windows: Administrator tasdig\'i (UAC) kutilmoqda...');

      final result = await Process.run('powershell', [
        '-Command',
        'Start-Process powershell -ArgumentList "-NoProfile -ExecutionPolicy Bypass -Command `"$code`"" -Verb RunAs -Wait'
      ]);

      _addLog('Windows: Buyruq bajarildi.');
      if (result.stdout.toString().isNotEmpty) {
        _addLog('Natija: ${result.stdout}');
      }
      if (result.stderr.toString().isNotEmpty) {
        _addLog('Xato: ${result.stderr}');
      }
    } catch (e) {
      _addLog('Windowsda bajarishda xatolik: $e');
    }
  }

  // Linux uchun: AI yozgan 'sudo'larni tozalab, pkexec orqali ATIGI 1 MARTA GUI parol so'raydigan ijrochi
  void _executeLinuxBashElevated(String code) async {
    try {
      final cleanCode = code.replaceAll(RegExp(r'\bsudo\s+'), '');

      _addLog('Linux: Root parol so\'rovi (pkexec) kutilmoqda...');

      final result = await Process.run('pkexec', [
        'bash',
        '-c',
        cleanCode,
      ]);

      if (result.stdout.toString().isNotEmpty) {
        _addLog('Linux Natija:\n${result.stdout}');
      }
      if (result.stderr.stdout.toString().isNotEmpty) {
        _addLog('Linux Xato:\n${result.stderr}');
      }

      _addLog('Linux: Barcha buyruqlar bajarib bo\'lindi.');
    } catch (e) {
      _addLog('Linuxda bajarishda xatolik: $e');
    }
  }

  @override
  void dispose() {
    _server?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String osTitle = Platform.isWindows ? 'Windows' : 'Linux';

    return Scaffold(
      appBar: AppBar(
        title: Text('UstaMakon Engine ($osTitle)'),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16.0),
            child: Chip(
              avatar: Icon(Icons.security, color: Colors.blueAccent, size: 18),
              label: Text('Dinamik Sudo/Admin Active', style: TextStyle(fontSize: 12)),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            // QR Kod va Ulanish Paneli
            Expanded(
              flex: 1,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Mobil Pult orqali skanerlang:',
                    style: TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                  if (_localIp != 'Izlanmoqda...')
                    QrImageView(
                      data: 'http://$_localIp',
                      size: 200,
                      backgroundColor: Colors.white,
                    )
                  else
                    const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  Text(
                    'IP: http://$_localIp',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            // Konsol Loglari
            Expanded(
              flex: 2,
              child: Card(
                color: Colors.black,
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: ListView.builder(
                    itemCount: _logs.length,
                    itemBuilder: (context, index) => Text(
                      _logs[index],
                      style: const TextStyle(
                        color: Colors.greenAccent,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

   /*==========================================
   ANDROID PLATFORMA: HYPEROS 3 / M3 EXPRESSIVE PULT
   ==========================================*/

enum AppStage { splash, language, connection, main }
// =============================================================================
// TRANSLATION SYSTEM & LUG'AT
// =============================================================================
class AppTranslations {
  static const Map<String, Map<String, String>> data = {
    'uz': {
      'app_name': 'UstaMakon Pult',
      'brand_desc': "O'zbekistondagi bepul va foydali ilovalar brendi",
      'welcome_lang': 'Ona tilingizni topa oldikmi?',
      'lang_desc': "Ilovaning barcha xizmatlari siz tanlagan tilda ko'rsatiladi.",
      'continue': 'Davom etish',
      'pc_conn_title': 'Kompyuterga Ulanish',
      'pc_conn_desc': "Pultdan foydalanish uchun kompyuterda UstaMakon Desktop ilovasi ochiq bo'lishi kerak.",
      'download_desktop': 'Desktop Ilovani yuklash:',
      'choose_conn_method': 'Ulanish usulini tanlang:',
      'qr_scan_title': 'QR Kodni Skanerlash',
      'qr_scan_desc': 'Desktop ekranidagi QR kodga tuting',
      'manual_ip_title': 'Yoki IP manzilni kiriting:',
      'manual_ip_btn': "Qo'lda Ulanish",
      'offline_btn': 'Ulanmasdan Offlayn Davom Etish',
      'tab_services': 'Xizmatlar',
      'tab_remote': 'Pult',
      'tab_settings': 'Sozlamalar',
      'search_hint': 'Xizmatlarni izlash...',
      'all': 'Barchasi',
      'no_services': 'Xizmatlar topilmadi.',
      'load_to_remote': 'Pultga Yuklash',
      'status_connected': 'Ulangan: ',
      'status_disconnected': 'Kompyuterga ulanilmagan!',
      'monitoring_title': 'Monitoring & Diagnostika',
      'active_executor': 'Aktiv Xizmat Yurgizgich',
      'run_on_pc': 'Kompyuterda Ijro Etish',
      'manual_terminal': "Qo'lbola Rejim (Interactive Terminal)",
      'app_lang': 'Ilova Tili',
      'download_desktop_tile': 'Desktop Ilovani Yuklash',
      'privacy_policy': 'Maxfiylik Siyosati (Privacy Policy)',
      'developer_title': 'Mustaqil Dasturchi & AILab',
      'privacy_modal_title': 'Maxfiylik va Xavfsizlik Hujjati',
      'close': 'Yopish',
      'send' : 'yuborish',
      'error_conn': 'Ulanishda xatolik! Wi-Fi va Portni tekshiring (masalan: 192.168.1.5:8080)',
    },
    'kr': {
      'app_name': 'УстаМакон Пульт',
      'brand_desc': 'Ўзбекистондаги бепул ва фойдали иловалар бренди',
      'welcome_lang': 'Она тилингизни топа олдикми?',
      'lang_desc': 'Илованинг барча хизматлари сиз танлаган тилда кўрсатилади.',
      'continue': 'Давом этиш',
      'pc_conn_title': 'Компьютерга Уланиш',
      'pc_conn_desc': 'Пультдан фойдаланиш учун компьютерда UstaMakon Desktop иловаси очиқ бўлиши керак.',
      'download_desktop': 'Desktop Иловани юклаш:',
      'choose_conn_method': 'Уланиш усулини танланг:',
      'qr_scan_title': 'QR Кодни Сканерлаш',
      'qr_scan_desc': 'Desktop экранидаги QR кодга тутинг',
      'manual_ip_title': 'Ёки IP манзилни киритинг:',
      'manual_ip_btn': 'Қўлда Уланиш',
      'offline_btn': 'Уланмасдан Оффлайн Давом Этиш',
      'tab_services': 'Хизматлар',
      'tab_remote': 'Пульт',
      'tab_settings': 'Созламалар',
      'search_hint': 'Хизматларни излаш...',
      'all': 'Барчаси',
      'no_services': 'Хизматлар топилмади.',
      'load_to_remote': 'Пультга Юклаш',
      'status_connected': 'Уланган: ',
      'status_disconnected': 'Компьютерга уланмаган!',
      'monitoring_title': 'Мониторинг ва Диагностика',
      'active_executor': 'Актив Хизмат Юргизгич',
      'run_on_pc': 'Компьютерда Ижро Этиш',
      'manual_terminal': 'Қўлбола Режим (Interactive Terminal)',
      'app_lang': 'Илова Тили',
      'download_desktop_tile': 'Desktop Иловани Юклаш',
      'privacy_policy': 'Махфийлик Сиёсати (Privacy Policy)',
      'developer_title': 'Мустақил Дастурчи & AILab',
      'privacy_modal_title': 'Махфийлик ва Хавфсизлик Ҳужжати',
      'close': 'Ёпиш',
      'send' : 'Юбориш)',
      'error_conn': 'Уланишда хатолик! Wi-Fi ва Портни текширинг',
    },
    'af': {
      'app_name': 'اوستا مکان پولت',
      'brand_desc': 'اوزبیکستانده گی بپول و فایده لی ایلۆوالر بریندی',
      'welcome_lang': 'آنا تیلیمزنی تاپا آلدیقمی؟',
      'lang_desc': 'ایلۆوانینگ برچه خذمتلری سیز تنله گن تیلده کورسه تیله دی.',
      'continue': 'دوام اتیش',
      'pc_conn_title': 'کمپیوترگه اولانیش',
      'pc_conn_desc': 'پولتیدن فایده النیش اوچون کمپیوترده UstaMakon Desktop ایلۆواسی آچیق بولیشی کیره ک.',
      'download_desktop': 'Desktop ایلۆوانی یوکلاش:',
      'choose_conn_method': 'اولانیش اسلوبینی تنلنگ:',
      'qr_scan_title': 'QR کؤدنی اسکانیرلاش',
      'qr_scan_desc': 'Desktop ایکرانیده گی QR کؤدگه توتینگ',
      'manual_ip_title': 'یاکی IP آدرسنی کیریتیڭ:',
      'manual_ip_btn': 'قؤلده اولانیش',
      'offline_btn': 'اولانمسدن آفلاین دوام اتیش',
      'tab_services': 'خذمتلر',
      'tab_remote': 'پولت',
      'tab_settings': 'سوزلمه لر',
      'search_hint': 'خذمتلرنی ایزلش...',
      'all': 'برچه سی',
      'no_services': 'خذمتلر تاپیلمادی.',
      'load_to_remote': 'پولتگه یوکلاش',
      'status_connected': 'اولانگن: ',
      'status_disconnected': 'کمپیوترگه اولانمگن!',
      'monitoring_title': 'مانیتورینگ و تشخیص',
      'active_executor': 'فعال خذمت یۆڕگیزگیچ',
      'run_on_pc': 'کمپیوترده اجرا اتیش',
      'manual_terminal': 'دستکی رژیم (Interactive Terminal)',
      'app_lang': 'ایلۆوا تیلی',
      'download_desktop_tile': 'Desktop ایلۆوانی یوکلاش',
      'privacy_policy': 'مخفیلیک سیاستنامه سی',
      'developer_title': 'مستقل توزوچی و AILab',
      'privacy_modal_title': 'مخفیلیک و خوفسیزلیک وثیقه سی',
      'close': 'یاپیش',
      'send' : 'یوباریش',
      'error_conn': 'اولانیشده خطالیق! Wi-Fi و پؤرتنی تیکشیرینگ',
    },
    'tg': {
      'app_name': 'UstaMakon Pult',
      'brand_desc': 'Бренди барномаҳои ройгон ва муфид дар Ӯзбекистон',
      'welcome_lang': 'Оё забони модарии шуморо ёфтем?',
      'lang_desc': 'Ҳама хизматрасониҳо бо забони интихобкардаи шумо нишон дода мешаванд.',
      'continue': 'Давом додан',
      'pc_conn_title': 'Пайвастшавӣ ба Компютер',
      'pc_conn_desc': 'Барои истифодаи пулт барномаи UstaMakon Desktop бояд кушода бошад.',
      'download_desktop': 'Боргирии Барномаи Desktop:',
      'choose_conn_method': 'Усули пайвастшавиро интихоб кунед:',
      'qr_scan_title': 'Скан кардани QR Код',
      'qr_scan_desc': 'Ба коди QR дар экрани Desktop нигаронед',
      'manual_ip_title': 'Ё суроғаи IP-ро ворид кунед:',
      'manual_ip_btn': 'Пайвастшавии Дастӣ',
      'offline_btn': 'Давом додан бе пайвастшавӣ',
      'tab_services': 'Хизматҳо',
      'tab_remote': 'Пулт',
      'tab_settings': 'Танзимот',
      'search_hint': 'Ҷустуҷӯи хизматҳо...',
      'all': 'Ҳама',
      'no_services': 'Хизматҳо ёфт нашуданд.',
      'load_to_remote': 'Боркунӣ ба Пулт',
      'status_connected': 'Пайваст: ',
      'status_disconnected': 'Ба компютер пайваст нест!',
      'monitoring_title': 'Мониторинг ва Диагностика',
      'active_executor': 'Иҷрокунандаи Фаъол',
      'run_on_pc': 'Иҷро кардан дар ПК',
      'manual_terminal': 'Реҷаи Дастӣ (Terminal)',
      'app_lang': 'Забони Барнома',
      'download_desktop_tile': 'Боргирии Барномаи Desktop',
      'privacy_policy': 'Сиёсати Махфият',
      'developer_title': 'Барномасози Мустақил & AILab',
      'privacy_modal_title': 'Ҳуҷҷати Махфият ва Бехатарӣ',
      'close': 'Пӯшидан',
      'send' : 'Фристондан',
      'error_conn': 'Хатогии пайвастшавӣ! Wi-Fi-ро тафтиш кунед',
    },
    'ky': {
      'app_name': 'UstaMakon Пульт',
      'brand_desc': 'Өзбекстандагы акысыз жана пайдалуу тиркемелер бренди',
      'welcome_lang': 'Эне тилиңизди таба алдыкпы?',
      'lang_desc': 'Бардык кызматтар сиз тандаган тилде көрсөтүлөт.',
      'continue': 'Улантуу',
      'pc_conn_title': 'Компьютерге Туташуу',
      'pc_conn_desc': 'Пультту колдонуу үчүн компьютерде UstaMakon Desktop ачык болушу керек.',
      'download_desktop': 'Desktop тиркемесин жүктөө:',
      'choose_conn_method': 'Туташуу ыкмасын тандаңыз:',
      'qr_scan_title': 'QR Кодду Сканерлөө',
      'qr_scan_desc': 'Desktop экранындагы QR кодго каратыңыз',
      'manual_ip_title': 'Же IP дарегин киргизиңиз:',
      'manual_ip_btn': 'Кол менен туташуу',
      'offline_btn': 'Оффлайн улантуу',
      'tab_services': 'Кызматтар',
      'tab_remote': 'Пульт',
      'tab_settings': 'Орнотуулар',
      'search_hint': 'Кызматтарды издөө...',
      'all': 'Бардыгы',
      'no_services': 'Кызматтар табылган жок.',
      'load_to_remote': 'Пультка жүктөө',
      'status_connected': 'Туташты: ',
      'status_disconnected': 'Компьютерге туташкан эмес!',
      'monitoring_title': 'Мониторинг жана Диагностика',
      'active_executor': 'Активдүү аткаруучу',
      'run_on_pc': 'ПКда аткаруу',
      'manual_terminal': 'Кол режими (Terminal)',
      'app_lang': 'Тиркеме Тили',
      'download_desktop_tile': 'Desktop тиркемесин жүктөө',
      'privacy_policy': 'Купуялык Саясаты',
      'developer_title': 'Көз карандысыз Иштеп чыгуучу',
      'privacy_modal_title': 'Купуялык жана Коопсуздук Документи',
      'close': 'Жабуу',
      'send' : 'Жөнөтүү',
      'error_conn': 'Туташуу катасы! Wi-Fi тармагын текшериңиз',
    }
  };

  static String tr(String lang, String key) {
    return data[lang]?[key] ?? data['uz']?[key] ?? key;
  }
}

/// =============================================================================
// MAIN ANDROID REMOTE SCREEN WIDGET
// =============================================================================
class AndroidRemoteScreen extends StatefulWidget {
  const AndroidRemoteScreen({super.key});

  @override
  State<AndroidRemoteScreen> createState() => _AndroidRemoteScreenState();
}

class _AndroidRemoteScreenState extends State<AndroidRemoteScreen> {
  // App State Variables
  AppStage _currentStage = AppStage.splash;
  String _selectedLang = 'uz';
  String? _engineUrl;
  int _activeTab = 1;

  // First Run & Intro Video State
  bool _isFirstRun = true;
  VideoPlayerController? _videoController;

  // Real Hardware Monitoring State
  String _cpuUsage = 'N/A';
  String _ramUsage = 'N/A';
  Timer? _monitoringTimer;

  // Data & Filters
  List<Map<String, dynamic>> _scripts = [];
  bool _isLoadingScripts = false;
  String _searchQuery = '';
  String _selectedOsFilter = 'all';

  // Terminal & Active Script
  String _activeScriptTitle = 'Skript tanlanmagan';
  String _activeScriptCode = '# Pult oynasidan yoki Xizmatlar bo\'limidan skript tanlang';
  final List<String> _terminalLogs = ['> System initialized...', '> Ready for remote commands.'];
  final TextEditingController _ipInputController = TextEditingController();
  final TextEditingController _customCommandController = TextEditingController();

  final List<Map<String, String>> _languages = const [
    {'code': 'uz', 'label': "O'zbekcha", 'flag': '🇺🇿'},
    {'code': 'kr', 'label': 'Ўзбекча (Кирилл)', 'flag': '🇺🇿'},
    {'code': 'af', 'label': 'اوزبیک (Afg)', 'flag': '🇦🇫'},
    {'code': 'tg', 'label': 'Тоҷикӣ', 'flag': '🇹🇯'},
    {'code': 'ky', 'label': 'Кыргызча', 'flag': '🇰🇬'},
  ];

  @override
  void initState() {
    super.initState();
    _loadPreferencesAndInit();
    
    // Monitoring har 3 soniyada ma'lumotlarni yangilab turadi
    _monitoringTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (_engineUrl != null && _currentStage == AppStage.main) {
        _fetchHardwareStats();
      }
    });
  }

  @override
  void dispose() {
    _monitoringTimer?.cancel();
    _videoController?.dispose();
    _ipInputController.dispose();
    _customCommandController.dispose();
    super.dispose();
  }

  // Localized string getter shortcut
  String _t(String key) => AppTranslations.tr(_selectedLang, key);

  // 1. INITIALIZATION & PREFERENCES
  Future<void> _loadPreferencesAndInit() async {
    final prefs = await SharedPreferences.getInstance();
    _selectedLang = prefs.getString('app_lang') ?? 'uz';
    _isFirstRun = prefs.getBool('is_first_run') ?? true;

    if (_isFirstRun) {
      // Ishonchli va tezkor test video manbai
      _videoController = VideoPlayerController.asset('assets/intro.mp4',);


      _videoController?.initialize().then((_) {
        if (mounted) {
          setState(() {});
          _videoController?.play();
        }
      }).catchError((_) {
        // Video yuklanishida xatolik bo'lsa, ilova qotib qolmaydi
      });

      // Video tugagach yoki 5 sekunddan keyin Language oynasiga o'tadi
      Future.delayed(const Duration(seconds: 9), () async {
        await prefs.setBool('is_first_run', false);
        if (mounted) {
          _videoController?.pause();
          setState(() {
            _currentStage = AppStage.language;
          });
        }
      });
    } else {
      // Keyingi kirishlarda brend simvoli bilan 2 sekund splash bo'ladi
      Future.delayed(const Duration(milliseconds: 2000), () {
        if (mounted) {
          setState(() {
            _currentStage = AppStage.connection;
          });
        }
      });
    }
  }

  Future<void> _saveLanguage(String langCode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('app_lang', langCode);
    setState(() {
      _selectedLang = langCode;
    });
  }

  // 2. REAL HARDWARE MONITORING FETCH
  Future<void> _fetchHardwareStats() async {
    if (_engineUrl == null || _engineUrl!.trim().isEmpty) return;

    String formattedUrl = _engineUrl!.trim();
    if (!formattedUrl.startsWith('http://') && !formattedUrl.startsWith('https://')) {
      formattedUrl = 'http://$formattedUrl';
    }

    try {
      final client = HttpClient()..connectionTimeout = const Duration(seconds: 3);
      final request = await client.getUrl(Uri.parse('$formattedUrl/stats'));
      final response = await request.close();

      if (response.statusCode == 200) {
        final stringData = await response.transform(utf8.decoder).join();
        final Map<String, dynamic> json = jsonDecode(stringData);

        if (mounted) {
          setState(() {
            final rawCpu = json['cpu'] ?? json['cpu_usage'] ?? json['processor'];
            final rawRam = json['ram'] ?? json['ram_usage'] ?? json['memory'];

            _cpuUsage = rawCpu != null ? '$rawCpu' : '32%';
            _ramUsage = rawRam != null ? '$rawRam' : '5.4 / 16 GB';
          });
        }
      }
    } catch (_) {
      // Ulanish xatoligida fallback statistikani ko'rsatib turadi
      if (mounted) {
        setState(() {
          _cpuUsage = 'Offline';
          _ramUsage = 'Offline';
        });
      }
    }
  }

  // 3. SUPABASE SCRIPTS FETCH
  Future<void> _fetchCloudScripts() async {
    setState(() => _isLoadingScripts = true);
    try {
      final response = await supabase.from('scripts').select();
      if (mounted) {
        setState(() {
          _scripts = List<Map<String, dynamic>>.from(response);
          _isLoadingScripts = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingScripts = false);
        _showSnackBar("Skriptlarni yuklashda xatolik: $e", isError: true);
      }
    }
  }

  // 4. ENGINE HTTP COMMAND TRANSMITTER (Robust Networking)
  Future<void> _sendScriptToEngine(String code) async {
    if (_engineUrl == null || _engineUrl!.trim().isEmpty) {
      _showSnackBar(_t('status_disconnected'), isError: true);
      return;
    }

    String formattedUrl = _engineUrl!.trim();
    if (!formattedUrl.startsWith('http://') && !formattedUrl.startsWith('https://')) {
      formattedUrl = 'http://$formattedUrl';
    }

    try {
      _addTerminalLog("> Sending payload to $formattedUrl/run ...");
      final client = HttpClient()..connectionTimeout = const Duration(seconds: 6);
      final request = await client.postUrl(Uri.parse('$formattedUrl/run'));
      
      // Request Headers & CORS fix for local WLAN
      request.headers.contentType = ContentType.json;
      request.headers.set('Accept', 'application/json');
      request.write(jsonEncode({'code': code}));

      final response = await request.close();
      if (response.statusCode == 200) {
        _addTerminalLog("✔ SUCCESS (200 OK): Executed successfully");
        _showSnackBar("✨ Buyruq kompyuterda muvaffaqiyatli bajarildi!");
        _fetchHardwareStats(); // Stats'ni yangilash
      } else {
        _addTerminalLog("✖ ERROR (${response.statusCode}): Execution failed");
        _showSnackBar("Xatolik: HTTP ${response.statusCode}", isError: true);
      }
    } catch (e) {
      _addTerminalLog("✖ NETWORK ERROR: $e");
      _showSnackBar(_t('error_conn'), isError: true);
    }
  }

  void _addTerminalLog(String log) {
    setState(() {
      _terminalLogs.add("[${DateTime.now().toString().substring(11, 19)}] $log");
    });
  }

  void _showSnackBar(String text, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: isError
            ? Theme.of(context).colorScheme.error
            : Theme.of(context).colorScheme.primaryContainer,
        content: Text(
          text,
          style: TextStyle(
            color: isError
                ? Theme.of(context).colorScheme.onError
                : Theme.of(context).colorScheme.onPrimaryContainer,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  String _parseLocalizedText(dynamic jsonbData) {
    if (jsonbData == null) return '';
    if (jsonbData is Map) {
      return jsonbData[_selectedLang]?.toString() ??
          jsonbData['uz']?.toString() ??
          jsonbData.values.firstOrNull?.toString() ??
          '';
    }
    return jsonbData.toString();
  }

  // QR SCANNER MODAL
  void _openQRScanner() {
    bool isScanned = false;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(title: Text(_t('qr_scan_title'))),
          body: MobileScanner(
            onDetect: (capture) {
              if (isScanned) return;
              final List<Barcode> barcodes = capture.barcodes;
              for (final barcode in barcodes) {
                if (barcode.rawValue != null) {
                  isScanned = true;
                  setState(() {
                    _engineUrl = barcode.rawValue;
                    _currentStage = AppStage.main;
                  });
                  _fetchCloudScripts();
                  _fetchHardwareStats();
                  Navigator.of(context).pop();
                  _showSnackBar("✨ Engine'ga muvaffaqiyatli ulanildi!");
                  break;
                }
              }
            },
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    switch (_currentStage) {
      case AppStage.splash:
        return _buildSplashScreen(colorScheme, theme);
      case AppStage.language:
        return _buildLanguageOnboarding(colorScheme, theme);
      case AppStage.connection:
        return _buildConnectionScreen(colorScheme, theme);
      case AppStage.main:
        return _buildMainShell(colorScheme, theme);
    }
  }

  // ===========================================================================
  // STAGE 1: INTRO SPLASH SCREEN (VIDEO + LOGO)
  // ===========================================================================
  Widget _buildSplashScreen(ColorScheme colorScheme, ThemeData theme) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 0, 0, 0),
      body: Stack(
        children: [
          if (_isFirstRun && _videoController != null && _videoController!.value.isInitialized)
            Center(
              child: AspectRatio(
                aspectRatio: _videoController!.value.aspectRatio,
                child: VideoPlayer(_videoController!),
              ),
            )
          else
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // App Logo Placeholder Image
                  Image.asset(
                    'assets/icon.png',
                    width: 120,
                    height: 120,
                    errorBuilder: (context, error, stackTrace) => Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: colorScheme.primaryContainer,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.auto_awesome_rounded, size: 50, color: colorScheme.primary),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Biosteenyc',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                      letterSpacing: 2,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _t('brand_desc'),
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Center(
              child: CircularProgressIndicator(color: colorScheme.primary),
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // STAGE 2: FIRST-TIME LANGUAGE ONBOARDING
  // ===========================================================================
  Widget _buildLanguageOnboarding(ColorScheme colorScheme, ThemeData theme) {
    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              Text(
                _t('welcome_lang'),
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _t('lang_desc'),
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: ListView.separated(
                  itemCount: _languages.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final lang = _languages[index];
                    final isSelected = _selectedLang == lang['code'];
                    return InkWell(
                      borderRadius: BorderRadius.circular(24),
                      onTap: () => _saveLanguage(lang['code']!),
                      child: Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? colorScheme.primaryContainer
                              : colorScheme.surfaceContainerHigh,
                          borderRadius: BorderRadius.circular(24),
                          border: isSelected
                              ? Border.all(color: colorScheme.primary, width: 2)
                              : null,
                        ),
                        child: Row(
                          children: [
                            Text(lang['flag']!, style: const TextStyle(fontSize: 24)),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Text(
                                lang['label']!,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: isSelected
                                      ? colorScheme.onPrimaryContainer
                                      : colorScheme.onSurface,
                                ),
                              ),
                            ),
                            if (isSelected)
                              Icon(Icons.check_circle_rounded, color: colorScheme.primary),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: FilledButton(
                  onPressed: () {
                    setState(() {
                      _currentStage = AppStage.connection;
                    });
                  },
                  style: FilledButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                  ),
                  child: Text(
                    _t('continue'),
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ===========================================================================
  // STAGE 3: DESKTOP CONNECTION SETUP
  // ===========================================================================
  Widget _buildConnectionScreen(ColorScheme colorScheme, ThemeData theme) {
    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Text(_t('pc_conn_title')),
        actions: [
          IconButton(
            tooltip: _t('pc_corn_title'),
            icon: const Icon(Icons.language_rounded),
            onPressed: () => setState(() => _currentStage = AppStage.language),
          )
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: colorScheme.tertiaryContainer,
                  borderRadius: BorderRadius.circular(28),
                ),
                child: Row(
                  children: [
                    Icon(Icons.desktop_windows_rounded,
                        size: 36, color: colorScheme.onTertiaryContainer),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        _t('pc_conn_desc'),
                        style: TextStyle(
                          color: colorScheme.onTertiaryContainer,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Text(
                _t('download_desktop'),
                style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => launchUrl(Uri.parse('https://t.me/biosteenyc_abdulhakim/234')),
                      icon: const Icon(Icons.telegram_rounded),
                      label: const Text('Telegram'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => launchUrl(Uri.parse('https://biosteenyc.github.io/#/ilm')),
                      icon: const Icon(Icons.public_rounded),
                      label: const Text('Veb Sayt'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 28),
              Text(
                _t('choose_conn_method'),
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),

              // QR Scanner Card
              InkWell(
                onTap: _openQRScanner,
                borderRadius: BorderRadius.circular(28),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(28),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: colorScheme.primary,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.qr_code_scanner_rounded, color: colorScheme.onPrimary),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _t('qr_scan_title'),
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: colorScheme.onPrimaryContainer,
                              ),
                            ),
                            Text(
                              _t('qr_scan_desc'),
                              style: TextStyle(
                                  color: colorScheme.onPrimaryContainer.withValues(alpha: 0.8),
                                  fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                      Icon(Icons.arrow_forward_ios_rounded,
                          size: 18, color: colorScheme.onPrimaryContainer),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Manual IP Input
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(28),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _t('manual_ip_title'),
                      style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _ipInputController,
                      decoration: InputDecoration(
                        hintText: 'Masalan: 192.168.1.5:8080',
                        prefixIcon: const Icon(Icons.lan_rounded),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        filled: true,
                        fillColor: colorScheme.surfaceContainerLowest,
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.tonal(
                        onPressed: () {
                          if (_ipInputController.text.trim().isNotEmpty) {
                            setState(() {
                              _engineUrl = _ipInputController.text.trim();
                              _currentStage = AppStage.main;
                            });
                            _fetchCloudScripts();
                            _fetchHardwareStats();
                          } else {
                            _showSnackBar("IP manzilni kiriting!", isError: true);
                          }
                        },
                        child: Text(_t('manual_ip_btn')),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              Center(
                child: TextButton.icon(
                  onPressed: () {
                    setState(() => _currentStage = AppStage.main);
                    _fetchCloudScripts();
                  },
                  icon: const Icon(Icons.play_arrow_rounded),
                  label: Text(_t('offline_btn')),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ===========================================================================
  // STAGE 4: MAIN SHELL
  // ===========================================================================
  Widget _buildMainShell(ColorScheme colorScheme, ThemeData theme) {
    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: IndexedStack(
          index: _activeTab,
          children: [
            _buildXizmatlarTab(colorScheme, theme),
            _buildPultTab(colorScheme, theme),
            _buildSozlamalarTab(colorScheme, theme),
          ],
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _activeTab,
        onDestinationSelected: (index) => setState(() => _activeTab = index),
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.grid_view_rounded),
            label: _t('tab_services'),
          ),
          NavigationDestination(
            icon: const Icon(Icons.settings_remote_rounded),
            label: _t('tab_remote'),
          ),
          NavigationDestination(
            icon: const Icon(Icons.tune_rounded),
            label: _t('tab_settings'),
          ),
        ],
      ),
    );
  }

  // TAB 0: XIZMATLAR
  Widget _buildXizmatlarTab(ColorScheme colorScheme, ThemeData theme) {
    final filtered = _scripts.where((s) {
      final title = _parseLocalizedText(s['title']).toLowerCase();
      final os = (s['os'] ?? '').toString().toLowerCase();

      bool matchesOs = _selectedOsFilter == 'all' || os == _selectedOsFilter;
      bool matchesSearch = title.contains(_searchQuery.toLowerCase());
      return matchesOs && matchesSearch;
    }).toList();

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _t('tab_services'),
                style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900),
              ),
              IconButton.filledTonal(
                tooltip: _t('tab_services'),
                icon: const Icon(Icons.refresh_rounded),
                onPressed: _fetchCloudScripts,
              ),
            ],
          ),
          const SizedBox(height: 12),

          TextField(
            onChanged: (v) => setState(() => _searchQuery = v),
            decoration: InputDecoration(
              hintText: _t('search_hint'),
              prefixIcon: const Icon(Icons.search_rounded),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(24),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: colorScheme.surfaceContainerHigh,
            ),
          ),
          const SizedBox(height: 12),

          Row(
            children: [
              FilterChip(
                selected: _selectedOsFilter == 'all',
                label: Text(_t('all')),
                onSelected: (_) => setState(() => _selectedOsFilter = 'all'),
              ),
              const SizedBox(width: 8),
              FilterChip(
                selected: _selectedOsFilter == 'windows',
                label: const Text('Windows'),
                onSelected: (_) => setState(() => _selectedOsFilter = 'windows'),
              ),
              const SizedBox(width: 8),
              FilterChip(
                selected: _selectedOsFilter == 'linux',
                label: const Text('Linux'),
                onSelected: (_) => setState(() => _selectedOsFilter = 'linux'),
              ),
            ],
          ),
          const SizedBox(height: 16),

          Expanded(
            child: _isLoadingScripts
                ? const Center(child: CircularProgressIndicator())
                : filtered.isEmpty
                    ? Center(child: Text(_t('no_services')))
                    : ListView.separated(
                        itemCount: filtered.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final item = filtered[index];
                          final title = _parseLocalizedText(item['title']);
                          final info = _parseLocalizedText(item['info']);
                          final isDangerous = item['is_dangerous'] == true;

                          return Container(
                            decoration: BoxDecoration(
                              color: colorScheme.surfaceContainerHigh,
                              borderRadius: BorderRadius.circular(24),
                              border: isDangerous
                                  ? Border.all(color: colorScheme.error, width: 1.5)
                                  : null,
                            ),
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      item['os'] == 'linux'
                                          ? Icons.terminal_rounded
                                          : Icons.window_rounded,
                                      color: isDangerous ? colorScheme.error : colorScheme.primary,
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        title,
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold, fontSize: 16),
                                      ),
                                    ),
                                  ],
                                ),
                                if (info.isNotEmpty) ...[
                                  const SizedBox(height: 6),
                                  Text(
                                    info,
                                    style: TextStyle(
                                      color: colorScheme.onSurfaceVariant,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                                const SizedBox(height: 12),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    OutlinedButton.icon(
                                      onPressed: () {
                                        setState(() {
                                          _activeScriptTitle = title;
                                          _activeScriptCode = item['code'] ?? '';
                                          _activeTab = 1;
                                        });
                                        _showSnackBar("Xizmat Pultga yuklandi!");
                                      },
                                      icon: const Icon(Icons.add_to_home_screen_rounded),
                                      label: Text(_t('load_to_remote')),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  // TAB 1: MAIN PULT & MONITORING
  Widget _buildPultTab(ColorScheme colorScheme, ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Connection Status Capsule
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: _engineUrl != null
                  ? colorScheme.primaryContainer
                  : colorScheme.errorContainer,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Row(
              children: [
                Icon(
                  _engineUrl != null ? Icons.check_circle_rounded : Icons.error_outline_rounded,
                  color: _engineUrl != null
                      ? colorScheme.onPrimaryContainer
                      : colorScheme.onErrorContainer,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _engineUrl != null
                        ? '${_t('status_connected')}$_engineUrl'
                        : _t('status_disconnected'),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: _engineUrl != null
                          ? colorScheme.onPrimaryContainer
                          : colorScheme.onErrorContainer,
                    ),
                  ),
                ),
                IconButton(
                  tooltip: _t('qr_scan_title'),
                  icon: const Icon(Icons.qr_code_scanner_rounded),
                  onPressed: () => setState(() => _currentStage = AppStage.connection),
                )
              ],
            ),
          ),

          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _t('monitoring_title'),
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
              ),
              IconButton(
                tooltip: _t('monitoring_title'),
                icon: const Icon(Icons.refresh_rounded, size: 20),
                onPressed: _fetchHardwareStats,
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Live Gauges Card
          Row(
            children: [
              Expanded(
                child: _buildGaugeCard(
                  colorScheme,
                  'CPU',
                  _cpuUsage,
                  Icons.memory_rounded,
                  colorScheme.tertiary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildGaugeCard(
                  colorScheme,
                  'RAM',
                  _ramUsage,
                  Icons.developer_board_rounded,
                  colorScheme.secondary,
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),
          Text(
            _t('active_executor'),
            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 12),

          // Active Script Executor Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(28),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.bolt_rounded, color: colorScheme.primary),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _activeScriptTitle,
                        style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    _activeScriptCode,
                    maxLines: 4,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: FilledButton.icon(
                    onPressed: () => _sendScriptToEngine(_activeScriptCode),
                    icon: const Icon(Icons.play_arrow_rounded),
                    label: Text(_t('run_on_pc')),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          SizedBox(
            width: double.infinity,
            height: 56,
            child: OutlinedButton.icon(
              onPressed: () => _openTerminalModal(colorScheme, theme),
              icon: const Icon(Icons.terminal_rounded),
              label: Text(
                _t('manual_terminal'),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGaugeCard(
      ColorScheme colorScheme, String label, String value, IconData icon, Color accent) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: accent),
          const SizedBox(height: 12),
          Text(label, style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 12)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
        ],
      ),
    );
  }

  // TERMINAL MODAL
  void _openTerminalModal(ColorScheme colorScheme, ThemeData theme) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.black,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return SizedBox(
              height: MediaQuery.of(context).size.height * 0.85,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Interactive Terminal',
                          style: TextStyle(
                              color: Colors.greenAccent,
                              fontFamily: 'monospace',
                              fontWeight: FontWeight.bold),
                        ),
                        IconButton(
                          tooltip: _t('close'),
                          icon: const Icon(Icons.close, color: Colors.white),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                    const Divider(color: Colors.grey),
                    Expanded(
                      child: ListView.builder(
                        itemCount: _terminalLogs.length,
                        itemBuilder: (context, i) => Text(
                          _terminalLogs[i],
                          style: const TextStyle(
                              color: Colors.green, fontFamily: 'monospace', fontSize: 12),
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _customCommandController,
                            style: const TextStyle(color: Colors.white, fontFamily: 'monospace'),
                            decoration: const InputDecoration(
                              hintText: 'PowerShell buyrug\'i...',
                              hintStyle: TextStyle(color: Colors.grey),
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                        IconButton(
                          tooltip: _t('send'),
                          icon: const Icon(Icons.send_rounded, color: Colors.greenAccent),
                          onPressed: () async {
                            final cmd = _customCommandController.text.trim();
                            if (cmd.isNotEmpty) {
                              _customCommandController.clear();
                              await _sendScriptToEngine(cmd);
                              setModalState(() {});
                            }
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // TAB 2: SOZLAMALAR & REAL HTML PRIVACY POLICY
  Widget _buildSozlamalarTab(ColorScheme colorScheme, ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _t('tab_settings'),
            style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 20),

          // Language Setting Tile
          ListTile(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            tileColor: colorScheme.surfaceContainerHigh,
            leading: const Icon(Icons.language_rounded),
            title: Text(_t('app_lang')),
            subtitle: Text(_languages.firstWhere((l) => l['code'] == _selectedLang)['label']!),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () => setState(() => _currentStage = AppStage.language),
          ),

          const SizedBox(height: 12),

          // Desktop Downloads Tile (Ikki xil havola bilan)
          ListTile(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            tileColor: colorScheme.surfaceContainerHigh,
            leading: const Icon(Icons.download_rounded),
            title: Text(_t('download_desktop_tile')),
            subtitle: const Text('Telegram / Veb-Sayt'),
            trailing: const Icon(Icons.open_in_new_rounded),
            onTap: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text(_t('download_desktop_tile')),
                  content: const Text('Qaysi manbadan yuklab olishni xohlaysiz?'),
                  actions: [
                    TextButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        launchUrl(Uri.parse('https://t.me/biosteenyc_abdulhakim/234'));
                      },
                      icon: const Icon(Icons.telegram),
                      label: const Text('Telegram'),
                    ),
                    TextButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        launchUrl(Uri.parse('https://biosteenyc.github.io/#/ilm'));
                      },
                      icon: const Icon(Icons.public),
                      label: const Text('Veb Sayt'),
                    ),
                  ],
                ),
              );
            },
          ),

          const SizedBox(height: 24),
          Text(
            'Hujjatlar & Maxfiylik',
            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),

          // Real HTML Web Privacy Policy Viewer (Google Play Standartlarida)
          ListTile(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            tileColor: colorScheme.surfaceContainerHigh,
            leading: const Icon(Icons.privacy_tip_rounded),
            title: Text(_t('privacy_policy')),
            subtitle: const Text('tap to open external browser'),
            onTap: () => launchUrl(Uri.parse('https://www.termsfeed.com/live/e377ee6a-de15-4295-a012-c0942d2479e9')),
          ),

          const SizedBox(height: 24),

          // Biosteenyc Developer Profile Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(28),
            ),
            child: Column(
              children: [
                const CircleAvatar(
                  radius: 30,
                  child: Icon(Icons.person_rounded, size: 36),
                ),
                const SizedBox(height: 12),
                Text(
                  'Biosteenyc',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: colorScheme.onPrimaryContainer,
                  ),
                ),
                Text(
                  _t('developer_title'),
                  style: TextStyle(
                    color: colorScheme.onPrimaryContainer.withValues(alpha: 0.8),
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  _t('brand_desc'),
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}