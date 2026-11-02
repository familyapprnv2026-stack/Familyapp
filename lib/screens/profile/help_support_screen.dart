import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  static const _faqs = [
    {'q': '¿Cómo agrego una tarea?', 'a': 'Ve a la pestaña "Tareas" y pulsa el botón con el símbolo "+" para crear una nueva tarea. Puedes asignar la categoría y la fecha límite.'},
    {'q': '¿Cómo creo un evento familiar?', 'a': 'Abre la pestaña "Calendario" y pulsa el símbolo "+". Completa los detalles del evento y guárdalo para que aparezca en el calendario compartido.'},
    {'q': '¿Puedo administrar las tareas de mis hijos?', 'a': 'Sí. Cada miembro de la familia puede ver las tareas compartidas. El administrador (dueño de la familia) puede gestionar la configuración general.'},
    {'q': '¿Cómo edito mi información personal?', 'a': 'Entra en "Perfil de Usuario" y toca "Editar Perfil" para actualizar tu nombre, apellidos y teléfono.'},
    {'q': '¿Qué hago si olvidé mi contraseña?', 'a': 'En la pantalla de inicio de sesión, toca "¿Olvidaste tu contraseña?" e ingresa tu correo para recibir instrucciones de recuperación.'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Ayuda y Soporte')),
      body: ListView(
        padding: const EdgeInsets.all(24.0),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Icon(Icons.support_agent, color: AppTheme.primaryColor),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    '¿Necesitas ayuda? Consulta las preguntas frecuentes o contáctanos por correo.',
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 24),
          Text(
            'Preguntas Frecuentes',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          for (final faq in _faqs)
            ExpansionTile(
              title: Text(faq['q']!, style: TextStyle(fontWeight: FontWeight.w600)),
              childrenPadding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
              children: [Text(faq['a']!, style: TextStyle(color: context.textSecondary))],
            ),
          SizedBox(height: 24),
          Divider(),
          SizedBox(height: 16),
          Text(
            'Contacto',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(Icons.email_outlined, color: AppTheme.primaryColor),
            title: Text('familyapprnv2026@gmail.com'),
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(Icons.chat_outlined, color: AppTheme.primaryColor),
            title: Text('Chat de ayuda en línea'),
            subtitle: Text('Disponible de lunes a viernes, 9:00 a 18:00'),
          ),
        ],
      ),
    );
  }
}
