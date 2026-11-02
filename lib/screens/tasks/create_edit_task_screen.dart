import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class CreateEditTaskScreen extends StatelessWidget {
  final bool isEdit;
  const CreateEditTaskScreen({super.key, this.isEdit = false});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(isEdit ? 'Editar Tarea' : 'Crear Tarea')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            TextFormField(decoration: const InputDecoration(hintText: 'Título de la tarea')),
            const SizedBox(height: 16),
            TextFormField(decoration: const InputDecoration(hintText: 'Descripción (Opcional)')),
            const SizedBox(height: 16),
            // Placeholder for Date, Assignee, Priority, Category dropdowns
            Container(height: 50, color: Colors.white, child: const Center(child: Text('Seleccionar Fecha', style: TextStyle(color: AppTheme.textHint)))),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(onPressed: () {}, child: Text(isEdit ? 'Guardar Cambios' : 'Crear Tarea')),
            ),
          ],
        ),
      ),
    );
  }
}
