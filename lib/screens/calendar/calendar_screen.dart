import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../models/event.dart';
import '../../providers/auth_provider.dart';
import '../../services/firestore_service.dart';
import '../../theme/app_theme.dart';
import '../../utils/formatters.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  List<FamilyEvent> _events = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _load();
  }

  Future<void> _load() async {
    final auth = context.read<AuthProvider>();
    final familyId = await auth.familyIdForUser();
    final events = familyId != null
        ? await FirestoreService.getEvents(familyId)
        : <FamilyEvent>[];
    if (!mounted) return;
    setState(() {
      _events = events;
      _loading = false;
    });
  }

  Future<void> _openCreate() async {
    await context.push('/create-event');
    if (mounted) _load();
  }

  Future<void> _openEdit(FamilyEvent event) async {
    await context.push('/edit-event', extra: event);
    if (mounted) _load();
  }

  List<FamilyEvent> get _dayEvents {
    final selected = _selectedDay;
    if (selected == null) return [];
    return _events.where((e) => isSameDay(e.date, selected)).toList();
  }

  List<FamilyEvent> get _upcoming {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final list = _events.where((e) => !e.date.isBefore(today)).toList()
      ..sort((a, b) => a.date.compareTo(b.date));
    return list.take(5).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryColor,
      floatingActionButton: FloatingActionButton(
        onPressed: _openCreate,
        backgroundColor: Colors.white,
        foregroundColor: AppTheme.primaryColor,
        child: const Icon(Icons.add),
      ),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              child: Row(
                children: [
                  Text('Calendario Familiar', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
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
                                children: [
                                  TableCalendar<FamilyEvent>(
                                    firstDay: DateTime.utc(2020, 10, 16),
                                    lastDay: DateTime.utc(2030, 3, 14),
                                    focusedDay: _focusedDay,
                                    eventLoader: (day) =>
                                        _events.where((e) => isSameDay(e.date, day)).toList(),
                                    selectedDayPredicate: (day) {
                                      return isSameDay(_selectedDay, day);
                                    },
                                    onDaySelected: (selectedDay, focusedDay) {
                                      setState(() {
                                        _selectedDay = selectedDay;
                                        _focusedDay = focusedDay;
                                      });
                                    },
                                    calendarFormat: CalendarFormat.month,
                                    headerStyle: const HeaderStyle(
                                      formatButtonVisible: false,
                                      titleCentered: true,
                                      titleTextStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppTheme.primaryDark),
                                      leftChevronIcon: Icon(Icons.chevron_left, color: AppTheme.primaryColor),
                                      rightChevronIcon: Icon(Icons.chevron_right, color: AppTheme.primaryColor),
                                    ),
                                    calendarStyle: CalendarStyle(
                                      selectedDecoration: const BoxDecoration(
                                        color: AppTheme.primaryColor,
                                        shape: BoxShape.circle,
                                      ),
                                      todayDecoration: BoxDecoration(
                                        color: AppTheme.primaryColor.withValues(alpha: 0.3),
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  const Text('Toca un día para ver sus eventos', style: TextStyle(color: AppTheme.textHint, fontSize: 12)),
                                ],
                              ),
                            ),
                            const SizedBox(height: 24),

                            Text(
                              _dayEvents.isNotEmpty ? 'Eventos del día' : 'Próximas actividades',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                            ),
                            const SizedBox(height: 16),

                            if (_dayEvents.isNotEmpty)
                              for (final event in _dayEvents) _buildEventItem(event)
                            else if (_upcoming.isNotEmpty)
                              for (final event in _upcoming) _buildEventItem(event)
                            else
                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: 16),
                                child: Text(
                                  'No hay eventos por aquí todavía. Toca + para crear uno.',
                                  style: TextStyle(color: AppTheme.textHint),
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

  Widget _buildEventItem(FamilyEvent event) {
    return GestureDetector(
      onTap: () => _openEdit(event),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.event, color: Colors.white, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(event.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 4),
                  Text(
                    event.location.isEmpty
                        ? AppFormats.dateTime(event.date)
                        : '${AppFormats.dateTime(event.date)} · ${event.location}',
                    style: const TextStyle(color: AppTheme.textSecondary, fontSize: 14),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppTheme.textHint),
          ],
        ),
      ),
    );
  }
}
