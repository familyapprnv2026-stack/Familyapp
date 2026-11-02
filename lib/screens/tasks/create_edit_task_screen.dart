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
  static const _categories = ['Hogar', 'Académicas'];

  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  List<Map<String, dynamic>> _members = [];
  String? _assignee;
  DateTime? _date;
  String _priority = 'Media';
  String _category = 'Hogar';
  bool _isSaving = false;
  bool _loadingMembers = true;

  @override
  void initState() {
    super.initState();
    _loadMembers();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _loadMembers() async {
    final auth = context.read<AuthProvider>();
    final familyId = await auth.familyIdForUser();
    List<Map<String, dynamic>> members = [];
    if (familyId != null) {
      members = await FirestoreService.getFamilyMembers(familyId);
    }
    if (!mounted) return;
    setState(() {
      _members = members;
      _loadingMembers = false;
    });
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
      'assignee': _assignee ?? '',
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
            Text('Título', style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            TextFormField(
              controller: _titleController,
              decoration: InputDecoration(hintText: 'Título de la tarea'),
            ),
            SizedBox(height: 16),

            Text('Descripción', style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            TextFormField(
              controller: _descriptionController,
              maxLines: 3,
              decoration: InputDecoration(hintText: 'Descripción (Opcional)'),
            ),
            SizedBox(height: 16),

            Text('Fecha', style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
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
                    Icon(Icons.calendar_today_outlined, color: AppTheme.primaryColor, size: 20),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _date == null
                            ? 'Seleccionar fecha'
                            : '${_date!.day}/${_date!.month}/${_date!.year}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: _date == null ? context.textHint : context.textPrimary,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 16),

            Text('Prioridad', style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            DropdownButtonFormField<String>(
              initialValue: _priority,
              isExpanded: true,
              items: _priorities
                  .map((p) => DropdownMenuItem(
                      value: p,
                      child: Text(p, maxLines: 1, overflow: TextOverflow.ellipsis)))
                  .toList(),
              onChanged: (value) => setState(() => _priority = value ?? 'Media'),
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.priority_high, color: AppTheme.primaryColor),
              ),
            ),
            SizedBox(height: 16),

            Text('Categoría', style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            DropdownButtonFormField<String>(
              initialValue: _category,
              isExpanded: true,
              items: _categories
                  .map((c) => DropdownMenuItem(
                      value: c,
                      child: Text(c, maxLines: 1, overflow: TextOverflow.ellipsis)))
                  .toList(),
              onChanged: (value) => setState(() => _category = value ?? 'Hogar'),
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.category_outlined, color: AppTheme.primaryColor),
              ),
            ),
            SizedBox(height: 16),

            Text('Asignado a', style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            _loadingMembers
                ? const LinearProgressIndicator()
                : DropdownButtonFormField<String>(
                    initialValue: _assignee,
                    isExpanded: true,
                    hint: Text('Miembro de la familia',
                        maxLines: 1, overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: context.textHint)),
                    items: _members
                        .map((m) {
                          final full =
                              '${m['name']} ${m['lastNames']}'.trim();
                          return DropdownMenuItem(
                              value: full,
                              child: Text(full,
                                  maxLines: 1, overflow: TextOverflow.ellipsis));
                        })
                        .toList(),
                    onChanged: (value) =>
                        setState(() => _assignee = value),
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.person_outline, color: AppTheme.primaryColor),
                    ),
                  ),
            SizedBox(height: 32),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _save,
                child: _isSaving
                    ? SizedBox(
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
