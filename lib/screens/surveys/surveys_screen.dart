import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:metrixvox_admin/config/theme.dart';
import 'package:metrixvox_admin/models/survey_summary.dart';
import 'package:metrixvox_admin/providers/auth_provider.dart';
import 'package:metrixvox_admin/providers/surveys_provider.dart';
import 'package:metrixvox_admin/providers/tenant_provider.dart';

class SurveysScreen extends StatefulWidget {
  const SurveysScreen({super.key});

  @override
  State<SurveysScreen> createState() => _SurveysScreenState();
}

class _SurveysScreenState extends State<SurveysScreen> {
  String? _loadedTenantId;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadIfNeeded();
  }

  void _loadIfNeeded() {
    final auth = context.watch<AuthProvider>();
    final tenant = context.watch<TenantProvider>().selected;

    if (auth.token != null &&
        tenant != null &&
        tenant.tenantId != _loadedTenantId) {
      _loadedTenantId = tenant.tenantId;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.read<SurveysProvider>().load(
              token: auth.token!,
              tenantId: tenant.tenantId,
            );
      });
    }
  }

  Future<void> _delete(SurveySummary survey) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Desactivar encuesta'),
        content: Text('Desactivar "${survey.title}"?\n\nNo se eliminaran las respuestas existentes.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: AdminTheme.rose),
            child: const Text('Desactivar'),
          ),
        ],
      ),
    );

    if (confirm != true) return;
    if (!mounted) return;

    final auth = context.read<AuthProvider>();
    final tenant = context.read<TenantProvider>().selected;
    if (auth.token == null || tenant == null) return;

    try {
      await context.read<SurveysProvider>().delete(
            token: auth.token!,
            tenantId: tenant.tenantId,
            surveyCode: survey.surveyCode,
          );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Encuesta desactivada')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SurveysProvider>();
    final tenant = context.watch<TenantProvider>().selected;

    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Encuestas',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        color: AdminTheme.dark,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      tenant == null
                          ? 'Selecciona un cliente'
                          : 'Cliente: ${tenant.name} · ${provider.surveys.length} encuestas',
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 14,
                        color: AdminTheme.gray,
                      ),
                    ),
                  ],
                ),
              ),
              ElevatedButton.icon(
                onPressed: tenant == null
                    ? null
                    : () => context.go('/surveys/new'),
                icon: const Icon(Icons.add),
                label: const Text('Nueva encuesta'),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Expanded(
            child: provider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : provider.error != null
                    ? Center(
                        child: Text(
                          provider.error!,
                          style: const TextStyle(color: AdminTheme.rose),
                        ),
                      )
                    : provider.surveys.isEmpty
                        ? _EmptyState(
                            onCreate: tenant == null
                                ? null
                                : () => context.go('/surveys/new'),
                          )
                        : ListView.separated(
                            itemCount: provider.surveys.length,
                            separatorBuilder: (_, __) => const SizedBox(height: 12),
                            itemBuilder: (context, index) {
                              final survey = provider.surveys[index];
                              return _SurveyCard(
                                survey: survey,
                                onEdit: () =>
                                    context.go('/surveys/${survey.surveyCode}'),
                                onDelete: () => _delete(survey),
                              );
                            },
                          ),
          ),
        ],
      ),
    );
  }
}

class _SurveyCard extends StatelessWidget {
  final SurveySummary survey;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _SurveyCard({
    required this.survey,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AdminTheme.border),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: survey.isActive
                  ? AdminTheme.indigo.withOpacity(0.12)
                  : AdminTheme.gray.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.assignment,
              color: survey.isActive ? AdminTheme.indigo : AdminTheme.gray,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        survey.title,
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AdminTheme.dark,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    _StatusBadge(isActive: survey.isActive),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  survey.surveyCode,
                  style: const TextStyle(
                    fontFamily: 'Courier New',
                    fontSize: 12,
                    color: AdminTheme.gray,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${survey.sectionCount} secciones · ${survey.questionCount} preguntas · ${survey.industryType}',
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 12,
                    color: AdminTheme.gray,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: 'Editar',
            onPressed: onEdit,
            color: AdminTheme.indigo,
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            tooltip: 'Desactivar',
            onPressed: onDelete,
            color: AdminTheme.rose,
          ),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final bool isActive;

  const _StatusBadge({required this.isActive});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: isActive
            ? AdminTheme.emerald.withOpacity(0.12)
            : AdminTheme.gray.withOpacity(0.15),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        isActive ? 'Activa' : 'Inactiva',
        style: TextStyle(
          fontFamily: 'Inter',
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: isActive ? AdminTheme.emerald : AdminTheme.gray,
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final VoidCallback? onCreate;

  const _EmptyState({this.onCreate});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.assignment_outlined, size: 64, color: AdminTheme.gray.withOpacity(0.4)),
          const SizedBox(height: 16),
          const Text(
            'Aun no hay encuestas',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AdminTheme.gray,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Crea tu primera encuesta para empezar a capturar',
            style: TextStyle(fontFamily: 'Inter', fontSize: 14, color: AdminTheme.gray),
          ),
          if (onCreate != null) ...[
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onCreate,
              icon: const Icon(Icons.add),
              label: const Text('Crear encuesta'),
            ),
          ],
        ],
      ),
    );
  }
}
