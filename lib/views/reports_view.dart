import 'package:flutter/material.dart';
import '../models.dart'; // Go up one level

class ReportsView extends StatelessWidget {
  final List<Order> orders;
  final List<InventoryItem> inventory;

  const ReportsView({super.key, required this.orders, required this.inventory});

  @override
  Widget build(BuildContext context) {
    final totalOrders = orders.length;
    final totalRevenue = (totalOrders * 50) + 1250; // Mock Calculation
    const averageDelivery = 1.5; // Mock Days
    final lowStockCount = inventory.where((i) => i.stock <= i.lowStockThreshold).length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Key Performance Indicators',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.2,
          children: [
            _StatCard(
                title: 'Total Orders (30D)',
                value: (totalOrders + 12).toString(),
                unit: 'units',
                icon: Icons.format_list_numbered,
                color: kPrimaryColor),
            _StatCard(
                title: 'Estimated Revenue',
                value: '\$${totalRevenue.toStringAsFixed(0)}',
                unit: 'USD',
                icon: Icons.attach_money,
                color: Colors.blue.shade600),
            _StatCard(
                title: 'Avg. Delivery Time',
                value: averageDelivery.toStringAsFixed(1),
                unit: 'days',
                icon: Icons.local_shipping_outlined,
                color: Colors.amber.shade700),
            _StatCard(
                title: 'Low Stock Items',
                value: lowStockCount.toString(),
                unit: 'items',
                icon: Icons.warning_amber_rounded,
                color: Colors.red.shade600),
          ],
        ),
        const SizedBox(height: 24),
        const Text('Order Trends',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        Container(
          height: 180,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [BoxShadow(color: Colors.grey.shade200, blurRadius: 4)],
          ),
          alignment: Alignment.center,
          child: Text('Chart Placeholder', style: TextStyle(color: Colors.grey.shade400, fontStyle: FontStyle.italic)),
        )
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final String unit;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.unit,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shadowColor: color.withOpacity(0.2),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border(bottom: BorderSide(color: color, width: 4)),
        ),
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(title, style: TextStyle(fontSize: 13, color: Colors.grey.shade500, fontWeight: FontWeight.w500)),
                Icon(icon, size: 20, color: color),
              ],
            ),
            RichText(
              text: TextSpan(
                text: value,
                style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: Colors.black87),
                children: [
                  TextSpan(
                    text: ' $unit',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.grey.shade400),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}