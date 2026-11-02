import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class LegalScreen extends StatelessWidget {
  final String title;
  final List<LegalSection> sections;
  final String lastUpdated;
  const LegalScreen({
    super.key,
    required this.title,
    required this.sections,
    required this.lastUpdated,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: ListView(
        padding: const EdgeInsets.all(24.0),
        children: [
          Text(
            'Última actualización: $lastUpdated',
            style: TextStyle(color: context.textHint, fontSize: 13),
          ),
          SizedBox(height: 16),
          for (final section in sections) ...[
            Text(
              section.title,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.primaryColor),
            ),
            SizedBox(height: 8),
            Text(
              section.content,
              style: TextStyle(fontSize: 14, height: 1.5, color: context.textSecondary),
            ),
            SizedBox(height: 24),
          ],
        ],
      ),
    );
  }
}

class LegalSection {
  final String title;
  final String content;
  const LegalSection(this.title, this.content);
}
