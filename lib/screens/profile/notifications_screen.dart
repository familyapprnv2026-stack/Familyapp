import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  static const _items = <NotificationItem>[
    NotificationItem(Icons.event, 'Evento familiar', 'Reunión familiar este sábado a las 18:00', 'Hoy'),
    NotificationItem(Icons.task_alt, 'Tarea por vencer', 'Recuerda terminar la tarea "Limpiar la sala"', 'Mañana'),
    NotificationItem(Icons.check_circle, 'Tarea completada', 'María completó "Hacer la compra"', 'Hace 2 h'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Notificaciones')),
      body: _items.isEmpty
          ? Center(child: Text('No tienes notificaciones'))
          : ListView.separated(
              padding: const EdgeInsets.all(16.0),
              itemCount: _items.length,
              separatorBuilder: (_, _) => SizedBox(height: 8),
              itemBuilder: (context, index) {
                final item = _items[index];
                return Card(
                  elevation: 0,
                  color: Theme.of(context).colorScheme.surface,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(item.icon, color: AppTheme.primaryColor),
                    ),
                    title: Text(item.title, style: TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(item.subtitle),
                    trailing: Text(
                      item.time,
                      style: TextStyle(color: context.textHint, fontSize: 12),
                    ),
                  ),
                );
              },
            ),
    );
  }
}

class NotificationItem {
  final IconData icon;
  final String title;
  final String subtitle;
  final String time;
  const NotificationItem(this.icon, this.title, this.subtitle, this.time);
}
