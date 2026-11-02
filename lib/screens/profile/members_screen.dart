import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/firestore_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/initials_avatar.dart';

class MembersScreen extends StatefulWidget {
  const MembersScreen({super.key});

  @override
  State<MembersScreen> createState() => _MembersScreenState();
}

class _MembersScreenState extends State<MembersScreen> {
  static const _roleOptions = [
    'Mamá',
    'Papá',
    'Hermano',
    'Hermana',
    'Hijo',
    'Hija',
    'Miembro',
  ];

  List<Map<String, dynamic>> _members = [];
  String? _familyId;
  bool _loading = true;
  bool _isAdmin = false;

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
    final familyId = profile?['familyId'];
    final myRole = profile?['role']?.toString();
    final isAdmin = myRole == 'owner' || myRole == 'admin';
    if (familyId == null) {
      if (mounted) {
        setState(() => _loading = false);
      }
      return;
    }
    if (current != null) {
      await FirestoreService.syncUserToFamilyMembers(current.uid);
    }
    final members = await FirestoreService.getFamilyMembers(familyId);
    if (!mounted) return;
    setState(() {
      _members = members;
      _isAdmin = isAdmin;
      _familyId = familyId;
      _loading = false;
    });
  }

  Future<void> _changeRole(String uid, String newRole) async {
    await FirestoreService.updateUserProfile(uid, {'role': newRole});
    if (!mounted) return;
    setState(() {
      _members = _members
          .map((m) => m['uid'] == uid ? {...m, 'role': newRole} : m)
          .toList();
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Rol actualizado a $newRole')),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Miembros de la Familia')),
      body: _loading
          ? Center(child: CircularProgressIndicator())
          : CustomScrollView(
              slivers: [
                if (_familyId != null)
                  SliverToBoxAdapter(child: _buildFamilyCodeCard()),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                  sliver: _members.isEmpty
                      ? SliverFillRemaining(
                          hasScrollBody: false,
                          child: Center(
                            child: Text('Aún no hay miembros en tu familia',
                                style: TextStyle(color: context.textSecondary)),
                          ),
                        )
                      : SliverList.separated(
                          itemCount: _members.length,
                          separatorBuilder: (_, _) =>
                              const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final m = _members[index];
                            final name =
                                '${m['name'] ?? ''} ${m['lastNames'] ?? ''}'
                                    .trim();
                            final role = m['role']?.toString() ?? 'member';
                            final initials = _initials(
                                m['name']?.toString() ?? '',
                                m['lastNames']?.toString() ?? '');
                            final color = _roleColor(role);
                            return Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.surface,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Row(
                                children: [
                                  InitialsAvatar(
                                    initials: initials,
                                    size: 44,
                                    color: color.withValues(alpha: 0.2),
                                    textColor: color,
                                  ),
                                  SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          name.isEmpty ? 'Miembro' : name,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold),
                                        ),
                                        SizedBox(height: 4),
                                        Text(
                                          _roleLabel(role),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            fontSize: 13,
                                            color: context.textSecondary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  if (_isAdmin && role != 'owner')
                                    DropdownButton<String>(
                                      value: _isAdminRole(role)
                                          ? 'Miembro'
                                          : role,
                                      underline: const SizedBox(),
                                      isDense: true,
                                      items: _roleOptions
                                          .map((r) => DropdownMenuItem(
                                              value: r, child: Text(r)))
                                          .toList(),
                                      onChanged: (value) {
                                        if (value != null) {
                                          _changeRole(
                                              m['uid'] as String, value);
                                        }
                                      },
                                    ),
                                ],
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }

  Widget _buildFamilyCodeCard() {
    final code = _familyId!;
    return Container(
      margin: const EdgeInsets.fromLTRB(24, 16, 24, 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(Icons.emoji_events_outlined, color: AppTheme.primaryColor),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Código de tu familia',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          SizedBox(height: 4),
          Text(
            'Compártelo para que otros se unan al registrarse',
            style: TextStyle(fontSize: 12, color: context.textSecondary),
          ),
          SizedBox(height: 12),
          Row(
            children: [
              Flexible(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    code,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 8),
              IconButton(
                icon: Icon(Icons.copy_outlined,
                    size: 20, color: AppTheme.primaryColor),
                tooltip: 'Copiar código',
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: code));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Código copiado')),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  bool _isAdminRole(String role) =>
      role == 'owner' || role == 'admin' || !_roleOptions.contains(role);

  String _initials(String name, String lastNames) {
    final first = name.isNotEmpty ? name.trim().substring(0, 1) : '';
    final second = lastNames.isNotEmpty ? lastNames.trim().substring(0, 1) : '';
    return (first + second).toUpperCase();
  }

  Color _roleColor(String role) {
    switch (role) {
      case 'owner':
      case 'admin':
        return AppTheme.primaryColor;
      case 'Mamá':
        return AppTheme.catMom;
      case 'Papá':
        return AppTheme.catDad;
      case 'Hermano':
      case 'Hijo':
        return AppTheme.catHome;
      case 'Hermana':
      case 'Hija':
        return AppTheme.catSofia;
      default:
        return AppTheme.primaryLight;
    }
  }
}
