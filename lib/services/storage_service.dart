import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../models/historico_entry.dart';
import '../models/resultado.dart';

/// Persistência local (histórico e relatórios). O COCOS funciona 100%
/// offline, então tudo fica salvo apenas no dispositivo do usuário.
class StorageService {
  StorageService._();

  static const _historicoKey = 'cocos:historico';
  static const _relatoriosKey = 'cocos:relatorios';
  static const _uuid = Uuid();

  static String genId() => _uuid.v4();

  // ── Histórico ────────────────────────────────────────────────────────────

  static Future<List<HistoricoEntry>> loadHistorico() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_historicoKey);
    if (raw == null) return [];
    try {
      final list = jsonDecode(raw) as List;
      return list
          .map((e) => HistoricoEntry.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  static Future<void> saveHistoricoEntry(HistoricoEntry entry) async {
    final prefs = await SharedPreferences.getInstance();
    final current = await loadHistorico();
    final updated = [entry, ...current].take(100).toList();
    await prefs.setString(
        _historicoKey, jsonEncode(updated.map((e) => e.toJson()).toList()));
  }

  static Future<List<HistoricoEntry>> deleteHistoricoEntry(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final current = await loadHistorico();
    final updated = current.where((e) => e.id != id).toList();
    await prefs.setString(
        _historicoKey, jsonEncode(updated.map((e) => e.toJson()).toList()));
    return updated;
  }

  static Future<void> clearHistorico() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_historicoKey);
  }

  // ── Relatórios ───────────────────────────────────────────────────────────

  static Future<List<Relatorio>> loadRelatorios() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_relatoriosKey);
    if (raw == null) return [];
    try {
      final list = jsonDecode(raw) as List;
      return list.map((e) => Relatorio.fromJson(e as Map<String, dynamic>)).toList();
    } catch (_) {
      return [];
    }
  }

  static Future<void> saveRelatorio(Relatorio rel) async {
    final prefs = await SharedPreferences.getInstance();
    final current = await loadRelatorios();
    final updated = [rel, ...current].take(50).toList();
    await prefs.setString(
        _relatoriosKey, jsonEncode(updated.map((e) => e.toJson()).toList()));
  }
}
