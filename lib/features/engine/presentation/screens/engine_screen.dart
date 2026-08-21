// =============================================================================
// FILE START: lib/features/engine/presentation/screens/engine_screen.dart
// =============================================================================

import 'package:kompyuter_sirlari/imports.dart';

/// Desktop Engine (Windows/Linux): mahalliy server + QR + konsol loglari.
class EngineScreen extends StatefulWidget {
  const EngineScreen({super.key});

  @override
  State<EngineScreen> createState() => _EngineScreenState();
}

class _EngineScreenState extends State<EngineScreen> {
  late final LocalEngineServer _server = LocalEngineServer(onLog: _addLog);
  final List<String> _logs = [];
  String _localIp = 'Izlanmoqda...';

  @override
  void initState() {
    super.initState();
    _server.start().then((_) {
      if (mounted && _server.localAddress != null) {
        setState(() => _localIp = _server.localAddress!);
      }
    });
  }

  @override
  void dispose() {
    _server.stop();
    super.dispose();
  }

  void _addLog(String msg) {
    if (!mounted) return;
    setState(() {
      _logs.add('[${DateTime.now().toString().split('.').first}] $msg');
    });
  }

  @override
  Widget build(BuildContext context) {
    final osTitle = Platform.isWindows ? 'Windows' : 'Linux';

    return Scaffold(
      appBar: AppBar(
        title: Text('${AppMeta.engineTitle} ($osTitle)'),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16.0),
            child: Chip(
              avatar: Icon(Icons.security, color: Colors.blueAccent, size: 18),
              label: Text(
                'Dinamik Sudo/Admin Active',
                style: TextStyle(fontSize: 12),
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            // QR Kod va ulanish paneli
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
            // Konsol loglari
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
// =============================================================================
// FILE END: lib/features/engine/presentation/screens/engine_screen.dart
// =============================================================================