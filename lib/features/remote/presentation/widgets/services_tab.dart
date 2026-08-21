// =============================================================================
// FILE START: lib/features/remote/presentation/widgets/services_tab.dart
// =============================================================================
import 'package:kompyuter_sirlari/imports.dart';

/// TAB 0 — Xizmatlar (qidiruv + OS filtri + skriptlar ro'yxati).
class ServicesTab extends StatefulWidget {
  const ServicesTab({
    super.key,
    required this.lang,
    required this.scripts,
    required this.isLoading,
    required this.onRefresh,
    required this.onLoadToRemote,
  });

  final String lang;
  final List<AppScript> scripts;
  final bool isLoading;
  final Future<void> Function() onRefresh;
  final ValueChanged<AppScript> onLoadToRemote;

  @override
  State<ServicesTab> createState() => _ServicesTabState();
}

class _ServicesTabState extends State<ServicesTab> {
  String _searchQuery = '';
  String _osFilter = 'all';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final lang = widget.lang;

    final filtered = widget.scripts.where((s) {
      final title = s.titleFor(lang).toLowerCase();
      final os = s.os.toLowerCase();
      final matchesOs = _osFilter == 'all' || os == _osFilter;
      final matchesSearch = title.contains(_searchQuery.toLowerCase());
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
                tr(lang, 'tab_services'),
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
              ),
              IconButton.filledTonal(
                tooltip: tr(lang, 'tab_services'),
                icon: const Icon(Icons.refresh_rounded),
                onPressed: widget.onRefresh,
              ),
            ],
          ),
          const SizedBox(height: 12),

          TextField(
            onChanged: (v) => setState(() => _searchQuery = v),
            decoration: InputDecoration(
              hintText: tr(lang, 'search_hint'),
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
                selected: _osFilter == 'all',
                label: Text(tr(lang, 'all')),
                onSelected: (_) => setState(() => _osFilter = 'all'),
              ),
              const SizedBox(width: 8),
              FilterChip(
                selected: _osFilter == 'windows',
                label: const Text('Windows'),
                onSelected: (_) => setState(() => _osFilter = 'windows'),
              ),
              const SizedBox(width: 8),
              FilterChip(
                selected: _osFilter == 'linux',
                label: const Text('Linux'),
                onSelected: (_) => setState(() => _osFilter = 'linux'),
              ),
            ],
          ),
          const SizedBox(height: 16),

          Expanded(
            child: widget.isLoading
                ? const Center(child: CircularProgressIndicator())
                : filtered.isEmpty
                    ? Center(child: Text(tr(lang, 'no_services')))
                    : ListView.separated(
                        itemCount: filtered.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 12),
                        itemBuilder: (context, index) =>
                            _scriptCard(filtered[index], colorScheme, lang),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _scriptCard(AppScript script, ColorScheme colorScheme, String lang) {
    final title = script.titleFor(lang);
    final info = script.infoFor(lang);

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(24),
        border: script.isDangerous
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
                script.osIcon,
                color: script.isDangerous
                    ? colorScheme.error
                    : colorScheme.primary,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
            ],
          ),
          if (info.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              info,
              style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 13),
            ),
          ],
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              OutlinedButton.icon(
                onPressed: () => widget.onLoadToRemote(script),
                icon: const Icon(Icons.add_to_home_screen_rounded),
                label: Text(tr(lang, 'load_to_remote')),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
// =============================================================================
// FILE END: lib/features/remote/presentation/widgets/services_tab.dart
// =============================================================================