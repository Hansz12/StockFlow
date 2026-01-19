import 'package:flutter/material.dart';
import 'models.dart';
import 'screens/role_switcher.dart';

// --- MAIN APPLICATION SETUP ---

void main() {
  runApp(const SupplierApp());
}

// Global State (Since we are using a single file for the application)
class GlobalAppState extends InheritedWidget {
  final List<Order> orders;
  final List<InventoryItem> inventory;
  final Function(Order) addOrder;
  final Function(String, OrderStatus) updateOrderStatus;
  final Function(String, int) updateStock;

  const GlobalAppState({
    super.key,
    required this.orders,
    required this.inventory,
    required this.addOrder,
    required this.updateOrderStatus,
    required this.updateStock,
    required super.child,
  });

  static GlobalAppState of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<GlobalAppState>()!;
  }

  @override
  bool updateShouldNotify(GlobalAppState oldWidget) {
    return orders != oldWidget.orders || inventory != oldWidget.inventory;
  }
}

class SupplierApp extends StatefulWidget {
  const SupplierApp({super.key});

  @override
  State<SupplierApp> createState() => _SupplierAppState();
}

class _SupplierAppState extends State<SupplierApp> {
  // Central State Management (Mock Database)
  late List<Order> _orders;
  late List<InventoryItem> _inventory;

  @override
  void initState() {
    super.initState();
    _orders = getMockOrders();
    _inventory = getMockInventory();
  }

  void _addOrder(Order newOrder) {
    setState(() {
      _orders.insert(0, newOrder);
    });
    // In a real app, this would be a Firestore addDoc call.
    // We also update stock for simplicity here, assuming the order is accepted immediately
    // In a real app, stock update happens when the order is 'Shipped'.
    for (var item in newOrder.items) {
      _updateStockByName(item.itemName, -item.quantity);
    }
  }

  void _updateOrderStatus(String id, OrderStatus newStatus) {
    setState(() {
      final index = _orders.indexWhere((order) => order.id == id);
      if (index != -1) {
        _orders[index].status = newStatus;
      }
    });
  }

  void _updateStock(String id, int change) {
    setState(() {
      final index = _inventory.indexWhere((item) => item.id == id);
      if (index != -1) {
        final currentStock = _inventory[index].stock;
        _inventory[index].stock = (currentStock + change).clamp(0, 9999);
      }
    });
  }

  // Helper to update stock based on item name (used by customer placement)
  void _updateStockByName(String name, int change) {
    setState(() {
      final index = _inventory.indexWhere((item) => item.name == name);
      if (index != -1) {
        final currentStock = _inventory[index].stock;
        _inventory[index].stock = (currentStock + change).clamp(0, 9999);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return GlobalAppState(
      orders: _orders,
      inventory: _inventory,
      addOrder: _addOrder,
      updateOrderStatus: _updateOrderStatus,
      updateStock: _updateStock,
      child: MaterialApp(
        title: 'Supplier/Customer App',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primaryColor: kPrimaryColor,
          colorScheme: ColorScheme.fromSwatch(
            primarySwatch: MaterialColor(
              kPrimaryColor.value,
              const <int, Color>{
                50: Color(0xFFE8F6F1),
                100: Color(0xFFC7EADE),
                200: Color(0xFFA0D1C7),
                300: Color(0xFF78B9AC),
                400: Color(0xFF56A196),
                500: kPrimaryColor, // Main color
                600: Color(0xFF0F9873),
                700: Color(0xFF0D8267),
                800: Color(0xFF0A6D5A),
                900: Color(0xFF064741),
              },
            ),
            backgroundColor: kBackgroundColor,
          ).copyWith(secondary: kPrimaryColor),
          scaffoldBackgroundColor: kBackgroundColor,
          fontFamily: 'Inter',
          useMaterial3: true,
        ),
        home: const RoleSwitcher(),
      ),
    );
  }
}
