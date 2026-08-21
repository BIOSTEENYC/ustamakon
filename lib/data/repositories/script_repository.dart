// =============================================================================
// FILE START: lib/data/repositories/script_repository.dart
// =============================================================================

import 'package:kompyuter_sirlari/imports.dart';

/// Supabase `scripts` jadvali bilan ishlash (CRUD) — yagona kirish nuqtasi.
class ScriptRepository {
  ScriptRepository(this._client);

  final SupabaseClient _client;

  static final instance = ScriptRepository(Supabase.instance.client);

  Future<List<AppScript>> fetchAll() async {
    final rows = await _client.from('scripts').select();
    return (rows as List)
        .map((r) => AppScript.fromJson(Map<String, dynamic>.from(r as Map)))
        .toList();
  }

  Future<void> add(ScriptDraft draft) async {
    await _client.from('scripts').insert(draft.toPayload());
  }

  Future<void> update(dynamic id, ScriptDraft draft) async {
    await _client.from('scripts').update(draft.toPayload()).eq('id', id);
  }

  Future<void> delete(dynamic id) async {
    await _client.from('scripts').delete().eq('id', id);
  }
}
// =============================================================================
// FILE END: lib/data/repositories/script_repository.dart
// =============================================================================