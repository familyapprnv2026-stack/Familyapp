class AppFormats {
  static const List<String> _weekdays = [
    'lunes', 'martes', 'miércoles', 'jueves', 'viernes', 'sábado', 'domingo',
  ];
  static const List<String> _months = [
    'enero', 'febrero', 'marzo', 'abril', 'mayo', 'junio',
    'julio', 'agosto', 'septiembre', 'octubre', 'noviembre', 'diciembre',
  ];
  static const List<String> weekdaysShort = ['L', 'M', 'X', 'J', 'V', 'S', 'D'];

  static String longDate(DateTime d) {
    return '${_weekdays[d.weekday - 1]}, ${d.day} de ${_months[d.month - 1]} de ${d.year}';
  }

  static String shortDate(DateTime d) {
    return '${d.day}/${d.month}/${d.year}';
  }

  static String time(DateTime d) {
    final h = d.hour.toString().padLeft(2, '0');
    final m = d.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  static String dateTime(DateTime d) {
    return '${d.day}/${d.month}/${d.year} · ${time(d)}';
  }

  static String initials(String name, String lastNames) {
    final a = name.trim().isNotEmpty ? name.trim()[0] : '';
    final b = lastNames.trim().isNotEmpty ? lastNames.trim()[0] : '';
    return '$a$b'.toUpperCase();
  }
}
