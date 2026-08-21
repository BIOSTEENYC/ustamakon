// =============================================================================
// FILE START: lib/features/admin/presentation/widgets/script_edit_dialog.dart
// =============================================================================
import 'package:kompyuter_sirlari/imports.dart';

/// Skriptni tahrirlash dialogi
/// (uz tili + OS + kategoriya + xavflilik + kod; boshqa tillar saqlanadi).
class ScriptEditDialog extends StatefulWidget {
  const ScriptEditDialog({super.key, required this.script});

  final AppScript script;

  @override
  State<ScriptEditDialog> createState() => _ScriptEditDialogState();
}

class _ScriptEditDialogState extends State<ScriptEditDialog> {
  late final Map<String, TextEditingController> _titleControllers = {
    for (final lang in supportedLanguages)
      lang.code: TextEditingController(text: widget.script.title[lang.code]),
  };
  late final Map<String, TextEditingController> _infoControllers = {
    for (final lang in supportedLanguages)
      lang.code: TextEditingController(text: widget.script.info[lang.code]),
  };
  late final TextEditingController _codeController =
      TextEditingController(text: widget.script.code);

  late String _os = widget.script.os;
  late String _category = widget.script.category;
  late bool _isDangerous = widget.script.isDangerous;

  @override
  void dispose() {
    for (final c in _titleControllers.values) {
      c.dispose();
    }
    for (final c in _infoControllers.values) {
      c.dispose();
    }
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final title = {
      for (final lang in supportedLanguages)
        lang.code: _titleControllers[lang.code]!.text.trim(),
    };
    final info = {
      for (final lang in supportedLanguages)
        lang.code: _infoControllers[lang.code]!.text.trim(),
    };

    await ScriptRepository.instance.update(
      widget.script.id,
      ScriptDraft(
        title: title,
        info: info,
        code: _codeController.text.trim(),
        os: _os,
        category: _category,
        isDangerous: _isDangerous,
      ),
    );

    if (mounted) Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return AlertDialog(
      backgroundColor: colorScheme.surfaceContainerHighest,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(36)),
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
                initialValue: _os,
                decoration: InputDecoration(
                  labelText: 'Operatsion Tizim',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                items: const [
                  DropdownMenuItem(value: 'windows', child: Text('Windows')),
                  DropdownMenuItem(value: 'linux', child: Text('Linux')),
                ],
                onChanged: (v) => setState(() => _os = v!),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _category,
                decoration: InputDecoration(
                  labelText: 'Kategoriya',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                items: const [
                  DropdownMenuItem(value: 'optimization', child: Text('Optimization')),
                  DropdownMenuItem(value: 'debloat', child: Text('Debloat')),
                  DropdownMenuItem(value: 'installers', child: Text('Installers')),
                  DropdownMenuItem(value: 'diagnostics', child: Text('Diagnostics')),
                ],
                onChanged: (v) => setState(() => _category = v!),
              ),
              const SizedBox(height: 12),
              SwitchListTile(
                title: const Text("Xavfli Skript"),
                value: _isDangerous,
                onChanged: (v) => setState(() => _isDangerous = v),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _titleControllers['uz'],
                decoration: InputDecoration(
                  labelText: "Sarlavha (O'zbekcha)",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _infoControllers['uz'],
                decoration: InputDecoration(
                  labelText: "Tavsif (O'zbekcha)",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _codeController,
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
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Bekor qilish'),
        ),
        FilledButton(
          style: FilledButton.styleFrom(shape: const StadiumBorder()),
          onPressed: _save,
          child: const Text('Saqlash'),
        ),
      ],
    );
  }
}
// =============================================================================
// FILE END: lib/features/admin/presentation/widgets/script_edit_dialog.dart
// =============================================================================