import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class RecoverPasswordScreen extends StatelessWidget {
  const RecoverPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Recuperar contraseña')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Ingresa tu correo para recibir un enlace de recuperación.', style: TextStyle(color: AppTheme.textSecondary)),
            const SizedBox(height: 24),
            TextFormField(
              decoration: const InputDecoration(hintText: 'tu@correo.com', prefixIcon: Icon(Icons.email_outlined)),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(onPressed: () {}, child: const Text('Enviar enlace')),
            ),
          ],
        ),
      ),
    );
  }
}
