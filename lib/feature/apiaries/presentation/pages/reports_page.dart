import 'package:flutter/material.dart';

class ReportsPage extends StatelessWidget {
  final String apiaryId;
  const ReportsPage({super.key, required this.apiaryId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Informes del Apiario $apiaryId')),
      body: Center(
        child: Text('Página de Informes para Apiario ID: $apiaryId'),
      ),
    );
  }
}
