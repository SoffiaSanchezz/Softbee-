import 'package:equatable/equatable.dart';
import 'package:Softbee/feature/inventory/data/models/inventory_item.dart';

class InventoryState extends Equatable {
  final List<InventoryItem> inventoryItems;
  final Map<String, dynamic> inventorySummary;
  final List<InventoryItem> lowStockItems;
  final bool isLoading;
  final String? errorMessage;
  final bool isEditing;
  final InventoryItem? editingItem;

  const InventoryState({
    this.inventoryItems = const [],
    this.inventorySummary = const {},
    this.lowStockItems = const [],
    this.isLoading = true, // Default to true when first loading
    this.errorMessage,
    this.isEditing = false,
    this.editingItem,
  });

  InventoryState copyWith({
    List<InventoryItem>? inventoryItems,
    Map<String, dynamic>? inventorySummary,
    List<InventoryItem>? lowStockItems,
    bool? isLoading,
    String? errorMessage,
    bool? isEditing,
    InventoryItem? editingItem,
  }) {
    return InventoryState(
      inventoryItems: inventoryItems ?? this.inventoryItems,
      inventorySummary: inventorySummary ?? this.inventorySummary,
      lowStockItems: lowStockItems ?? this.lowStockItems,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage, // Nullable, so pass directly
      isEditing: isEditing ?? this.isEditing,
      editingItem: editingItem, // Nullable, so pass directly
    );
  }

  @override
  List<Object?> get props => [
    inventoryItems,
    inventorySummary,
    lowStockItems,
    isLoading,
    errorMessage,
    isEditing,
    editingItem,
  ];
}
