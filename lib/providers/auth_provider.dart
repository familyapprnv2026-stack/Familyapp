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

  bool get isLoading => _isLoading;
  String? get error => _error;
  User? get user => _auth.currentUser;
  String? get familyId => _familyId;

  bool get isSignedIn {
    try {
      return _auth.currentUser != null;
    } catch (_) {
      return false;
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

  Future<bool> signIn(String email, String password) async {
    _setLoading(true);
    try {
      await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
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
  }) async {
    _setLoading(true);
    try {
      final cred = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final uid = cred.user!.uid;
      final familyId = await FirestoreService.createFamily(
        ownerId: uid,
        ownerName: '$name $lastNames',
      );
      await FirestoreService.createUserProfile(
        uid,
        name: name,
        lastNames: lastNames,
        phone: phone,
        email: email.trim(),
        familyId: familyId,
      );
      _familyId = familyId;
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
