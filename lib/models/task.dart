import 'package:cloud_firestore/cloud_firestore.dart';

class Task {
  final String id;
  final String title;
  final String description;
  final DateTime date;
  final String priority;
  final String category;
  final String assignee;
  final bool completed;

  const Task({
    required this.id,
    required this.title,
    this.description = '',
    required this.date,
    this.priority = 'Media',
    this.category = 'Hogar',
    this.assignee = '',
    this.completed = false,
  });

  factory Task.fromMap(String id, Map<String, dynamic> map) {
    final ts = map['date'];
    return Task(
      id: id,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      date: ts is Timestamp ? ts.toDate() : DateTime.now(),
      priority: map['priority'] ?? 'Media',
      category: map['category'] ?? 'Hogar',
      assignee: map['assignee'] ?? '',
      completed: map['completed'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'date': date,
      'priority': priority,
      'category': category,
      'assignee': assignee,
      'completed': completed,
    };
  }
}
