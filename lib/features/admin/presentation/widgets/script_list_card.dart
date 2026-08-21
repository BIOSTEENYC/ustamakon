// =============================================================================
// FILE START: lib/features/admin/presentation/widgets/script_list_card.dart
// =============================================================================

import 'package:kompyuter_sirlari/imports.dart';

class ScriptListCard extends StatefulWidget {
  const ScriptListCard({super.key, this.languageCode = 'uz'});

  /// Ro'yxat matnini ko'rsatish tili.
  final String languageCode;

  @override
  ScriptListCardState createState() => ScriptListCardState();
}

class ScriptListCardState extends State<ScriptListCard> {
  final TextEditingController _searchController = TextEditingController();
  late Future<List<AppScript>> _scriptsFuture;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _scriptsFuture = ScriptRepository.instance.fetchAll();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// Formada yangi yozuv qo'shilganda ro'yxatni yangilash uchun.
  void refresh() => setState(() {
        _scriptsFuture = ScriptRepository.instance.fetchAll();
      });

  Future<void> _delete(AppScript script) async {
    try {
      await ScriptRepository.instance.delete(script.id);
      if (!mounted) return;
      refresh();
      showAppSnack(context, "🗑 Skript o'chirildi!", duration: const Duration(seconds: 1));
    } catch (e) {
      if (!mounted) return;
      showAppSnack(context, "O'chirishda xatolik: $e", isError: true);
    }
  }

  void _edit(AppScript script) {
    showDialog<bool>(
      context: context,
      builder: (_) => ScriptEditDialog(script: script),
    ).then((saved) {
      if (saved == true && mounted) refresh();
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
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
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
            child: FutureBuilder<List<AppScript>>(
              future: _scriptsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text("Xatolik: ${snapshot.error}"));
                }

                final filtered = (snapshot.data ?? [])
                    .where((s) =>
                        s.titleFor(widget.languageCode).toLowerCase().contains(_searchQuery) ||
                        s.os.toLowerCase().contains(_searchQuery))
                    .toList();

                if (filtered.isEmpty) {
                  return const Center(child: Text('Skriptlar topilmadi.'));
                }

                return ListView.separated(
                  itemCount: filtered.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 12),
                  itemBuilder: (context, index) =>
                      _scriptItem(filtered[index], colorScheme),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _scriptItem(AppScript script, ColorScheme colorScheme) {
    final title = script.titleFor(widget.languageCode).isEmpty
        ? 'Nomsiz'
        : script.titleFor(widget.languageCode);
    final info = script.infoFor(widget.languageCode);

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(24),
        border: script.isDangerous
            ? Border.all(color: colorScheme.error, width: 2)
            : null,
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: script.isDangerous
                  ? colorScheme.errorContainer
                  : colorScheme.secondaryContainer,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Icon(
              script.osIcon,
              color: script.isDangerous
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
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
                ),
                const SizedBox(height: 4),
                Text(
                  info,
                  style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 13),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  children: [
                    TagPill(label: script.os.toUpperCase()),
                    TagPill(label: script.category),
                  ],
                ),
              ],
            ),
          ),
          Column(
            children: [
              IconButton.filledTonal(
                icon: const Icon(Icons.edit_rounded, size: 20),
                onPressed: () => _edit(script),
              ),
              const SizedBox(height: 6),
              IconButton(
                icon: Icon(Icons.delete_outline_rounded, color: colorScheme.error),
                onPressed: () => _delete(script),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
// =============================================================================
// FILE END: lib/features/admin/presentation/widgets/script_list_card.dart
// =============================================================================