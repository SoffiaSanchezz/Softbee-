import 'package:flutter/material.dart';

class InventoryPage extends StatelessWidget {
  final String apiaryId;
  const InventoryPage({super.key, required this.apiaryId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Inventario del Apiario $apiaryId')),
      body: Center(
        child: Text('Página de Inventario para Apiario ID: $apiaryId'),
      ),
    );
  }
}
