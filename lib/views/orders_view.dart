import 'package:flutter/material.dart';
import '../models.dart'; // Go up one level
import '../main.dart'; // Go up one level

class OrdersView extends StatelessWidget {
  final String activeTab;
  final List<Order> orders;

  const OrdersView({
    super.key,
    required this.activeTab,
    required this.orders,
  });

  @override
  Widget build(BuildContext context) {
    if (orders.isEmpty) {
      return _buildEmptyState(activeTab);
    }
    
    // We get the state here to pass the update function down
    final state = GlobalAppState.of(context);

    return Column(
      children: orders.map((order) => OrderCard(order: order, onUpdateStatus: state.updateOrderStatus)).toList(),
    );
  }
  
  Widget _buildEmptyState(String tab) {
    return Padding(
      padding: const EdgeInsets.only(top: 80.0),
      child: Center(
        child: Column(
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.check_circle_outline, size: 40, color: Colors.grey.shade300),
            ),
            const SizedBox(height: 16),
            Text(
              'No ${tab.toLowerCase()} orders',
              style: TextStyle(color: Colors.grey.shade500, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }
}

class OrderCard extends StatelessWidget {
  final Order order;
  final Function(String, OrderStatus) onUpdateStatus;

  const OrderCard({super.key, required this.order, required this.onUpdateStatus});

  @override
  Widget build(BuildContext context) {
    final theme = OrderStatusTheme.getTheme(order.status);
    final totalOrderValue = order.items.fold<double>(0.0, (sum, item) => sum + item.total);

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {}, // Detail view mock
        child: Stack(
          children: [
            Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              child: Container(
                width: 6,
                decoration: BoxDecoration(
                  color: theme.background.withOpacity(0.8),
                  borderRadius: const BorderRadius.horizontal(left: Radius.circular(16)),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0).copyWith(left: 14.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            order.customerName,
                            style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87),
                          ),
                          Text(
                            'ID: ${order.customerShopId.substring(0, 12)}...',
                            style: TextStyle(fontSize: 12, color: Colors.grey.shade400),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: theme.background,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: [
                            Icon(theme.icon, size: 14, color: theme.text),
                            const SizedBox(width: 4),
                            Text(order.status.name.toUpperCase(),
                                style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: theme.text)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade100),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ...order.items.map((item) => Padding(
                          padding: const EdgeInsets.only(bottom: 4.0),
                          child: Text('${item.quantity} x ${item.name} (\$${item.total.toStringAsFixed(2)})',
                              style: TextStyle(
                                  fontSize: 14, color: Colors.grey.shade700)),
                        )).toList(),
                        if (order.items.isNotEmpty) const Divider(height: 8, thickness: 1),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('TOTAL:', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                            Text('\$${totalOrderValue.toStringAsFixed(2)}', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: kPrimaryColor)),
                          ],
                        )
                      ]
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        OrderStatusTheme.timeAgo(order.timestamp),
                        style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic, color: Colors.grey.shade400),
                      ),
                      Row(
                        children: [
                          if (order.status == OrderStatus.pending) ...[
                            IconButton(
                              onPressed: () => onUpdateStatus(order.id, OrderStatus.rejected),
                              icon: Icon(Icons.close, color: Colors.red.shade500),
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton(
                              onPressed: () => onUpdateStatus(order.id, OrderStatus.accepted),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: kPrimaryColor,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              ),
                              child: const Text('Accept', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                            ),
                          ],
                          if (order.status == OrderStatus.accepted)
                            ElevatedButton.icon(
                              onPressed: () => onUpdateStatus(order.id, OrderStatus.shipped),
                              icon: const Icon(Icons.local_shipping_outlined, size: 18),
                              label: const Text('Mark Shipped', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue.shade600,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              ),
                            ),
                        ],
                      ),
                    ],
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}