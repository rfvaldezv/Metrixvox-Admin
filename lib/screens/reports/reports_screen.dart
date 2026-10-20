import 'dart:html' as html;
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:metrixvox_admin/config/theme.dart';
import 'package:metrixvox_admin/providers/auth_provider.dart';
import 'package:metrixvox_admin/providers/tenant_provider.dart';
import 'package:metrixvox_admin/services/report_service.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  DateTime _dateFrom = DateTime.now().subtract(const Duration(days: 30));
  DateTime _dateTo = DateTime.now();
  bool _isGenerating = false;
  Map<String, dynamic>? _analysisResult;
  String? _error;

  // Estado para el historial
  bool _isLoadingHistory = false;
  List<dynamic> _history = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final tenantProvider = context.read<TenantProvider>();
      final auth = context.read<AuthProvider>();
      
      if (tenantProvider.tenants.isEmpty && auth.token != null) {
        await tenantProvider.loadTenants(auth.token!);
      }
      _loadHistory();
    });
  }

  Future<void> _loadHistory() async {
    final auth = context.read<AuthProvider>();
    final tenant = context.read<TenantProvider>().selected;
    if (auth.token == null || tenant == null) return;

    setState(() => _isLoadingHistory = true);
    try {
      final history = await ReportService.getHistory(
        token: auth.token!,
        tenantId: tenant.tenantId,
      );
      if (mounted) {
        setState(() {
          _history = history;
          _isLoadingHistory = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoadingHistory = false);
    }
  }

  Future<void> _generateAnalysis() async {
    final auth = context.read<AuthProvider>();
    final tenant = context.read<TenantProvider>().selected;
    
    if (auth.token == null || tenant == null) {
      setState(() => _error = 'Por favor, selecciona un cliente en el menú superior.');
      return;
    }

    setState(() {
      _isGenerating = true;
      _error = null;
      _analysisResult = null;
    });

    try {
      final result = await ReportService.generateAnalysis(
        token: auth.token!,
        tenantId: tenant.tenantId,
        surveyCode: 'SURVEY_HOSPITAL_JARDINADAS',
        dateFrom: _dateFrom,
        dateTo: _dateTo,
      );

      if (mounted) {
        setState(() {
          _analysisResult = result;
          _isGenerating = false;
        });
        _loadHistory();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isGenerating = false;
        });
      }
    }
  }

  Future<void> _downloadPdfById(String id) async {
    final auth = context.read<AuthProvider>();
    if (auth.token == null) return;

    final url = ReportService.getPdfUrlById(id);

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {'Authorization': 'Bearer ${auth.token}'},
      );

      if (response.statusCode == 200) {
        final bytes = response.bodyBytes;
        final blob = html.Blob([bytes], 'application/pdf');
        final blobUrl = html.Url.createObjectUrlFromBlob(blob);
        final anchor = html.document.createElement('a') as html.AnchorElement
          ..href = blobUrl
          ..style.display = 'none'
          ..download = 'Reporte_Ejecutivo_$id.pdf';
        
        html.document.body?.children.add(anchor);
        anchor.click();
        html.document.body?.children.remove(anchor);
        html.Url.revokeObjectUrl(blobUrl);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error al descargar: ${response.statusCode}')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error de conexión: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Reportes Ejecutivos',
            style: TextStyle(fontFamily: 'Poppins', fontSize: 28, fontWeight: FontWeight.w700, color: AdminTheme.dark),
          ),
          const SizedBox(height: 16),

          // SELECTOR DE CLIENTE
          Row(
            children: [
              const Text('Cliente: ', style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(width: 8),
              Consumer<TenantProvider>(
                builder: (context, tenantProvider, child) {
                  if (tenantProvider.tenants.isEmpty) return const Text('Cargando...');
                  return DropdownButton<String>(
                    value: tenantProvider.selected?.tenantId,
                    items: tenantProvider.tenants.map((t) {
                      return DropdownMenuItem<String>(value: t.tenantId, child: Text(t.name));
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) {
                        final t = tenantProvider.tenants.firstWhere((t) => t.tenantId == val);
                        tenantProvider.selectTenant(t);
                        _loadHistory();
                      }
                    },
                  );
                },
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // FILTROS Y BOTÓN DE GENERAR
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.calendar_today),
                  label: Text('Desde: ${_dateFrom.toString().split(' ')[0]}'),
                  onPressed: () async {
                    final d = await showDatePicker(context: context, initialDate: _dateFrom, firstDate: DateTime(2020), lastDate: DateTime.now());
                    if (d != null) setState(() => _dateFrom = d);
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.calendar_today),
                  label: Text('Hasta: ${_dateTo.toString().split(' ')[0]}'),
                  onPressed: () async {
                    final d = await showDatePicker(context: context, initialDate: _dateTo, firstDate: DateTime(2020), lastDate: DateTime.now());
                    if (d != null) setState(() => _dateTo = d);
                  },
                ),
              ),
              const SizedBox(width: 16),
              ElevatedButton.icon(
                onPressed: _isGenerating ? null : _generateAnalysis,
                icon: _isGenerating ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Icon(Icons.auto_awesome),
                label: Text(_isGenerating ? 'Analizando...' : 'Generar Análisis IA'),
              ),
            ],
          ),
          
          const SizedBox(height: 24),

          if (_error != null)
            Container(
              padding: const EdgeInsets.all(16),
              color: AdminTheme.rose.withOpacity(0.1),
              child: Text(_error!, style: const TextStyle(color: AdminTheme.rose)),
            ),

          // RESULTADO RECIÉN GENERADO
          if (_analysisResult != null)
            Container(
              margin: const EdgeInsets.only(bottom: 24),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: AdminTheme.border)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Análisis Recién Generado', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      ElevatedButton.icon(
                        onPressed: () => _downloadPdfById(_analysisResult!['id']),
                        icon: const Icon(Icons.picture_as_pdf),
                        label: const Text('Descargar PDF'),
                        style: ElevatedButton.styleFrom(backgroundColor: AdminTheme.emerald),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text('Sentimiento: ${_analysisResult!['generalSentiment']}', style: const TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(_analysisResult!['executiveSummary'] ?? '', style: const TextStyle(height: 1.5)),
                ],
              ),
            ),

          // HISTORIAL
          const Text('Historial de Reportes', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Expanded(
            child: _isLoadingHistory
                ? const Center(child: CircularProgressIndicator())
                : _history.isEmpty
                    ? const Center(child: Text('No hay reportes generados aún.'))
                    : ListView.separated(
                        itemCount: _history.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final item = _history[index];
                          
                          // Formatear fechas de creación y periodo
                          final createdAt = DateTime.parse(item['createdAt']).toLocal();
                          final dateFrom = DateTime.parse(item['dateFrom']).toLocal();
                          final dateTo = DateTime.parse(item['dateTo']).toLocal();

                          return Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: AdminTheme.border)),
                            child: Row(
                              children: [
                                const Icon(Icons.insert_drive_file, color: AdminTheme.indigo, size: 32),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      // Mostrar el periodo en el título
                                      Text(
                                        'Periodo: ${dateFrom.day}/${dateFrom.month}/${dateFrom.year} al ${dateTo.day}/${dateTo.month}/${dateTo.year}', 
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)
                                      ),
                                      const SizedBox(height: 4),
                                      // Mostrar cuándo se generó, respuestas y sentimiento
                                      Text(
                                        'Generado el ${createdAt.day}/${createdAt.month}/${createdAt.year} · ${item['totalResponses']} respuestas · Sentimiento: ${item['generalSentiment']}', 
                                        style: const TextStyle(color: AdminTheme.gray, fontSize: 13)
                                      ),
                                    ],
                                  ),
                                ),
                                ElevatedButton.icon(
                                  onPressed: () => _downloadPdfById(item['id']),
                                  icon: const Icon(Icons.download),
                                  label: const Text('Descargar'),
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
}
