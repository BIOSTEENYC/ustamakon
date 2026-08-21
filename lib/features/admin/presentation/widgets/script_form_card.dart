// =============================================================================
// FILE START: lib/features/admin/presentation/widgets/script_form_card.dart
// =============================================================================
import 'package:kompyuter_sirlari/imports.dart';

/// Yangi skript yaratish formasi
/// (5 til sarlavha/tavsif + OS + kategoriya + xavflilik + kod).
class ScriptFormCard extends StatefulWidget {
  const ScriptFormCard({super.key, required this.onSaved});

  final Future<void> Function(ScriptDraft draft) onSaved;

  @override
  State<ScriptFormCard> createState() => _ScriptFormCardState();
}

class _ScriptFormCardState extends State<ScriptFormCard>
    with SingleTickerProviderStateMixin {
  final Map<String, TextEditingController> _titleControllers = {
    for (final lang in supportedLanguages) lang.code: TextEditingController(),
  };
  final Map<String, TextEditingController> _infoControllers = {
    for (final lang in supportedLanguages) lang.code: TextEditingController(),
  };
  final TextEditingController _codeController = TextEditingController();

  String _selectedOs = 'windows';
  String _selectedCategory = 'optimization';
  bool _isDangerous = false;

  late final TabController _langTabController =
      TabController(length: supportedLanguages.length, vsync: this);

  @override
  void dispose() {
    for (final c in _titleControllers.values) {
      c.dispose();
    }
    for (final c in _infoControllers.values) {
      c.dispose();
    }
    _codeController.dispose();
    _langTabController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_titleControllers['uz']!.text.trim().isEmpty ||
        _codeController.text.trim().isEmpty) {
      showAppSnack(context, "O'zbekcha sarlavha va kod majburiy!");
      return;
    }

    final title = <String, String>{};
    final info = <String, String>{};
    for (final lang in supportedLanguages) {
      final code = lang.code;
      title[code] = _titleControllers[code]!.text.trim().isNotEmpty
          ? _titleControllers[code]!.text.trim()
          : _titleControllers['uz']!.text.trim();
      info[code] = _infoControllers[code]!.text.trim().isNotEmpty
          ? _infoControllers[code]!.text.trim()
          : _infoControllers['uz']!.text.trim();
    }

    await widget.onSaved(ScriptDraft(
      title: title,
      info: info,
      code: _codeController.text.trim(),
      os: _selectedOs,
      category: _selectedCategory,
      isDangerous: _isDangerous,
    ));

    _clearForm();
  }

  void _clearForm() {
    for (final c in _titleControllers.values) {
      c.clear();
    }
    for (final c in _infoControllers.values) {
      c.clear();
    }
    _codeController.clear();
    setState(() {
      _selectedOs = 'windows';
      _selectedCategory = 'optimization';
      _isDangerous = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return ExpressiveCard(
      radius: 32,
      padding: const EdgeInsets.all(24),
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
            "Ko'p tilli dinamik skriptlar yarating",
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 20),

          Row(
            children: [
              Expanded(child: _osDropdown(colorScheme)),
              const SizedBox(width: 12),
              Expanded(child: _categoryDropdown(colorScheme)),
            ],
          ),
          const SizedBox(height: 16),

          // Xavfli / tizimiy kalit
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
              subtitle: const Text("Qizil ogohlantirish ko'rsatiladi"),
              value: _isDangerous,
              activeThumbColor: colorScheme.error,
              onChanged: (v) => setState(() => _isDangerous = v),
            ),
          ),
          const SizedBox(height: 20),

          _languageBar(colorScheme),
          const SizedBox(height: 16),

          SizedBox(
            height: 150,
            child: TabBarView(
              controller: _langTabController,
              children: [
                for (final lang in supportedLanguages)
                  _langInputs(lang, colorScheme),
              ],
            ),
          ),
          const SizedBox(height: 12),

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

          SizedBox(
            width: double.infinity,
            height: 56,
            child: FilledButton.icon(
              onPressed: _submit,
              icon: const Icon(Icons.bolt_rounded, size: 24),
              label: const Text(
                "Supabase'ga Saqlash",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
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

  Widget _osDropdown(ColorScheme colorScheme) {
    return DropdownButtonFormField<String>(
      initialValue: _selectedOs,
      decoration: InputDecoration(
        labelText: 'OS',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
        filled: true,
        fillColor: colorScheme.surfaceContainerLowest,
      ),
      items: const [
        DropdownMenuItem(value: 'windows', child: Text('Windows')),
        DropdownMenuItem(value: 'linux', child: Text('Linux')),
      ],
      onChanged: (v) => setState(() => _selectedOs = v!),
    );
  }

  Widget _categoryDropdown(ColorScheme colorScheme) {
    return DropdownButtonFormField<String>(
      initialValue: _selectedCategory,
      decoration: InputDecoration(
        labelText: 'Kategoriya',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
        filled: true,
        fillColor: colorScheme.surfaceContainerLowest,
      ),
      items: const [
        DropdownMenuItem(value: 'optimization', child: Text('Optimization')),
        DropdownMenuItem(value: 'debloat', child: Text('Debloat')),
        DropdownMenuItem(value: 'installers', child: Text('Installers')),
        DropdownMenuItem(value: 'diagnostics', child: Text('Diagnostics')),
      ],
      onChanged: (v) => setState(() => _selectedCategory = v!),
    );
  }

  Widget _languageBar(ColorScheme colorScheme) {
    return Container(
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
        tabs: [
          for (final lang in supportedLanguages)
            Tab(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text(lang.shortLabel),
              ),
            ),
        ],
      ),
    );
  }

  Widget _langInputs(AppLanguage lang, ColorScheme colorScheme) {
    return Column(
      children: [
        TextField(
          controller: _titleControllers[lang.code],
          decoration: InputDecoration(
            labelText: 'Sarlavha (${lang.shortLabel})',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
            filled: true,
            fillColor: colorScheme.surfaceContainerLowest,
          ),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: _infoControllers[lang.code],
          decoration: InputDecoration(
            labelText: 'Tavsif (${lang.shortLabel})',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
            filled: true,
            fillColor: colorScheme.surfaceContainerLowest,
          ),
        ),
      ],
    );
  }
}
// =============================================================================
// FILE END: lib/features/admin/presentation/widgets/script_form_card.dart
// =============================================================================