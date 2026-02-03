import 'package:flutter/material.dart';

class MonitoringPage extends StatelessWidget {
  final String apiaryId;
  const MonitoringPage({super.key, required this.apiaryId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Monitoreo del Apiario $apiaryId')),
      body: Center(
        child: Text('Página de Monitoreo para Apiario ID: $apiaryId'),
      ),
    );
  }
}
