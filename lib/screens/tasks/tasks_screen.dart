import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../models/task.dart';
import '../../providers/auth_provider.dart';
import '../../services/firestore_service.dart';
import '../../theme/app_theme.dart';

class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  int _selectedTabIndex = 0;
  late Future<List<Task>> _tasksFuture;

  @override
  void initState() {
    super.initState();
    _tasksFuture = _load();
  }

  Future<List<Task>> _load() async {
    final auth = context.read<AuthProvider>();
    final familyId = await auth.familyIdForUser();
    if (familyId == null) return [];
    return FirestoreService.getTasks(familyId);
  }

  void _reload() {
    setState(() {
      _tasksFuture = _load();
    });
  }

  Future<void> _toggleTask(Task task) async {
    final auth = context.read<AuthProvider>();
    final familyId = await auth.familyIdForUser();
    if (familyId == null) return;
    await FirestoreService.updateTask(
      familyId,
      task.id,
      {'completed': !task.completed},
    );
    if (!mounted) return;
    _reload();
  }

  void _openCreate() {
    context.push('/create-task').then((_) {
      if (mounted) _reload();
    });
  }

  List<Task> _filtered(List<Task> tasks) {
    switch (_selectedTabIndex) {
      case 1:
        return tasks.where((t) => !t.completed).toList();
      case 2:
        return tasks.where((t) => t.completed).toList();
      default:
        return tasks;
    }
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

  IconData _categoryIcon(String category) {
    switch (category) {
      case 'Hogar':
        return Icons.home_outlined;
      case 'Académicas':
        return Icons.school_outlined;
      case 'Mamá':
        return Icons.face_2_outlined;
      case 'Papá':
        return Icons.face_outlined;
      case 'Juan':
        return Icons.child_care_outlined;
      case 'Sofía':
        return Icons.child_friendly_outlined;
      default:
        return Icons.task_alt;
    }
  }

  @override
  Widget build(BuildContext context) {
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
                  const Text('Tareas', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                  IconButton(
                    icon: const Icon(Icons.add, color: Colors.white),
                    onPressed: _openCreate,
                  ),
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
                child: FutureBuilder<List<Task>>(
                  future: _tasksFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    final tasks = snapshot.data ?? [];
                    final done = tasks.where((t) => t.completed).length;
                    final progress = tasks.isEmpty ? 0.0 : done / tasks.length;
                    final visible = _filtered(tasks);

                    return SingleChildScrollView(
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
                                const Text('Progreso general', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                const SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('$done de ${tasks.length} completadas', style: const TextStyle(color: AppTheme.textSecondary)),
                                    Text('${(progress * 100).round()}%', style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryColor)),
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
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),

                          Row(
                            children: [
                              Expanded(
                                child: _buildCategoryCard('Hogar', 'Tareas del hogar', _categoryColor('Hogar'), Icons.home_outlined),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: _buildCategoryCard('Académicas', 'Estudios', _categoryColor('Académicas'), Icons.school_outlined),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),

                          Row(
                            children: [
                              _buildTab(0, 'Todas'),
                              const SizedBox(width: 8),
                              _buildTab(1, 'Pendientes'),
                              const SizedBox(width: 8),
                              _buildTab(2, 'Completadas'),
                            ],
                          ),
                          const SizedBox(height: 24),

                          if (snapshot.hasError)
                            Center(
                              child: Text(
                                'Error al cargar las tareas',
                                style: TextStyle(color: Colors.red.withValues(alpha: 0.7)),
                              ),
                            )
                          else if (visible.isEmpty)
                            const Center(
                              child: Padding(
                                padding: EdgeInsets.symmetric(vertical: 32),
                                child: Text('No hay tareas por aquí', style: TextStyle(color: AppTheme.textHint)),
                              ),
                            )
                          else
                            for (final task in visible) _buildTaskItem(task),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryCard(String title, String subtitle, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color),
          ),
          const SizedBox(height: 12),
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 4),
          Text(subtitle, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildTab(int index, String text) {
    bool isSelected = _selectedTabIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedTabIndex = index;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryColor : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: isSelected ? null : Border.all(color: AppTheme.backgroundColor),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isSelected ? Colors.white : AppTheme.textSecondary,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildTaskItem(Task task) {
    final color = _categoryColor(task.category);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => _toggleTask(task),
            child: Icon(
              task.completed ? Icons.check_circle : Icons.radio_button_unchecked,
              color: task.completed ? AppTheme.primaryColor : AppTheme.textHint,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task.title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    decoration: task.completed ? TextDecoration.lineThrough : null,
                    color: task.completed ? AppTheme.textHint : AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(task.assignee.isEmpty ? task.category : task.assignee, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
                    const Text(' • ', style: TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
                    Text(task.priority, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
                    const Text(' • 📅 ', style: TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
                    Text('${task.date.day}/${task.date.month}/${task.date.year}', style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
                  ],
                )
              ],
            ),
          ),
          Icon(_categoryIcon(task.category), color: color, size: 20),
          const SizedBox(width: 8),
          const Icon(Icons.chevron_right, color: AppTheme.textHint),
        ],
      ),
    );
  }
}
