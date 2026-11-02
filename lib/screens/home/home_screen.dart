import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/task.dart';
import '../../providers/auth_provider.dart';
import '../../services/firestore_service.dart';
import '../../theme/app_theme.dart';
import '../../utils/formatters.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Task> _tasks = [];
  Map<String, dynamic>? _profile;
  bool _loading = true;

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
    final tasks = familyId != null
        ? await FirestoreService.getTasks(familyId)
        : <Task>[];
    if (!mounted) return;
    setState(() {
      _profile = profile;
      _tasks = tasks;
      _loading = false;
    });
  }

  Color _categoryColor(String category) {
    switch (category) {
      case 'Hogar':
        return AppTheme.catHome;
      case 'Académicas':
        return AppTheme.catAcademic;
      case 'Mamá':
        return AppTheme.catMom;
      case 'Papá':
        return AppTheme.catDad;
      case 'Juan':
        return AppTheme.catJuan;
      case 'Sofía':
        return AppTheme.catSofia;
      default:
        return AppTheme.primaryLight;
    }
  }

  @override
  Widget build(BuildContext context) {
    final name = _profile?['name']?.toString() ?? 'Familia';
    final firstName = name.trim().split(' ').first;
    final lastNames = _profile?['lastNames']?.toString() ?? '';
    final initials = AppFormats.initials(name, lastNames);

    final done = _tasks.where((t) => t.completed).length;
    final progress = _tasks.isEmpty ? 0.0 : done / _tasks.length;
    final now = DateTime.now();
    final monday = now.subtract(Duration(days: now.weekday - 1));

    return Scaffold(
      backgroundColor: AppTheme.primaryColor,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('FamilyApp', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 16),
                      Text('Hola, $firstName 👋', style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text(
                        AppFormats.longDate(now),
                        style: const TextStyle(color: Colors.white70, fontSize: 14),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      const Icon(Icons.notifications_none, color: Colors.white),
                      const SizedBox(width: 16),
                      CircleAvatar(
                        backgroundColor: Colors.white.withValues(alpha: 0.2),
                        child: Text(initials, style: const TextStyle(color: Colors.white)),
                      ),
                    ],
                  )
                ],
              ),
            ),
            const SizedBox(height: 16),

            Expanded(
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: AppTheme.backgroundColor,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(32),
                    topRight: Radius.circular(32),
                  ),
                ),
                child: _loading
                    ? const Center(child: CircularProgressIndicator())
                    : SingleChildScrollView(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Esta semana', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                  const SizedBox(height: 16),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      for (int i = 0; i < 7; i++)
                                        _buildDay(
                                          AppFormats.weekdaysShort[i],
                                          (monday.add(Duration(days: i))).day.toString(),
                                          monday.add(Duration(days: i)).day == now.day,
                                        ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 24),

                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Tareas familiares', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                  const SizedBox(height: 8),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        '$done de ${_tasks.length} completadas',
                                        style: const TextStyle(color: AppTheme.textSecondary),
                                      ),
                                      Text(
                                        '${(progress * 100).round()}%',
                                        style: const TextStyle(fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  LinearProgressIndicator(
                                    value: progress,
                                    backgroundColor: AppTheme.backgroundColor,
                                    color: AppTheme.primaryColor,
                                    minHeight: 8,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  const SizedBox(height: 16),
                                  if (_tasks.isEmpty)
                                    const Padding(
                                      padding: EdgeInsets.symmetric(vertical: 16),
                                      child: Text(
                                        'Aún no hay tareas por aquí. Crea la primera desde la pestaña Tareas.',
                                        style: TextStyle(color: AppTheme.textHint),
                                      ),
                                    )
                                  else
                                    for (final task in _tasks.take(5))
                                      _buildTaskItem(task),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDay(String label, String number, bool isSelected) {
    return Column(
      children: [
        Text(label, style: TextStyle(color: isSelected ? AppTheme.primaryColor : AppTheme.textSecondary, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isSelected ? AppTheme.primaryColor : Colors.transparent,
            shape: BoxShape.circle,
          ),
          child: Text(number, style: TextStyle(color: isSelected ? Colors.white : AppTheme.textPrimary, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
        ),
      ],
    );
  }

  Widget _buildTaskItem(Task task) {
    final color = _categoryColor(task.category);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        children: [
          Icon(task.completed ? Icons.check_circle : Icons.radio_button_unchecked, color: task.completed ? AppTheme.primaryColor : AppTheme.textHint),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              task.title,
              style: TextStyle(
                decoration: task.completed ? TextDecoration.lineThrough : null,
                color: task.completed ? AppTheme.textHint : AppTheme.textPrimary,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              task.assignee.isEmpty ? task.category : task.assignee,
              style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
