import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:metrixvox_admin/config/theme.dart';
import 'package:metrixvox_admin/models/survey_question.dart';

/// Tipos de pregunta soportados.
const _questionTypes = [
  'CSAT_5',       // Emojis 😡🙁😐🙂😍
  'YES_NO',       // Sí / No
  'NPS_10',       // Escala 0-10
  'MULTIPLE_CHOICE', // Botones de opciones
  'TEXT',         // Campo de texto libre
];

class QuestionFormDialog extends StatefulWidget {
  final SurveyQuestion? initial;

  const QuestionFormDialog({super.key, this.initial});

  @override
  State<QuestionFormDialog> createState() => _QuestionFormDialogState();
}

class _QuestionFormDialogState extends State<QuestionFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _textController;
  late TextEditingController _weightController;
  late TextEditingController _optionsController;
  late String _type;
  late bool _isRequired;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController(text: widget.initial?.text ?? '');
    _weightController =
        TextEditingController(text: (widget.initial?.weight ?? 1.0).toString());
    _optionsController = TextEditingController(
        text: _parseOptionsForEdit(widget.initial?.optionsJson));
    _type = widget.initial?.type ?? 'CSAT_5';
    _isRequired = widget.initial?.isRequired ?? true;
  }

  String _parseOptionsForEdit(String? json) {
    if (json == null || json.isEmpty) return '';
    try {
      final list = jsonDecode(json) as List;
      return list.map((e) => e.toString()).join(', ');
    } catch (_) {
      return '';
    }
  }

  String? _buildOptionsJson() {
    if (_type != 'MULTIPLE_CHOICE' && _type != 'YES_NO') return null;
    final raw = _optionsController.text.trim();
    if (raw.isEmpty) return null;
    final list = raw
        .split(',')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();
    return jsonEncode(list);
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final weight = double.tryParse(_weightController.text.trim()) ?? 1.0;
    final optionsJson = _buildOptionsJson();

    final question = SurveyQuestion(
      id: widget.initial?.id ?? '',
      text: _textController.text.trim(),
      type: _type,
      isRequired: _isRequired,
      weight: weight,
      optionsJson: optionsJson,
    );

    Navigator.pop(context, question);
  }

  @override
  void dispose() {
    _textController.dispose();
    _weightController.dispose();
    _optionsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final showOptions = _type == 'MULTIPLE_CHOICE' || _type == 'YES_NO';

    return AlertDialog(
      title: Text(widget.initial == null ? 'Nueva pregunta' : 'Editar pregunta'),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      content: SizedBox(
        width: 500,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _textController,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'Texto de la pregunta',
                  border: OutlineInputBorder(),
                ),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Requerido' : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _type,
                decoration: const InputDecoration(
                  labelText: 'Tipo de pregunta',
                  border: OutlineInputBorder(),
                ),
                items: _questionTypes
                    .map((t) => DropdownMenuItem(value: t, child: Text(_typeLabel(t))))
                    .toList(),
                onChanged: (v) => setState(() => _type = v ?? 'CSAT_5'),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _weightController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Peso',
                        helperText: 'Para el score ponderado',
                        border: OutlineInputBorder(),
                      ),
                      validator: (v) {
                        final n = double.tryParse(v?.trim() ?? '');
                        if (n == null || n <= 0) return 'Número > 0';
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: SwitchListTile(
                      title: const Text('Requerida'),
                      value: _isRequired,
                      onChanged: (v) => setState(() => _isRequired = v),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ],
              ),
              if (showOptions) ...[
                const SizedBox(height: 16),
                TextFormField(
                  controller: _optionsController,
                  decoration: const InputDecoration(
                    labelText: 'Opciones (separadas por coma)',
                    helperText: 'Ej: Si, No, Tal vez',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: _submit,
          child: const Text('Guardar pregunta'),
        ),
      ],
    );
  }

  String _typeLabel(String type) {
    switch (type) {
      case 'CSAT_5':
        return 'CSAT 5 (emojis 😡🙁😐🙂😍)';
      case 'YES_NO':
        return 'Sí / No';
      case 'NPS_10':
        return 'NPS 10 (escala 0-10)';
      case 'MULTIPLE_CHOICE':
        return 'Opción múltiple';
      case 'TEXT':
        return 'Texto libre';
      default:
        return type;
    }
  }
}
