import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/theme_provider.dart';
import '../../theme/app_theme.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _appNotifications = true;
  bool _taskReminders = true;
  bool _emailNotifications = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Configuración')),
      body: ListView(
        padding: const EdgeInsets.all(24.0),
        children: [
          _sectionTitle('Apariencia'),
          Consumer<ThemeProvider>(
            builder: (context, theme, _) {
              return SwitchListTile(
                contentPadding: EdgeInsets.zero,
                activeTrackColor: AppTheme.primaryColor,
                title: Text('Modo oscuro'),
                subtitle: Text('Activar tema oscuro'),
                value: theme.isDark,
                onChanged: (v) => theme.setDark(v),
              );
            },
          ),
          Divider(height: 32),
          _sectionTitle('Notificaciones'),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            activeTrackColor: AppTheme.primaryColor,
            title: Text('Notificaciones de la app'),
            subtitle: Text('Recibir avisos dentro de la aplicación'),
            value: _appNotifications,
            onChanged: (v) => setState(() => _appNotifications = v),
          ),
          Divider(height: 32),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            activeTrackColor: AppTheme.primaryColor,
            title: Text('Recordatorios de tareas'),
            subtitle: Text('Avisar antes de la fecha de vencimiento'),
            value: _taskReminders,
            onChanged: (v) => setState(() => _taskReminders = v),
          ),
          Divider(height: 32),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            activeTrackColor: AppTheme.primaryColor,
            title: Text('Notificaciones por correo'),
            subtitle: Text('Enviar resúmenes por correo electrónico'),
            value: _emailNotifications,
            onChanged: (v) => setState(() => _emailNotifications = v),
          ),
          SizedBox(height: 24),
          _sectionTitle('Idioma'),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(Icons.language, color: AppTheme.primaryColor),
            title: Text('Idioma de la aplicación'),
            subtitle: Text('Español'),
            trailing: Icon(Icons.chevron_right, color: context.textHint),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Solo está disponible el idioma español por ahora')),
              );
            },
          ),
          Divider(height: 32),
          _sectionTitle('Datos'),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(Icons.storage_outlined, color: AppTheme.primaryColor),
            title: Text('Uso de datos'),
            subtitle: Text('Descargar contenido solo con Wi-Fi (próximamente)'),
            trailing: Icon(Icons.chevron_right, color: context.textHint),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: TextStyle(
          color: AppTheme.primaryColor,
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
