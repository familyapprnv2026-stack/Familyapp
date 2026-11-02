import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../theme/app_theme.dart';

class VerifyEmailScreen extends StatefulWidget {
  const VerifyEmailScreen({super.key});

  @override
  State<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen> {
  bool _sending = false;

  Future<void> _resend() async {
    final auth = context.read<AuthProvider>();
    setState(() => _sending = true);
    final ok = await auth.sendVerificationEmail();
    if (!mounted) return;
    setState(() => _sending = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(ok ? 'Correo de verificación enviado' : (auth.error ?? 'No se pudo enviar el correo'))),
    );
  }

  Future<void> _checkVerified() async {
    final auth = context.read<AuthProvider>();
    setState(() => _sending = true);
    await auth.reloadUser();
    if (!mounted) return;
    setState(() => _sending = false);
    if (auth.isEmailVerified) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('¡Cuenta verificada!')),
      );
      context.go('/home');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Aún no está verificada. Revisa tu correo e inténtalo de nuevo')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final email = auth.user?.email ?? auth.pendingEmail ?? '';
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) => SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Icon(Icons.mark_email_read_outlined,
                        color: AppTheme.primaryColor, size: 72),
                    SizedBox(height: 24),
                    Text(
                      'Verifica tu correo',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 12),
                    Text(
                      'Te enviamos un correo de verificación a $email\nRevisa tu bandeja de entrada (o spam) y haz clic en el enlace para activar tu cuenta.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: context.textSecondary, height: 1.5),
                    ),
                    SizedBox(height: 32),
                    ElevatedButton(
                      onPressed: _sending ? null : _checkVerified,
                      child: _sending
                          ? SizedBox(
                              height: 24,
                              width: 24,
                              child: CircularProgressIndicator(
                                  color: Colors.white, strokeWidth: 2))
                          : FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text('Ya verifiqué mi correo'),
                            ),
                    ),
                    SizedBox(height: 16),
                    TextButton(
                      onPressed: _sending ? null : _resend,
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text('Reenviar correo de verificación',
                            style: TextStyle(color: AppTheme.primaryColor)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
