import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:Softbee/feature/inventory/data/datasources/inventory_remote_datasource.dart';
import 'package:Softbee/feature/inventory/data/repositories/inventory_repository_impl.dart';
import 'package:Softbee/feature/inventory/domain/repositories/inventory_repository.dart';
import 'package:Softbee/feature/inventory/presentation/providers/inventory_controller.dart';
import 'package:Softbee/feature/inventory/presentation/providers/inventory_state.dart';
import 'package:Softbee/feature/auth/presentation/providers/auth_providers.dart'; // Import for authLocalDataSourceProvider

// Providers for the Inventory feature

final inventoryRepositoryProvider = Provider<InventoryRepository>((ref) {
  final remoteDataSource = ref.read(inventoryRemoteDataSourceProvider);
  final localDataSource = ref.read(
    authLocalDataSourceProvider,
  ); // Assuming AuthLocalDataSource is used for token
  return InventoryRepositoryImpl(
    remoteDataSource: remoteDataSource,
    localDataSource: localDataSource,
  );
});

final inventoryControllerProvider =
    StateNotifierProvider.family<InventoryController, InventoryState, String>((
      ref,
      apiaryId,
    ) {
      final repository = ref.read(inventoryRepositoryProvider);
      final controller = InventoryController(repository);
      controller.loadInventoryItems(apiaryId: apiaryId);
      return controller;
    });
