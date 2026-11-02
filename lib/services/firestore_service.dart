import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/event.dart';
import '../models/task.dart';

class FirestoreService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  static Future<String> createFamily({
    required String ownerId,
    required String ownerName,
  }) async {
    final doc = _db.collection('families').doc();
    await doc.set({
      'ownerId': ownerId,
      'ownerName': ownerName,
      'name': 'Mi familia',
      'memberIds': [ownerId],
      'createdAt': FieldValue.serverTimestamp(),
    });
    return doc.id;
  }

  static Future<void> createUserProfile(
    String uid, {
    required String name,
    required String lastNames,
    required String phone,
    required String email,
    required String familyId,
    String role = 'member',
  }) async {
    final data = <String, dynamic>{
      'name': name,
      'lastNames': lastNames,
      'phone': phone,
      'email': email,
      'familyId': familyId,
      'role': role,
      'createdAt': FieldValue.serverTimestamp(),
    };
    await _db.collection('users').doc(uid).set(data);
    await _db
        .collection('families')
        .doc(familyId)
        .collection('members')
        .doc(uid)
        .set(data);
    await _db.collection('families').doc(familyId).update({
      'memberIds': FieldValue.arrayUnion([uid]),
    });
  }

  static Future<bool> familyExists(String familyId) async {
    final doc = await _db.collection('families').doc(familyId).get();
    return doc.exists;
  }

  /// Agrega un usuario existente a una familia por su código (familyId).
  static Future<void> joinFamily(
    String uid,
    String familyId,
    Map<String, dynamic> data,
  ) async {
    await _db
        .collection('users')
        .doc(uid)
        .set({...data, 'familyId': familyId}, SetOptions(merge: true));
    await _db
        .collection('families')
        .doc(familyId)
        .collection('members')
        .doc(uid)
        .set({...data, 'familyId': familyId}, SetOptions(merge: true));
    await _db.collection('families').doc(familyId).update({
      'memberIds': FieldValue.arrayUnion([uid]),
    });
  }

  static Future<Map<String, dynamic>?> getUserProfile(String uid) async {
    final snap = await _db.collection('users').doc(uid).get();
    return snap.data();
  }

  static Future<void> updateUserProfile(
    String uid,
    Map<String, dynamic> data,
  ) async {
    await _db.collection('users').doc(uid).update(data);
    final profile = await _db.collection('users').doc(uid).get();
    final familyId = (profile.data()?['familyId'] ?? data['familyId'])
        as String?;
    if (familyId != null) {
      await _db
          .collection('families')
          .doc(familyId)
          .collection('members')
          .doc(uid)
          .set({...data, 'familyId': familyId}, SetOptions(merge: true));
    }
  }

  static Future<Map<String, dynamic>?> getFamily(String familyId) async {
    final snap = await _db.collection('families').doc(familyId).get();
    return snap.data();
  }

  static Future<List<Map<String, dynamic>>> getFamilyMembers(
    String familyId,
  ) async {
    final snap = await _db
        .collection('families')
        .doc(familyId)
        .collection('members')
        .orderBy('name')
        .get();
    return snap.docs
        .map((doc) => {'uid': doc.id, ...doc.data()})
        .toList();
  }

  /// Sincroniza el perfil del usuario a la subcolección de su familia
  /// (por retrocompatibilidad con cuentas creadas antes de la subcolección).
  static Future<void> syncUserToFamilyMembers(String uid) async {
    final userDoc = await _db.collection('users').doc(uid).get();
    final data = userDoc.data();
    final familyId = data?['familyId'];
    if (data == null || familyId == null) return;
    await _db
        .collection('families')
        .doc(familyId)
        .collection('members')
        .doc(uid)
        .set(data, SetOptions(merge: true));
  }

  static Future<List<Task>> getTasks(String familyId) async {
    final snap = await _db
        .collection('families')
        .doc(familyId)
        .collection('tasks')
        .orderBy('date')
        .get();
    return snap.docs
        .map((doc) => Task.fromMap(doc.id, doc.data()))
        .toList();
  }

  static Future<void> createTask(
    String familyId,
    Map<String, dynamic> data,
  ) async {
    await _db
        .collection('families')
        .doc(familyId)
        .collection('tasks')
        .add(data);
  }

  static Future<void> updateTask(
    String familyId,
    String taskId,
    Map<String, dynamic> data,
  ) async {
    await _db
        .collection('families')
        .doc(familyId)
        .collection('tasks')
        .doc(taskId)
        .update(data);
  }

  static Future<void> deleteTask(
    String familyId,
    String taskId,
  ) async {
    await _db
        .collection('families')
        .doc(familyId)
        .collection('tasks')
        .doc(taskId)
        .delete();
  }

  static Future<List<FamilyEvent>> getEvents(String familyId) async {
    final snap = await _db
        .collection('families')
        .doc(familyId)
        .collection('events')
        .orderBy('date')
        .get();
    return snap.docs
        .map((doc) => FamilyEvent.fromMap(doc.id, doc.data()))
        .toList();
  }

  static Future<void> createEvent(
    String familyId,
    Map<String, dynamic> data,
  ) async {
    await _db
        .collection('families')
        .doc(familyId)
        .collection('events')
        .add(data);
  }

  static Future<void> updateEvent(
    String familyId,
    String eventId,
    Map<String, dynamic> data,
  ) async {
    await _db
        .collection('families')
        .doc(familyId)
        .collection('events')
        .doc(eventId)
        .update(data);
  }

  static Future<void> deleteEvent(
    String familyId,
    String eventId,
  ) async {
    await _db
        .collection('families')
        .doc(familyId)
        .collection('events')
        .doc(eventId)
        .delete();
  }

  static Stream<QuerySnapshot<Map<String, dynamic>>> getChatMessages(String familyId) {
    return _db
        .collection('families')
        .doc(familyId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  static Future<void> sendMessage(
    String familyId,
    String text,
    String senderId,
    String senderName,
  ) async {
    await _db
        .collection('families')
        .doc(familyId)
        .collection('messages')
        .add({
      'text': text,
      'senderId': senderId,
      'senderName': senderName,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  /// Guarda un reporte de un mensaje inapropiado (requisito de Google Play
  /// para contenido generado por usuarios).
  static Future<void> reportMessage({
    required String familyId,
    required String messageId,
    required Map<String, dynamic> message,
    required String reportedBy,
    required String reason,
  }) async {
    await _db
        .collection('families')
        .doc(familyId)
        .collection('reports')
        .add({
      'messageId': messageId,
      'messageText': message['text'],
      'messageSenderId': message['senderId'],
      'messageSenderName': message['senderName'],
      'reportedBy': reportedBy,
      'reason': reason,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  /// Bloquea a un usuario: sus mensajes dejarán de mostrarse para el usuario actual.
  static Future<void> blockUser(String uid, String blockedUid) async {
    await _db.collection('users').doc(uid).update({
      'blockedUsers': FieldValue.arrayUnion([blockedUid]),
    });
  }

  /// Desbloquea a un usuario.
  static Future<void> unblockUser(String uid, String blockedUid) async {
    await _db.collection('users').doc(uid).update({
      'blockedUsers': FieldValue.arrayRemove([blockedUid]),
    });
  }
}
