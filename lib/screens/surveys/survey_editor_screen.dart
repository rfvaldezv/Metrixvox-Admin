import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:metrixvox_admin/config/theme.dart';
import 'package:metrixvox_admin/models/survey_question.dart';
import 'package:metrixvox_admin/providers/auth_provider.dart';
import 'package:metrixvox_admin/providers/tenant_provider.dart';
import 'package:metrixvox_admin/screens/surveys/question_form_dialog.dart';
import 'package:metrixvox_admin/services/survey_admin_service.dart';

class SurveyEditorScreen extends StatefulWidget {
  final String? surveyCode; // null = nueva, no-null = editar

  const SurveyEditorScreen({super.key, this.surveyCode});

  @override
  State<SurveyEditorScreen> createState() => _SurveyEditorScreenState();
}

class _SurveyEditorScreenState extends State<SurveyEditorScreen> {
  final _formKey = GlobalKey<FormState>();
  final _codeController = TextEditingController();
  final _titleController = TextEditingController();
  final _industryController = TextEditingController(text: 'Generic');

  final List<_EditableSection> _sections = [];
  bool _isLoading = true;
  bool _isSaving = false;
  String? _error;

  bool get _isEditing => widget.surveyCode != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      _loadSurvey();
    } else {
      _codeController.text = 'SURVEY_';
      _sections.add(_EditableSection(title: 'Nueva sección'));
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadSurvey() async {
    final auth = context.read<AuthProvider>();
    final tenant = context.read<TenantProvider>().selected;
    if (auth.token == null || tenant == null) return;

    try {
      final detail = await SurveyAdminService.getByCode(
        token: auth.token!,
        tenantId: tenant.tenantId,
        surveyCode: widget.surveyCode!,
      );

      _codeController.text = detail.surveyCode;
      _titleController.text = detail.surveyTitle;
      _industryController.text = detail.industryType;

      _sections.clear();
      for (final sec in detail.sections) {
        final editable = _EditableSection(title: sec.sectionName);
        for (final q in sec.questions) {
          editable.questions.add(q);
        }
        _sections.add(editable);
      }

      if (mounted) setState(() => _isLoading = false);
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    if (_sections.isEmpty) {
      setState(() => _error = 'Agrega al menos una sección');
      return;
    }

    final hasQuestions = _sections.any((s) => s.questions.isNotEmpty);
    if (!hasQuestions) {
      setState(() => _error = 'Agrega al menos una pregunta');
      return;
    }

    setState(() {
      _isSaving = true;
      _error = null;
    });

    final auth = context.read<AuthProvider>();
    final tenant = context.read<TenantProvider>().selected;
    if (auth.token == null || tenant == null) return;

    try {
      final sectionsModel = _sections
          .map((s) => SurveySection(
                sectionName: s.title,
                questions: s.questions,
              ))
          .toList();

      await SurveyAdminService.create(
        token: auth.token!,
        tenantId: tenant.tenantId,
        surveyCode: _codeController.text.trim().toUpperCase(),
        surveyTitle: _titleController.text.trim(),
        industryType: _industryController.text.trim(),
        scope: 'Customer',
        sections: sectionsModel,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_isEditing ? 'Encuesta actualizada' : 'Encuesta creada'),
          backgroundColor: AdminTheme.emerald,
        ),
      );
      context.go('/surveys');
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSaving = false;
          _error = e.toString();
        });
      }
    }
  }

  Future<void> _addSection() async {
    final name = await _showTextInputDialog(
      title: 'Nueva sección',
      label: 'Nombre de la sección',
    );
    if (name == null || name.isEmpty) return;
    setState(() => _sections.add(_EditableSection(title: name)));
  }

  Future<void> _addQuestion(int sectionIndex) async {
    final question = await showDialog<SurveyQuestion>(
      context: context,
      builder: (_) => const QuestionFormDialog(),
    );
    if (question == null) return;
    setState(() => _sections[sectionIndex].questions.add(question));
  }

  Future<void> _editQuestion(int sectionIndex, int questionIndex) async {
    final current = _sections[sectionIndex].questions[questionIndex];
    final question = await showDialog<SurveyQuestion>(
      context: context,
      builder: (_) => QuestionFormDialog(initial: current),
    );
    if (question == null) return;
    setState(() => _sections[sectionIndex].questions[questionIndex] = question);
  }

  Future<String?> _showTextInputDialog({
    required String title,
    required String label,
  }) async {
    final controller = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(labelText: label),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: const Text('Aceptar'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _codeController.dispose();
    _titleController.dispose();
    _industryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: AdminTheme.lightGray,
      appBar: AppBar(
        title: Text(_isEditing ? 'Editar encuesta' : 'Nueva encuesta'),
        backgroundColor: AdminTheme.indigo,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/surveys'),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Datos generales
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AdminTheme.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text('Información general',
                        style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 18,
                            fontWeight: FontWeight.w600)),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _codeController,
                      enabled: !_isEditing,
                      decoration: const InputDecoration(
                        labelText: 'Código (ej. SURVEY_CLINICA_01)',
                        prefixIcon: Icon(Icons.tag),
                      ),
                      validator: (v) =>
                          v == null || v.trim().isEmpty ? 'Requerido' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _titleController,
                      decoration: const InputDecoration(
                        labelText: 'Título de la encuesta',
                        prefixIcon: Icon(Icons.title),
                      ),
                      validator: (v) =>
                          v == null || v.trim().isEmpty ? 'Requerido' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _industryController,
                      decoration: const InputDecoration(
                        labelText: 'Industria (Healthcare, Retail, etc.)',
                        prefixIcon: Icon(Icons.business),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Secciones
              ..._sections.asMap().entries.map((entry) {
                final sIndex = entry.key;
                final section = entry.value;
                return _SectionEditor(
                  section: section,
                  onAddQuestion: () => _addQuestion(sIndex),
                  onEditQuestion: (qIndex) => _editQuestion(sIndex, qIndex),
                  onDeleteQuestion: (qIndex) => setState(
                      () => section.questions.removeAt(qIndex)),
                  onDeleteSection: () => setState(() => _sections.removeAt(sIndex)),
                  onTitleChanged: (title) => section.title = title,
                );
              }),
              const SizedBox(height: 16),

              OutlinedButton.icon(
                onPressed: _addSection,
                icon: const Icon(Icons.add),
                label: const Text('Agregar sección'),
              ),
              const SizedBox(height: 24),

              if (_error != null)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AdminTheme.rose.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(_error!, style: const TextStyle(color: AdminTheme.rose)),
                ),
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _isSaving ? null : () => context.go('/surveys'),
                      child: const Text('Cancelar'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton.icon(
                      onPressed: _isSaving ? null : _save,
                      icon: _isSaving
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: Colors.white),
                            )
                          : const Icon(Icons.save),
                      label: Text(_isSaving ? 'Guardando...' : 'Guardar encuesta'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EditableSection {
  String title;
  final List<SurveyQuestion> questions;
  _EditableSection({required this.title, List<SurveyQuestion>? initial})
      : questions = initial ?? [];
}

class _SectionEditor extends StatelessWidget {
  final _EditableSection section;
  final VoidCallback onAddQuestion;
  final ValueChanged<int> onEditQuestion;
  final ValueChanged<int> onDeleteQuestion;
  final VoidCallback onDeleteSection;
  final ValueChanged<String> onTitleChanged;

  const _SectionEditor({
    required this.section,
    required this.onAddQuestion,
    required this.onEditQuestion,
    required this.onDeleteQuestion,
    required this.onDeleteSection,
    required this.onTitleChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AdminTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  initialValue: section.title,
                  onChanged: onTitleChanged,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                  decoration: const InputDecoration(
                    labelText: 'Título de la sección',
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline),
                tooltip: 'Eliminar sección',
                onPressed: onDeleteSection,
                color: AdminTheme.rose,
              ),
            ],
          ),
          const Divider(height: 24),
          ...section.questions.asMap().entries.map((entry) {
            final qIndex = entry.key;
            final q = entry.value;
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AdminTheme.lightGray,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(q.text, style: const TextStyle(fontWeight: FontWeight.w500)),
                        const SizedBox(height: 2),
                        Text('${q.type} · Peso: ${q.weight}',
                            style: const TextStyle(fontSize: 11, color: AdminTheme.gray)),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit, size: 18),
                    onPressed: () => onEditQuestion(qIndex),
                    color: AdminTheme.indigo,
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, size: 18),
                    onPressed: () => onDeleteQuestion(qIndex),
                    color: AdminTheme.rose,
                  ),
                ],
              ),
            );
          }),
          TextButton.icon(
            onPressed: onAddQuestion,
            icon: const Icon(Icons.add),
            label: const Text('Agregar pregunta'),
          ),
        ],
      ),
    );
  }
}
