import 'package:flutter/material.dart';
import '../models.dart'; // Go up one level
import '../main.dart'; // Go up one level

class InventoryView extends StatelessWidget {
  final List<InventoryItem> inventory;

  const InventoryView({super.key, required this.inventory});

  @override
  Widget build(BuildContext context) {
    // Get the state here to pass the update function down
    final state = GlobalAppState.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: kPrimaryColor.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: kPrimaryColor.withOpacity(0.2)),
          ),
          child: Row(
            children: [
              const Icon(Icons.shopping_bag_outlined, color: kPrimaryColor, size: 20),
              const SizedBox(width: 8),
              Text(
                'You have ${inventory.length} distinct products in stock.',
                style: const TextStyle(color: kPrimaryColor, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        ...inventory.map((item) => InventoryCard(item: item, onUpdateStock: state.updateStock)).toList(),
      ],
    );
  }
}

class InventoryCard extends StatelessWidget {
  final InventoryItem item;
  final Function(String, int) onUpdateStock;

  const InventoryCard({super.key, required this.item, required this.onUpdateStock});

  @override
  Widget build(BuildContext context) {
    final isLow = item.stock <= item.lowStockThreshold;
    final color = isLow ? Colors.red.shade400 : Colors.grey.shade100;

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: color),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  item.name,
                  style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.black87),
                ),
                if (isLow)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.red.shade100,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.warning_amber_rounded, size: 14, color: Colors.red.shade700),
                        const SizedBox(width: 4),
                        Text('Low Stock', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.red.shade700)),
                      ],
                    ),
                  ),
              ],
            ),
            const Divider(height: 24, thickness: 1),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                RichText(
                  text: TextSpan(
                    text: item.stock.toString(),
                    style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w900, color: kPrimaryColor),
                    children: [
                      TextSpan(
                        text: ' ${item.unit}',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.grey.shade500),
                      ),
                    ],
                  ),
                ),
                Row(
                  children: [
                    FloatingActionButton.small(
                      heroTag: 'minus-${item.id}',
                      onPressed: () => onUpdateStock(item.id, -1),
                      backgroundColor: Colors.grey.shade100,
                      foregroundColor: Colors.grey.shade600,
                      elevation: 0,
                      child: const Icon(Icons.remove, size: 20),
                    ),
                    const SizedBox(width: 8),
                    FloatingActionButton.small(
                      heroTag: 'plus-${item.id}',
                      onPressed: () => onUpdateStock(item.id, 1),
                      backgroundColor: kPrimaryColor,
                      foregroundColor: Colors.white,
                      elevation: 4,
                      child: const Icon(Icons.add, size: 20),
                    ),
                  ],
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}