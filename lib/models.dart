import 'package:flutter/material.dart';

// --- Constants ---
const Color kPrimaryColor = Color(0xFF0F9873); // Professional Green
const Color kBackgroundColor = Color(0xFFF8FAFC); // Slate-50 look
const String kInternalBusinessId = 'SUP-8829-X';

// --- Enums ---
enum OrderStatus { pending, accepted, shipped, delivered }

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

  OrderItem({
    required this.itemId,
    required this.itemName,
    required this.quantity,
    required this.price,
  });
}

class Order {
  final String id;
  final String customerName;
  final DateTime date;
  OrderStatus status;
  final List<OrderItem> items;
  final double totalAmount;

  Order({
    required this.id,
    required this.customerName,
    required this.date,
    required this.status,
    required this.items,
    required this.totalAmount,
  });
}