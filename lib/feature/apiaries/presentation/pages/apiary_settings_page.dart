import 'package:flutter/material.dart';

class ApiarySettingsPage extends StatelessWidget {
  final String apiaryId;
  const ApiarySettingsPage({super.key, required this.apiaryId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Configuración del Apiario $apiaryId')),
      body: Center(
        child: Text('Página de Configuración para Apiario ID: $apiaryId'),
      ),
    );
  }
}
