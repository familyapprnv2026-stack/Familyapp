import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/event.dart';
import '../../providers/auth_provider.dart';
import '../../services/firestore_service.dart';
import '../../theme/app_theme.dart';
import '../../utils/formatters.dart';

class CreateEditEventScreen extends StatefulWidget {
  final FamilyEvent? event;

  const CreateEditEventScreen({super.key, this.event});

  @override
  State<CreateEditEventScreen> createState() => _CreateEditEventScreenState();
}

class _CreateEditEventScreenState extends State<CreateEditEventScreen> {
  late final TextEditingController _titleController;
  late final TextEditingController _locationController;
  DateTime _date = DateTime.now();
  TimeOfDay _time = TimeOfDay.now();
  bool _isSaving = false;

  bool get _isEdit => widget.event != null;

  @override
  void initState() {
    super.initState();
    final event = widget.event;
    _titleController = TextEditingController(text: event?.title ?? '');
    _locationController = TextEditingController(text: event?.location ?? '');
    if (event != null) {
      _date = event.date;
      _time = TimeOfDay.fromDateTime(event.date);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 5),
    );
    if (picked != null) {
      setState(() => _date = picked);
    }
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _time,
    );
    if (picked != null) {
      setState(() => _time = picked);
    }
  }

  Future<void> _save() async {
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Escribe un título para el evento')),
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
    final date = DateTime(_date.year, _date.month, _date.day, _time.hour, _time.minute);
    final data = <String, dynamic>{
      'title': _titleController.text.trim(),
      'date': date,
      'location': _locationController.text.trim(),
    };
    if (_isEdit) {
      await FirestoreService.updateEvent(familyId, widget.event!.id, {
        ...data,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } else {
      await FirestoreService.createEvent(familyId, {
        ...data,
        'createdBy': auth.user?.uid,
        'createdAt': FieldValue.serverTimestamp(),
      });
    }
    if (!mounted) return;
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_isEdit ? 'Editar Evento' : 'Crear Evento')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Título', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                hintText: 'Título del evento',
                prefixIcon: Icon(Icons.event, color: AppTheme.primaryColor),
              ),
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
                      AppFormats.shortDate(_date),
                      style: const TextStyle(color: AppTheme.textPrimary, fontSize: 14),
                    ),
                    const Spacer(),
                    const Icon(Icons.chevron_right, color: AppTheme.textHint),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            const Text('Hora', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            InkWell(
              onTap: _pickTime,
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.access_time, color: AppTheme.primaryColor, size: 20),
                    const SizedBox(width: 12),
                    Text(
                      _time.format(context),
                      style: const TextStyle(color: AppTheme.textPrimary, fontSize: 14),
                    ),
                    const Spacer(),
                    const Icon(Icons.chevron_right, color: AppTheme.textHint),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            const Text('Ubicación (Opcional)', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextFormField(
              controller: _locationController,
              decoration: const InputDecoration(
                hintText: 'Ubicación (Opcional)',
                prefixIcon: Icon(Icons.place_outlined, color: AppTheme.primaryColor),
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
                    : Text(_isEdit ? 'Guardar Cambios' : 'Crear Evento'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
