import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';
import '../../services/firestore_service.dart';
import '../../theme/app_theme.dart';
import '../../utils/formatters.dart';
import '../../widgets/initials_avatar.dart';

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

  Future<void> _copyFamilyCode(String code) async {
    if (code.isEmpty) return;
    await Clipboard.setData(ClipboardData(text: code));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('¡Código de invitación copiado al portapapeles!')),
    );
  }

  Future<void> _openJoinFamily() async {
    final controller = TextEditingController();
    final code = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('Unirse a una familia'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: InputDecoration(
            hintText: 'Ingresa el código de la familia',
            prefixIcon: Icon(Icons.group_add_outlined, color: AppTheme.primaryColor),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, controller.text.trim()),
            child: Text('Unirse'),
          ),
        ],
      ),
    );
    Future.delayed(const Duration(milliseconds: 300), () => controller.dispose());
    
    if (code == null || code.isEmpty || !mounted) return;
    final auth = context.read<AuthProvider>();
    final ok = await auth.joinFamilyWithCode(code);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(ok ? '¡Te uniste a la familia!' : (auth.error ?? 'No se pudo unir a la familia')),
      ),
    );
    if (ok) _load();
  }

  @override
  Widget build(BuildContext context) {
    final name = _profile?['name']?.toString() ?? '';
    final lastNames = _profile?['lastNames']?.toString() ?? '';
    final email = _profile?['email']?.toString() ?? '';
    final role = _profile?['role']?.toString() ?? 'member';
    final familyId = _profile?['familyId']?.toString() ?? '';
    final fullName = '$name $lastNames'.trim();
    final initials = AppFormats.initials(name, lastNames);
    final roleLabel = _roleLabel(role);

    return Scaffold(
      backgroundColor: AppTheme.primaryColor,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Perfil de Usuario',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  InitialsAvatar(
                    initials: initials,
                    size: 80,
                    color: Colors.white.withValues(alpha: 0.2),
                  ),
                  SizedBox(height: 16),
                  Text(
                    fullName.isEmpty ? 'Cargando...' : fullName,
                    style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 4),
                  Text(
                    email.isEmpty ? ' ' : email,
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                  SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(roleLabel, style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),

            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: context.background,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(32),
                    topRight: Radius.circular(32),
                  ),
                ),
                child: ListView(
                  padding: const EdgeInsets.all(24.0),
                  children: [
                    _buildMenuOption(context, 'Copiar código de invitación', Icons.content_copy_outlined, () => _copyFamilyCode(familyId)),
                    _buildMenuOption(context, 'Miembros de la Familia', Icons.group_outlined, () => context.push('/members')),
                    _buildMenuOption(context, 'Unirse a una Familia', Icons.group_add_outlined, _openJoinFamily),
                    _buildMenuOption(context, 'Editar Perfil', Icons.person_outline, _openEditProfile),
                    _buildMenuOption(context, 'Configuración', Icons.settings_outlined, () => context.push('/settings')),
                    _buildMenuOption(context, 'Notificaciones', Icons.notifications_none, () => context.push('/notifications')),
                    Divider(height: 32),
                    _buildMenuOption(context, 'Ayuda y Soporte', Icons.help_outline, () => context.push('/help')),
                    _buildMenuOption(context, 'Términos y Condiciones', Icons.description_outlined, () => context.push('/terms')),
                    _buildMenuOption(context, 'Política de Privacidad', Icons.privacy_tip_outlined, () => context.push('/privacy')),
                    _buildMenuOption(context, 'Acerca de FamilyApp', Icons.info_outline, () => context.push('/about')),
                    Divider(height: 32),
                    ListTile(
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        clipBehavior: Clip.antiAlias,
                        decoration: BoxDecoration(color: Colors.red.withValues(alpha: 0.1), shape: BoxShape.circle),
                        child: Icon(Icons.logout, color: Colors.red),
                      ),
                      title: Text('Cerrar Sesión', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
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

  String _roleLabel(String role) {
    switch (role) {
      case 'owner':
      case 'admin':
        return 'Administrador';
      case 'member':
        return 'Miembro';
      default:
        return role.isEmpty ? 'Miembro' : role;
    }
  }

  Widget _buildMenuOption(
    BuildContext context,
    String title,
    IconData icon,
    VoidCallback onTap,
  ) {    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(color: AppTheme.primaryColor.withValues(alpha: 0.1), shape: BoxShape.circle),
        child: Icon(icon, color: AppTheme.primaryColor),
      ),
      title: Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
      trailing: Icon(Icons.chevron_right, color: context.textHint),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 0, vertical: 4),
    );
  }
}
