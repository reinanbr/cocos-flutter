import 'package:flutter/material.dart';
import '../constants/colors.dart';
import '../models/historico_entry.dart';
import '../services/storage_service.dart';
import '../utils/format.dart';
import '../widgets/app_scaffold.dart';
import '../widgets/misc.dart';

const _tipoLabel = {
  HistoricoTipo.unico: 'Análise Única',
  HistoricoTipo.serie: 'Série',
  HistoricoTipo.relatorio: 'Relatório',
};

class HistoricoScreen extends StatefulWidget {
  const HistoricoScreen({super.key});

  @override
  State<HistoricoScreen> createState() => _HistoricoScreenState();
}

class _HistoricoScreenState extends State<HistoricoScreen> {
  List<HistoricoEntry> _entries = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final data = await StorageService.loadHistorico();
    if (mounted) setState(() { _entries = data; _loading = false; });
  }

  Future<void> _onDelete(String id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir'),
        content: const Text('Remover esta análise do histórico?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Excluir', style: TextStyle(color: AppColors.alerta)),
          ),
        ],
      ),
    );
    if (confirm == true) {
      final updated = await StorageService.deleteHistoricoEntry(id);
      setState(() => _entries = updated);
    }
  }

  Future<void> _onClear() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Limpar tudo'),
        content: const Text('Excluir todas as análises salvas? Esta ação não pode ser desfeita.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Limpar', style: TextStyle(color: AppColors.alerta)),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await StorageService.clearHistorico();
      setState(() => _entries = []);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const AppScaffold(title: '📁 Histórico', body: Center(child: CircularProgressIndicator(color: AppColors.folha)));
    }

    final groups = <String, List<HistoricoEntry>>{};
    for (final e in _entries) {
      groups.putIfAbsent(formatDate(e.data), () => []).add(e);
    }

    return AppScaffold(
      title: '📁 Histórico',
      body: RefreshIndicator(
        onRefresh: _load,
        child: _entries.isEmpty
            ? ListView(children: const [
                EmptyState(
                  emoji: '📁',
                  title: 'Nenhuma análise salva',
                  desc: 'Faça sua primeira análise e ela aparecerá aqui automaticamente.',
                ),
              ])
            : ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('${_entries.length} análise${_entries.length != 1 ? "s" : ""} salva${_entries.length != 1 ? "s" : ""}',
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.texto)),
                      TextButton(
                        onPressed: _onClear,
                        child: const Text('Limpar tudo', style: TextStyle(fontSize: 13, color: AppColors.alerta, fontWeight: FontWeight.w700)),
                      ),
                    ],
                  ),
                  for (final entry in groups.entries) ...[
                    Padding(
                      padding: const EdgeInsets.only(top: 12, bottom: 8),
                      child: Text(entry.key,
                          style: const TextStyle(
                              fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textoSec, letterSpacing: 0.5)),
                    ),
                    for (final item in entry.value)
                      InkWell(
                        onLongPress: () => _onDelete(item.id),
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: AppColors.card,
                            borderRadius: BorderRadius.circular(12),
                            border: Border(
                              top: const BorderSide(color: AppColors.borda),
                              right: const BorderSide(color: AppColors.borda),
                              bottom: const BorderSide(color: AppColors.borda),
                              left: BorderSide(color: item.cor, width: 4),
                            ),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                      decoration: BoxDecoration(
                                          color: item.cor.withValues(alpha: 0.13), borderRadius: BorderRadius.circular(6)),
                                      child: Text(_tipoLabel[item.tipo]!,
                                          style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: item.cor, letterSpacing: 0.4)),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(item.titulo, maxLines: 2, overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.texto, height: 1.3)),
                                    Padding(
                                      padding: const EdgeInsets.only(top: 4),
                                      child: Text(formatTime(item.data), style: const TextStyle(fontSize: 11, color: AppColors.textoSec)),
                                    ),
                                  ],
                                ),
                              ),
                              Container(width: 10, height: 10, decoration: BoxDecoration(color: item.cor, shape: BoxShape.circle)),
                            ],
                          ),
                        ),
                      ),
                  ],
                  const Padding(
                    padding: EdgeInsets.only(top: 8),
                    child: Text('💡 Segure uma entrada para excluí-la',
                        textAlign: TextAlign.center, style: TextStyle(fontSize: 11, color: AppColors.textoSec)),
                  ),
                ],
              ),
      ),
    );
  }
}
