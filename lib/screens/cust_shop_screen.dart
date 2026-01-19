import 'package:flutter/material.dart';
import '../main.dart'; // Go up one level
import '../models.dart'; // Go up one level

class CustomerShopScreen extends StatefulWidget {
  final bool isSupplier;
  final ValueChanged<bool> onToggleRole;
  const CustomerShopScreen({
    super.key,
    required this.isSupplier,
    required this.onToggleRole,
  });

  @override
  State<CustomerShopScreen> createState() => _CustomerShopScreenState();
}

class _CustomerShopScreenState extends State<CustomerShopScreen> {
  // Local state to track the items in the customer's cart
  final Map<String, int> _cart = {};
  String _customerName = 'Corner Market';
  String _customerNotes = '';

  void _updateCart(InventoryItem item, int quantity) {
    setState(() {
      if (quantity > 0) {
        _cart[item.id] = quantity;
      } else {
        _cart.remove(item.id);
      }
    });
  }

  void _placeOrder(GlobalAppState state) {
    if (_cart.isEmpty) {
      _showSnackbar(
        context,
        'Cart is empty. Add items before ordering.',
        isError: true,
      );
      return;
    }

    final List<OrderItem> items = [];
    double totalValue = 0;

    for (final entry in _cart.entries) {
      final itemId = entry.key;
      final quantity = entry.value;

      final inventoryItem = state.inventory.firstWhere((i) => i.id == itemId);

      // FIXED: Used .fromCart constructor to match models.dart
      items.add(
        OrderItem.fromCart(
          name: inventoryItem.name,
          quantity: quantity,
          unit: inventoryItem.unit,
          pricePerUnit: inventoryItem.price,
        ),
      );
      totalValue += (inventoryItem.price * quantity);
    }

    // Create the new Order object
    final newOrder = Order(
      id: generateId(), // Uses the new global ID generator from models.dart
      customerShopId: 'shop-9b3d1e6c', // Mock Customer ID
      customerName: _customerName,
      status: OrderStatus.pending,
      items: items,
      date: DateTime.now(), // FIXED: Changed 'timestamp' to 'date'
      notes: _customerNotes,
    );

    // Call the global function to add the order (simulating Firestore write)
    state.addOrder(newOrder);

    // Clear the cart and reset notes
    setState(() {
      _cart.clear();
      _customerNotes = '';
    });

    _showSnackbar(
      context,
      'Order placed successfully! Total: \$${totalValue.toStringAsFixed(2)}',
      isError: false,
    );
  }

