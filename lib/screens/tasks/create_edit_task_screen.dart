import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/firestore_service.dart';
import '../../theme/app_theme.dart';

class CreateEditTaskScreen extends StatefulWidget {
  final bool isEdit;
  const CreateEditTaskScreen({super.key, this.isEdit = false});

  @override
  State<CreateEditTaskScreen> createState() => _CreateEditTaskScreenState();
}

class _CreateEditTaskScreenState extends State<CreateEditTaskScreen> {
  static const _priorities = ['Alta', 'Media', 'Baja'];
  static const _categories = ['Hogar', 'Académicas', 'Mamá', 'Papá', 'Juan', 'Sofía'];

  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _assigneeController = TextEditingController();
  DateTime? _date;
  String _priority = 'Media';
  String _category = 'Hogar';
  bool _isSaving = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _assigneeController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _date ?? now,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 5),
    );
    if (picked != null) {
      setState(() => _date = picked);
    }
  }

  Future<void> _save() async {
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Escribe un título para la tarea')),
      );
      return;
    }
    setState(() => _isSaving = true);
    final auth = context.read<AuthProvider>();
    final familyId = await auth.familyIdForUser();
    if (!mounted) return;
    if (familyId == null) {
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No estás vinculado a una familia')),
      );
      return;
    }
    final data = <String, dynamic>{
      'title': _titleController.text.trim(),
      'description': _descriptionController.text.trim(),
      'date': _date ?? DateTime.now(),
      'priority': _priority,
      'category': _category,
      'assignee': _assigneeController.text.trim(),
      'completed': false,
      'createdBy': auth.user?.uid,
      'createdAt': FieldValue.serverTimestamp(),
    };
    await FirestoreService.createTask(familyId, data);
    if (!mounted) return;
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.isEdit ? 'Editar Tarea' : 'Crear Tarea')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Título', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(hintText: 'Título de la tarea'),
            ),
            const SizedBox(height: 16),

            const Text('Descripción', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextFormField(
              controller: _descriptionController,
              maxLines: 3,
              decoration: const InputDecoration(hintText: 'Descripción (Opcional)'),
            ),
            const SizedBox(height: 16),

            const Text('Fecha', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            InkWell(
              onTap: _pickDate,
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today_outlined, color: AppTheme.primaryColor, size: 20),
                    const SizedBox(width: 12),
                    Text(
                      _date == null
                          ? 'Seleccionar fecha'
                          : '${_date!.day}/${_date!.month}/${_date!.year}',
                      style: TextStyle(
                        color: _date == null ? AppTheme.textHint : AppTheme.textPrimary,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            const Text('Prioridad', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              initialValue: _priority,
              items: _priorities
                  .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                  .toList(),
              onChanged: (value) => setState(() => _priority = value ?? 'Media'),
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.priority_high, color: AppTheme.primaryColor),
              ),
            ),
            const SizedBox(height: 16),

            const Text('Categoría', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              initialValue: _category,
              items: _categories
                  .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                  .toList(),
              onChanged: (value) => setState(() => _category = value ?? 'Hogar'),
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.category_outlined, color: AppTheme.primaryColor),
              ),
            ),
            const SizedBox(height: 16),

            const Text('Asignado a', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextFormField(
              controller: _assigneeController,
              decoration: const InputDecoration(
                hintText: 'Miembro de la familia',
                prefixIcon: Icon(Icons.person_outline, color: AppTheme.primaryColor),
              ),
            ),
            const SizedBox(height: 32),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _save,
                child: _isSaving
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : Text(widget.isEdit ? 'Guardar Cambios' : 'Crear Tarea'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
