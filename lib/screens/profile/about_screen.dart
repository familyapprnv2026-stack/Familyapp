import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Acerca de FamilyApp')),
      body: ListView(
        padding: const EdgeInsets.all(24.0),
        children: [
          SizedBox(height: 16),
          Center(
            child: Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                color: AppTheme.primaryColor,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Icon(Icons.family_restroom, color: Colors.white, size: 48),
            ),
          ),
          SizedBox(height: 16),
          Center(
            child: Text(
              'FamilyApp',
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            ),
          ),
          SizedBox(height: 4),
          Center(
            child: Text(
              'Organiza tu vida familiar',
              style: TextStyle(color: context.textSecondary),
            ),
          ),
          SizedBox(height: 24),
          Divider(),
          SizedBox(height: 8),
          Text(
            'FamilyApp es una aplicación diseñada para ayudar a las familias a organizar sus tareas del hogar, eventos y actividades diarias de forma colaborativa. Comparte el calendario, asigna responsabilidades y mantén a todos los miembros al día.',
            style: TextStyle(fontSize: 14, height: 1.5, color: context.textSecondary),
          ),
          SizedBox(height: 24),
          Divider(),
          SizedBox(height: 8),
          const _InfoRow(label: 'Versión', value: '1.0.0'),
          const _InfoRow(label: 'Desarrollador', value: 'Camilo Ruiz Gordon'),
          const _InfoRow(label: 'Idiomas', value: 'Español'),
          const _InfoRow(label: 'Compatibilidad', value: 'Android, Web y Windows'),
          SizedBox(height: 8),
          Divider(),
          SizedBox(height: 16),
          Center(
            child: Text(
              '© 2026 FamilyApp. Todos los derechos reservados.',
              style: TextStyle(color: context.textHint, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: context.textSecondary),
            ),
          ),
          SizedBox(width: 12),
          Flexible(
            child: Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.end,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
