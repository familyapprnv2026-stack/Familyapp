import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_theme.dart';

class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  int _selectedTabIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryColor,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Top Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Tareas', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                  IconButton(
                    icon: const Icon(Icons.add, color: Colors.white),
                    onPressed: () => context.push('/create-task'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            
            // White Content Area
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
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // General Progress
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
                            const Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('3 de 9 completadas', style: TextStyle(color: AppTheme.textSecondary)),
                                Text('33%', style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryColor)),
                              ],
                            ),
                            const SizedBox(height: 8),
                            LinearProgressIndicator(
                              value: 0.33,
                              backgroundColor: AppTheme.backgroundColor,
                              color: AppTheme.primaryColor,
                              minHeight: 8,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      
                      // Categories
                      Row(
                        children: [
                          Expanded(
                            child: _buildCategoryCard('Hogar', '2/5 hechas', 0.4, AppTheme.catHome, Icons.home_outlined),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildCategoryCard('Académicas', '1/4 hechas', 0.25, AppTheme.catAcademic, Icons.school_outlined),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Tabs
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

                      // Tasks List
                      _buildTaskItem('Comprar víveres', 'Mamá', 'Alta', '10', AppTheme.catMom, true, Icons.shopping_cart_outlined),
                      _buildTaskItem('Reparar grifo cocina', 'Papá', 'Alta', '12', AppTheme.catDad, true, Icons.build_outlined),
                      _buildTaskItem('Hacer deberes matemáticas', 'Juan', 'Media', '15', AppTheme.catJuan, true, Icons.menu_book_outlined),
                      _buildTaskItem('Pasear al perro', 'Sofía', 'Media', '22', AppTheme.catSofia, false, Icons.pets_outlined),
                      _buildTaskItem('Limpiar habitación', 'Juan', 'Baja', '25', AppTheme.catJuan, false, Icons.cleaning_services_outlined),
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

  Widget _buildCategoryCard(String title, String subtitle, double progress, Color color, IconData icon) {
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
          const SizedBox(height: 12),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: AppTheme.backgroundColor,
            color: color,
            minHeight: 6,
            borderRadius: BorderRadius.circular(3),
          ),
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

  Widget _buildTaskItem(String title, String assignee, String priority, String dateStr, Color color, bool isCompleted, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(isCompleted ? Icons.check_circle : Icons.radio_button_unchecked, color: isCompleted ? AppTheme.primaryColor : AppTheme.textHint),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title, 
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    decoration: isCompleted ? TextDecoration.lineThrough : null,
                    color: isCompleted ? AppTheme.textHint : AppTheme.textPrimary,
                  )
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(assignee, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
                    const Text(' • ', style: TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
                    Text(priority, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
                    const Text(' • 📅 ', style: TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
                    Text(dateStr, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
                  ],
                )
              ],
            ),
          ),
          Icon(icon, color: AppTheme.textHint, size: 20),
          const SizedBox(width: 8),
          const Icon(Icons.chevron_right, color: AppTheme.textHint),
        ],
      ),
    );
  }
}
