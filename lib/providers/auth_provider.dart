import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../services/firestore_service.dart';

class AuthProvider extends ChangeNotifier {
  FirebaseAuth get _auth => FirebaseAuth.instance;
  StreamSubscription<User?>? _sub;
  String? _familyId;
  bool _isLoading = false;
  String? _error;
  String? _pendingEmail;

  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get pendingEmail => _pendingEmail;
  User? get user => _auth.currentUser;
  String? get familyId => _familyId;

  bool get isSignedIn {
    try {
      return _auth.currentUser != null;
    } catch (_) {
      return false;
    }
  }

  bool get isEmailVerified {
    final u = _auth.currentUser;
    return u != null && u.emailVerified;
  }

  Future<bool> sendVerificationEmail() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return false;
      await user.sendEmailVerification();
      return true;
    } catch (e) {
      _error = _friendlyError(e);
      return false;
    }
  }

  Future<void> reloadUser() async {
    final user = _auth.currentUser;
    if (user != null) {
      await user.reload();
      notifyListeners();
    }
  }

  void start() {
    _sub ??= _auth.authStateChanges().listen((_) {
      notifyListeners();
    });
  }

  Future<void> signOut() async {
    await _auth.signOut();
    _familyId = null;
    notifyListeners();
  }

  /// Forzar recarga del token para obtener el estado de verificación actualizado
  Future<bool> signIn(String email, String password) async {
    _setLoading(true);
    try {
      await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final user = _auth.currentUser;
      if (user != null) {
        await user.reload();
      }
      if (!isEmailVerified) {
        _pendingEmail = user?.email;
        _error = 'Debes verificar tu correo electrónico antes de iniciar sesión. Revisa tu bandeja de entrada.';
        return false;
      }
      _pendingEmail = null;
      await _loadFamilyId();
      return true;
    } catch (e) {
      _error = _friendlyError(e);
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> register({
    required String name,
    required String lastNames,
    required String phone,
    required String email,
    required String password,
    String? familyCode,
  }) async {
    _setLoading(true);
    try {
      final cred = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final uid = cred.user!.uid;
      final code = familyCode?.trim() ?? '';
      final String familyId;
      final String role;
      if (code.isNotEmpty && await FirestoreService.familyExists(code)) {
        familyId = code;
        role = 'member';
      } else if (code.isNotEmpty) {
        _error = 'El código de familia no existe. Verifica e intenta de nuevo.';
        return false;
      } else {
        familyId = await FirestoreService.createFamily(
          ownerId: uid,
          ownerName: '$name $lastNames',
        );
        role = 'owner';
      }
      await FirestoreService.createUserProfile(
        uid,
        name: name,
        lastNames: lastNames,
        phone: phone,
        email: email.trim(),
        familyId: familyId,
        role: role,
      );
      _familyId = familyId;
      _pendingEmail = email.trim();
      cred.user!.sendEmailVerification();
      return true;
    } catch (e) {
      _error = _friendlyError(e);
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Une la cuenta actual a una familia existente mediante su código (familyId).
  Future<bool> joinFamilyWithCode(String familyCode) async {
    _setLoading(true);
    try {
      final current = _auth.currentUser;
      if (current == null) return false;
      final code = familyCode.trim();
      if (!await FirestoreService.familyExists(code)) {
        _error = 'El código de familia no existe. Verifica e intenta de nuevo.';
        return false;
      }
      final profile =
          await FirestoreService.getUserProfile(current.uid) ?? <String, dynamic>{};
      await FirestoreService.joinFamily(current.uid, code, {
        ...profile,
        'name': profile['name'] ?? '',
        'lastNames': profile['lastNames'] ?? '',
        'phone': profile['phone'] ?? '',
        'email': profile['email'] ?? current.email ?? '',
        'role': 'member',
      });
      _familyId = code;
      return true;
    } catch (e) {
      _error = _friendlyError(e);
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> recoverPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
      return true;
    } catch (e) {
      _error = _friendlyError(e);
      return false;
    }
  }

  Future<String?> familyIdForUser() async {
    if (_familyId != null) return _familyId;
    final current = _auth.currentUser;
    if (current == null) return null;
    final profile = await FirestoreService.getUserProfile(current.uid);
    _familyId = profile?['familyId'];
    return _familyId;
  }

  Future<void> _loadFamilyId() async {
    final current = _auth.currentUser;
    if (current == null) return;
    final profile = await FirestoreService.getUserProfile(current.uid);
    _familyId = profile?['familyId'];
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  String _friendlyError(Object error) {
    if (error is FirebaseAuthException) {
      switch (error.code) {
        case 'email-already-in-use':
          return 'Este correo ya está registrado.';
        case 'invalid-email':
          return 'Ingresa un correo electrónico válido.';
        case 'weak-password':
          return 'La contraseña debe tener al menos 6 caracteres.';
        case 'user-not-found':
        case 'wrong-password':
        case 'invalid-credential':
          return 'Correo o contraseña incorrectos.';
        case 'user-disabled':
          return 'Esta cuenta ha sido deshabilitada.';
        case 'too-many-requests':
          return 'Demasiados intentos. Espera un momento e intenta de nuevo.';
        case 'network-request-failed':
          return 'Sin conexión a internet. Verifica tu red.';
      }
    }
    return 'Ha ocurrido un error. Intenta de nuevo.';
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}
