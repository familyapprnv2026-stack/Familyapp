import 'package:flutter/material.dart';

class GenericInfoScreen extends StatelessWidget {
  final String title;
  const GenericInfoScreen({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Text('Contenido de $title'),
      ),
    );
  }
}
