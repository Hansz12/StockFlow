import 'package:flutter/material.dart';
import 'dart:math'; // Needed for random ID generation

// --- Constants ---
const Color kPrimaryColor = Color(0xFF0F9873); // Professional Green
const Color kBackgroundColor = Color(0xFFF8FAFC); // Slate-50 look
const String kInternalBusinessId = 'SUP-8829-X';
const String kTechnicalUserId = 'firebase_uid_12345';

// --- Enums ---
// Fixed: Added 'rejected' so the Decline button works
enum OrderStatus { pending, accepted, shipped, delivered, rejected }

// --- Data Models ---
class InventoryItem {
  final String id;
  final String name;
  final String category;
  double stock;
  final double price;
  final String unit;
  final int lowStockThreshold;

  InventoryItem({
    required this.id,
    required this.name,
    required this.category,
    required this.stock,
    required this.price,
    required this.unit,
    required this.lowStockThreshold,
  });
}

class OrderItem {
  final String itemId;
  final String itemName;
  final int quantity;
  final double price;

  // Fixed: Added this getter because orders_view.dart uses 'item.total'
  double get total => price * quantity;

  OrderItem({
    required this.itemId,
    required this.itemName,
    required this.quantity,
    required this.price,
  });

  // Compatibility constructor for the Customer Screen
  factory OrderItem.fromCart({
    required String name,
    required int quantity,
    required double pricePerUnit,
    required String unit,
  }) {
    return OrderItem(
      itemId: 'generated', // ID not critical for display
      itemName: name,
      quantity: quantity,
      price: pricePerUnit,
    );
  }
}

class Order {
  final String id;
  final String customerName;
  final DateTime date; // Using 'date' as the primary time field
  OrderStatus status;
  final List<OrderItem> items;

  // Fixed: Added customerShopId because dashboard uses it
  final String customerShopId;
  final String notes;

  // Fixed: Added a getter for 'timestamp' to match some old code references
  DateTime get timestamp => date;

  // Fixed: Added a getter for 'totalAmount'
  double get totalAmount => items.fold(0, (sum, item) => sum + item.total);

  Order({
    required this.id,
    required this.customerName,
    required this.date,
    required this.status,
    required this.items,
    this.customerShopId = 'SHOP-GUEST', // Default value to prevent crashes
    this.notes = '',
    // Optional parameter to ignore if passed by mistake
    DateTime? timestamp,
    double? totalAmount,
  });
}

// --- HELPER FUNCTIONS (These were missing!) ---

// 1. Function to generate random IDs
String generateId() {
  var r = Random();
  return String.fromCharCodes(List.generate(8, (index) => r.nextInt(33) + 89));
}

// 2. Mock Inventory Data
List<InventoryItem> getMockInventory() {
  return [
    InventoryItem(
      id: '1',
      name: 'Kopi Arabica (Premium)',
      category: 'Beverage',
      stock: 4.0, // LOW STOCK! (Threshold is 10)
      price: 45.00,
      unit: 'Kg',
      lowStockThreshold: 10,
    ),
    InventoryItem(
      id: '2',
      name: 'Full Cream Milk',
      category: 'Dairy',
      stock: 120.0,
      price: 6.50,
      unit: 'Carton',
      lowStockThreshold: 20,
    ),
    InventoryItem(
      id: '3',
      name: 'Brown Sugar',
      category: 'Pantry',
      stock: 50.0,
      price: 3.20,
      unit: 'Pack',
      lowStockThreshold: 15,
    ),
    InventoryItem(
      id: '4',
      name: 'Paper Cups (12oz)',
      category: 'Packaging',
      stock: 500.0,
      price: 0.20,
      unit: 'Pcs',
      lowStockThreshold: 100,
    ),
  ];
}

// 3. Mock Orders Data
List<Order> getMockOrders() {
  return [
    Order(
      id: 'ORD-7721',
      customerName: 'Cafe Hipsteria',
      customerShopId: 'SHOP-001',
      date: DateTime.now().subtract(const Duration(minutes: 45)),
      status: OrderStatus.pending,
      items: [
        OrderItem(
          itemId: '1',
          itemName: 'Kopi Arabica (Premium)',
          quantity: 2,
          price: 45.00,
        ),
        OrderItem(
          itemId: '4',
          itemName: 'Paper Cups (12oz)',
          quantity: 100,
          price: 0.20,
        ),
      ],
    ),
    Order(
      id: 'ORD-7720',
      customerName: 'Mamak Maju',
      customerShopId: 'SHOP-002',
      date: DateTime.now().subtract(const Duration(hours: 3)),
      status: OrderStatus.accepted,
      items: [
        OrderItem(
          itemId: '2',
          itemName: 'Full Cream Milk',
          quantity: 10,
          price: 6.50,
        ),
      ],
    ),
    Order(
      id: 'ORD-7719',
      customerName: 'Boba Queen',
      customerShopId: 'SHOP-003',
      date: DateTime.now().subtract(const Duration(days: 1)),
      status: OrderStatus.shipped,
      items: [
        OrderItem(
          itemId: '3',
          itemName: 'Brown Sugar',
          quantity: 20,
          price: 3.20,
        ),
      ],
    ),
  ];
}