  void _showSnackbar(
    BuildContext context,
    String message, {
    required bool isError,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red.shade400 : kPrimaryColor,
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = GlobalAppState.of(context);
    final cartItemCount = _cart.entries.fold<int>(
      0,
      (prev, element) => prev + element.value,
    );

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue.shade600,
        foregroundColor: Colors.white,
        title: Text(
          'Welcome, $_customerName',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: false,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Row(
              children: [
                const Text(
                  'Customer',
                  style: TextStyle(fontSize: 12, color: Colors.white70),
                ),
                Switch.adaptive(
                  value: widget.isSupplier,
                  onChanged: (value) => widget.onToggleRole(value),
                  activeColor: kPrimaryColor,
                  activeTrackColor: kPrimaryColor.withOpacity(0.5),
                  inactiveThumbColor: Colors.white,
                  inactiveTrackColor: Colors.white.withOpacity(0.5),
                ),
                const Text(
                  'Supplier',
                  style: TextStyle(fontSize: 12, color: Colors.white70),
                ),
              ],
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Tap items to add to your order. Stock is live!',
                      style: TextStyle(
                        color: Colors.blue.shade800,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Available Products',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ...state.inventory
                .map(
                  (item) => CustomerProductCard(
                    item: item,
                    currentQuantity: _cart[item.id] ?? 0,
                    onQuantityChanged: (quantity) =>
                        _updateCart(item, quantity),
                  ),
                )
                .toList(),
            const SizedBox(height: 32),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomBar(context, cartItemCount, state),
    );
  }

  Widget _buildBottomBar(
    BuildContext context,
    int cartItemCount,
    GlobalAppState state,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () => _showCartModal(context, state),
              icon: const Icon(Icons.shopping_cart_outlined),
              label: Text('Cart (${cartItemCount})'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.blue.shade600,
                side: BorderSide(color: Colors.blue.shade300),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: cartItemCount > 0 ? () => _placeOrder(state) : null,
              icon: const Icon(Icons.send),
              label: const Text('Place Order'),
              style: ElevatedButton.styleFrom(
                backgroundColor: cartItemCount > 0
                    ? kPrimaryColor
                    : Colors.grey.shade400,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showCartModal(BuildContext context, GlobalAppState state) {
    // Collect cart items with full detail
    final cartDetails = _cart.entries.map((entry) {
      final item = state.inventory.firstWhere((i) => i.id == entry.key);
      return MapEntry(item, entry.value);
    }).toList();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter modalSetState) {
            double subtotal = 0;
            for (var entry in cartDetails) {
              subtotal += entry.key.price * entry.value;
            }

            return Padding(
              padding: EdgeInsets.only(
                top: 20,
                left: 16,
                right: 16,
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Your Order Summary',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const Divider(height: 20),

                  if (cartDetails.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 40.0),
                      child: Center(child: Text('Your cart is empty.')),
                    ),

                  ...cartDetails.map((entry) {
                    final item = entry.key;
                    final quantity = entry.value;
                    return ListTile(
                      title: Text(item.name),
                      subtitle: Text(
                        '\$${item.price.toStringAsFixed(2)} / ${item.unit}',
                      ),
                      trailing: Text(
                        '${quantity} x',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    );
                  }).toList(),

                  const Divider(height: 20),

                  TextField(
                    decoration: const InputDecoration(
                      labelText: 'Order Notes (Optional)',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                      ),
                    ),
                    onChanged: (value) =>
                        modalSetState(() => _customerNotes = value),
                    controller: TextEditingController(text: _customerNotes),
                  ),
                  const SizedBox(height: 16),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Subtotal:',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '\$${subtotal.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: kPrimaryColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: cartDetails.isNotEmpty
                          ? () {
                              _placeOrder(state);
                              Navigator.pop(context);
                            }
                          : null,
                      icon: const Icon(Icons.send),
                      label: const Text('Confirm and Place Order'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kPrimaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class CustomerProductCard extends StatefulWidget {
  final InventoryItem item;
  final int currentQuantity;
  final ValueChanged<int> onQuantityChanged;

  const CustomerProductCard({
    super.key,
    required this.item,
    required this.currentQuantity,
    required this.onQuantityChanged,
  });

  @override
  State<CustomerProductCard> createState() => _CustomerProductCardState();
}

class _CustomerProductCardState extends State<CustomerProductCard> {
  late int _quantity;

  @override
  void initState() {
    super.initState();
    _quantity = widget.currentQuantity;
  }

  @override
  void didUpdateWidget(covariant CustomerProductCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentQuantity != widget.currentQuantity) {
      _quantity = widget.currentQuantity;
    }
  }

  void _increment() {
    setState(() {
      if (_quantity < widget.item.stock) {
        _quantity++;
        widget.onQuantityChanged(_quantity);
      }
    });
  }

  void _decrement() {
    setState(() {
      if (_quantity > 0) {
        _quantity--;
        widget.onQuantityChanged(_quantity);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isAvailable = widget.item.stock > 0;
    final isSelected = _quantity > 0;

    return Card(
      elevation: isSelected ? 4 : 1,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isSelected ? kPrimaryColor : Colors.grey.shade200,
          width: isSelected ? 2 : 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.item.name,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    Text(
                      '\$${widget.item.price.toStringAsFixed(2)} / ${widget.item.unit}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Stock: ${widget.item.stock}',
                      style: TextStyle(
                        fontSize: 12,
                        color: isAvailable ? kPrimaryColor : Colors.red,
                      ),
                    ),
                    if (isSelected)
                      Text(
                        'Subtotal: \$${(widget.item.price * _quantity).toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                  ],
                ),
              ],
            ),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  isSelected ? 'In Cart: $_quantity' : 'Select Quantity',
                  style: TextStyle(
                    fontSize: 16,
                    color: isSelected ? kPrimaryColor : Colors.grey.shade500,
                  ),
                ),
                Row(
                  children: [
                    FloatingActionButton.small(
                      heroTag: 'cust-minus-${widget.item.id}',
                      onPressed: _decrement,
                      backgroundColor: Colors.grey.shade100,
                      foregroundColor: Colors.grey.shade600,
                      elevation: 0,
                      child: const Icon(Icons.remove, size: 20),
                    ),
                    SizedBox(
                      width: 40,
                      child: Text(
                        '$_quantity',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    FloatingActionButton.small(
                      heroTag: 'cust-plus-${widget.item.id}',
                      onPressed: isAvailable && _quantity < widget.item.stock
                          ? _increment
                          : null,
                      backgroundColor: isAvailable
                          ? kPrimaryColor
                          : Colors.grey.shade300,
                      foregroundColor: Colors.white,
                      elevation: isAvailable ? 4 : 0,
                      child: const Icon(Icons.add, size: 20),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
