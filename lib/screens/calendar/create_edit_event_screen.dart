import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class CreateEditEventScreen extends StatelessWidget {
  final bool isEdit;
  const CreateEditEventScreen({super.key, this.isEdit = false});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(isEdit ? 'Editar Evento' : 'Crear Evento')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            TextFormField(decoration: const InputDecoration(hintText: 'Título del evento')),
            const SizedBox(height: 16),
            Container(height: 50, color: Colors.white, child: const Center(child: Text('Seleccionar Fecha y Hora', style: TextStyle(color: AppTheme.textHint)))),
            const SizedBox(height: 16),
            TextFormField(decoration: const InputDecoration(hintText: 'Ubicación (Opcional)')),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(onPressed: () {}, child: Text(isEdit ? 'Guardar Cambios' : 'Crear Evento')),
            ),
          ],
        ),
      ),
    );
  }
}
