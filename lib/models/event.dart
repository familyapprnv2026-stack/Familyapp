import 'package:cloud_firestore/cloud_firestore.dart';

class FamilyEvent {
  final String id;
  final String title;
  final DateTime date;
  final String location;
  final String? createdBy;

  const FamilyEvent({
    required this.id,
    required this.title,
    required this.date,
    this.location = '',
    this.createdBy,
  });

  factory FamilyEvent.fromMap(String id, Map<String, dynamic> map) {
    final ts = map['date'];
    return FamilyEvent(
      id: id,
      title: map['title'] ?? '',
      date: ts is Timestamp ? ts.toDate() : DateTime.now(),
      location: map['location'] ?? '',
      createdBy: map['createdBy'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'date': date,
      'location': location,
      'createdBy': createdBy,
    };
  }
}
