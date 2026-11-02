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
  }) async {
    await _db.collection('users').doc(uid).set({
      'name': name,
      'lastNames': lastNames,
      'phone': phone,
      'email': email,
      'familyId': familyId,
      'role': 'member',
      'createdAt': FieldValue.serverTimestamp(),
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
  }

  static Future<Map<String, dynamic>?> getFamily(String familyId) async {
    final snap = await _db.collection('families').doc(familyId).get();
    return snap.data();
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
}
