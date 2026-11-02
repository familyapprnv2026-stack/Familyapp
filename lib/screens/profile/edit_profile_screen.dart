import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/firestore_service.dart';
import '../../theme/app_theme.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _nameController = TextEditingController();
  final _lastNamesController = TextEditingController();
  final _phoneController = TextEditingController();
  bool _loading = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _lastNamesController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final auth = context.read<AuthProvider>();
    final current = auth.user;
    final profile =
        current != null ? await FirestoreService.getUserProfile(current.uid) : null;
    if (!mounted) return;
    setState(() {
      _nameController.text = profile?['name']?.toString() ?? '';
      _lastNamesController.text = profile?['lastNames']?.toString() ?? '';
      _phoneController.text = profile?['phone']?.toString() ?? '';
      _loading = false;
    });
  }

  Future<void> _save() async {
    final auth = context.read<AuthProvider>();
    final current = auth.user;
    if (current == null) return;
    setState(() => _saving = true);
    await FirestoreService.updateUserProfile(current.uid, {
      'name': _nameController.text.trim(),
      'lastNames': _lastNamesController.text.trim(),
      'phone': _phoneController.text.trim(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
    if (!mounted) return;
    setState(() => _saving = false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Perfil actualizado')),
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Editar Perfil')),
      body: _loading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.2),
                    child: Icon(Icons.camera_alt, color: AppTheme.primaryColor, size: 32),
                  ),
                  SizedBox(height: 24),
                  TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      hintText: 'Nombre',
                      prefixIcon: Icon(Icons.person_outline, color: AppTheme.primaryColor),
                    ),
                  ),
                  SizedBox(height: 16),
                  TextFormField(
                    controller: _lastNamesController,
                    decoration: InputDecoration(
                      hintText: 'Apellidos',
                      prefixIcon: Icon(Icons.person_outline, color: AppTheme.primaryColor),
                    ),
                  ),
                  SizedBox(height: 16),
                  TextFormField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      hintText: 'Teléfono',
                      prefixIcon: Icon(Icons.phone_outlined, color: AppTheme.primaryColor),
                    ),
                  ),
                  SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _saving ? null : _save,
                      child: _saving
                          ? SizedBox(
                              height: 24,
                              width: 24,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                            )
                          : Text('Guardar Cambios'),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
