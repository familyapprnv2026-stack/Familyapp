import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class EditProfileScreen extends StatelessWidget {
  const EditProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Editar Perfil')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            CircleAvatar(
              radius: 40,
              backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.2),
              child: const Icon(Icons.camera_alt, color: AppTheme.primaryColor, size: 32),
            ),
            const SizedBox(height: 24),
            TextFormField(decoration: const InputDecoration(hintText: 'Nombre', prefixIcon: Icon(Icons.person_outline))),
            const SizedBox(height: 16),
            TextFormField(decoration: const InputDecoration(hintText: 'Apellidos', prefixIcon: Icon(Icons.person_outline))),
            const SizedBox(height: 16),
            TextFormField(decoration: const InputDecoration(hintText: 'Teléfono', prefixIcon: Icon(Icons.phone_outlined))),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(onPressed: () {}, child: const Text('Guardar Cambios')),
            ),
          ],
        ),
      ),
    );
  }
}
