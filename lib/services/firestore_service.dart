import 'package:cloud_firestore/cloud_firestore.dart';
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
}
