import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/firestore_service.dart';
import '../../theme/app_theme.dart';
import '../../utils/formatters.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic>? _profile;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final auth = context.read<AuthProvider>();
    final current = auth.user;
    final profile =
        current != null ? await FirestoreService.getUserProfile(current.uid) : null;
    if (!mounted) return;
    setState(() {
      _profile = profile;
    });
  }

  Future<void> _openEditProfile() async {
    await context.push('/edit-profile');
    if (mounted) _load();
  }

  Future<void> _signOut() async {
    final auth = context.read<AuthProvider>();
    await auth.signOut();
    if (mounted) context.go('/login');
  }

  @override
  Widget build(BuildContext context) {
    final name = _profile?['name']?.toString() ?? '';
    final lastNames = _profile?['lastNames']?.toString() ?? '';
    final email = _profile?['email']?.toString() ?? '';
    final role = _profile?['role']?.toString() ?? 'member';
    final fullName = '$name $lastNames'.trim();
    final initials = AppFormats.initials(name, lastNames);
    final roleLabel = role == 'owner' ? 'Administrador' : 'Miembro';

    return Scaffold(
      backgroundColor: AppTheme.primaryColor,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              child: Row(
                children: [
                  Text('Perfil de Usuario', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.white.withValues(alpha: 0.2),
                    child: Text(
                      initials.isEmpty ? 'F' : initials,
                      style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    fullName.isEmpty ? 'Cargando...' : fullName,
                    style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    email.isEmpty ? ' ' : email,
                    style: const TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(roleLabel, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),

            Expanded(
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: AppTheme.backgroundColor,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(32),
                    topRight: Radius.circular(32),
                  ),
                ),
                child: ListView(
                  padding: const EdgeInsets.all(24.0),
                  children: [
                    _buildMenuOption(context, 'Editar Perfil', Icons.person_outline, _openEditProfile),
                    _buildMenuOption(context, 'Configuración', Icons.settings_outlined, () => context.push('/settings')),
                    _buildMenuOption(context, 'Notificaciones', Icons.notifications_none, () => context.push('/notifications')),
                    const Divider(height: 32),
                    _buildMenuOption(context, 'Ayuda y Soporte', Icons.help_outline, () => context.push('/help')),
                    _buildMenuOption(context, 'Términos y Condiciones', Icons.description_outlined, () => context.push('/terms')),
                    _buildMenuOption(context, 'Política de Privacidad', Icons.privacy_tip_outlined, () => context.push('/privacy')),
                    _buildMenuOption(context, 'Acerca de FamilyApp', Icons.info_outline, () => context.push('/about')),
                    const Divider(height: 32),
                    ListTile(
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(color: Colors.red.withValues(alpha: 0.1), shape: BoxShape.circle),
                        child: const Icon(Icons.logout, color: Colors.red),
                      ),
                      title: const Text('Cerrar Sesión', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                      onTap: _signOut,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuOption(
    BuildContext context,
    String title,
    IconData icon,
    VoidCallback onTap,
  ) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: AppTheme.primaryColor.withValues(alpha: 0.1), shape: BoxShape.circle),
        child: Icon(icon, color: AppTheme.primaryColor),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      trailing: const Icon(Icons.chevron_right, color: AppTheme.textHint),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 0, vertical: 4),
    );
  }
}
