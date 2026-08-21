// =============================================================================
// FILE START: lib/features/remote/presentation/widgets/terminal_sheet.dart
// =============================================================================

import 'package:kompyuter_sirlari/imports.dart';

/// Interaktiv terminal (quyi oyna).
class TerminalSheet extends StatefulWidget {
  const TerminalSheet({
    super.key,
    required this.logs,
    required this.lang,
    required this.onSend,
  });

  final List<String> logs;
  final String lang;
  final Future<void> Function(String command) onSend;

  @override
  State<TerminalSheet> createState() => _TerminalSheetState();
}

class _TerminalSheetState extends State<TerminalSheet> {
  final TextEditingController _commandController = TextEditingController();

  @override
  void dispose() {
    _commandController.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final command = _commandController.text.trim();
    if (command.isEmpty) return;
    _commandController.clear();
    await widget.onSend(command);
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
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
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  tooltip: tr(widget.lang, 'close'),
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const Divider(color: Colors.grey),
            Expanded(
              child: ListView.builder(
                itemCount: widget.logs.length,
                itemBuilder: (context, i) => Text(
                  widget.logs[i],
                  style: const TextStyle(
                    color: Colors.green,
                    fontFamily: 'monospace',
                    fontSize: 12,
                  ),
                ),
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _commandController,
                    style: const TextStyle(color: Colors.white, fontFamily: 'monospace'),
                    decoration: const InputDecoration(
                      hintText: "PowerShell buyrug'i...",
                      hintStyle: TextStyle(color: Colors.grey),
                      border: InputBorder.none,
                    ),
                  ),
                ),
                IconButton(
                  tooltip: tr(widget.lang, 'send'),
                  icon: const Icon(Icons.send_rounded, color: Colors.greenAccent),
                  onPressed: _send,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
// =============================================================================
// FILE END: lib/features/remote/presentation/widgets/terminal_sheet.dart
// =============================================================================