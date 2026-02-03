import 'package:flutter/material.dart';

class HistoryPage extends StatelessWidget {
  final String apiaryId;
  const HistoryPage({super.key, required this.apiaryId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Historial del Apiario $apiaryId')),
      body: Center(
        child: Text('Página de Historial para Apiario ID: $apiaryId'),
      ),
    );
  }
}
