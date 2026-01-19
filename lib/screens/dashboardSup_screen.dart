import 'package:flutter/material.dart';
import '../main.dart'; // Go up one level to the root directory
import '../models.dart'; // Go up one level to the root directory
import '../views/orders_view.dart'; // Go up one level, then down into the views directory
import '../views/inventory_view.dart'; // Go up one level, then down into the views directory
import '../views/reports_view.dart'; // Go up one level, then down into the views directory
import '../views/profile_view.dart'; // Go up one level, then down into the views directory

class DashboardScreen extends StatefulWidget {
  final bool isSupplier;
  final ValueChanged<bool> onToggleRole;

  const DashboardScreen({
    super.key,
    required this.isSupplier,
    required this.onToggleRole,
  });

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0; // 0: Orders, 1: Stock, 2: Reports, 3: Profile
  String _activeOrdersTab = 'pending'; // 'pending', 'accepted', 'shipped'

  // --- VIEWS ---

  List<Widget> _getViews(GlobalAppState state) {
    return [
      OrdersView(
        activeTab: _activeOrdersTab,
        orders:
            state.orders
                .where((o) => o.status.name == _activeOrdersTab)
                .toList()
              ..sort((a, b) => b.date.compareTo(a.date)),
      ),
      InventoryView(
        inventory: state.inventory..sort((a, b) => a.name.compareTo(b.name)),
      ),
      ReportsView(orders: state.orders, inventory: state.inventory),
      const ProfileView(),
    ];
  }

  // --- WIDGET BUILDER ---

  String get _currentTitle {
    switch (_selectedIndex) {
      case 0:
        return 'Orders';
      case 1:
        return 'Stock';
      case 2:
        return 'Reports';
      case 3:
        return 'Profile';
      default:
        return 'Dashboard';
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = GlobalAppState.of(context);
    final views = _getViews(state);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          _buildSliverHeader(context),
          SliverPadding(
            padding: const EdgeInsets.all(16.0),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                views[_selectedIndex],
                const SizedBox(
                  height: 80,
                ), // Added padding so FAB doesn't cover content
              ]),
            ),
          ),
        ],
      ),
      // --- SCAN BUTTON (FAB) ---
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          print("Open Scanner Mockup");
          // Later we will navigate to the camera screen here
        },
        backgroundColor: Colors.orange,
        elevation: 4,
        shape: const CircleBorder(),
        child: const Icon(Icons.qr_code_scanner, color: Colors.white, size: 28),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      // ----------------------------
      bottomNavigationBar: _buildBottomNavigationBar(context),
    );
  }

  Widget _buildSliverHeader(BuildContext context) {
    return SliverAppBar(
      automaticallyImplyLeading: false,
      pinned: true,
      expandedHeight: 110.0, // Reduced slightly for better mobile proportion
      backgroundColor: kPrimaryColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
      ),
      // --- FIXED: Switch moved to ACTIONS to prevent overflow ---
      actions: [
        Row(
          children: [
            Text(
              widget.isSupplier ? 'Supplier' : 'Customer',
              style: TextStyle(
                fontSize: 12,
                color: Colors.white.withOpacity(0.9),
                fontWeight: FontWeight.w500,
              ),
            ),
            Switch.adaptive(
              value: widget.isSupplier,
              onChanged: (value) => widget.onToggleRole(value),
              activeColor: Colors.white,
              activeTrackColor: Colors.white.withOpacity(0.3),
              inactiveThumbColor: Colors.white,
              inactiveTrackColor: Colors.white.withOpacity(0.3),
            ),
            const SizedBox(width: 8),
          ],
        ),
      ],
      // ----------------------------------------------------------
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.only(left: 16.0, bottom: 16.0),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _currentTitle,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              _selectedIndex == 0
                  ? 'Manage incoming requests'
                  : 'Your business overview',
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
      bottom: _selectedIndex == 0 ? _buildOrdersTabBar() : null,
    );
  }

  PreferredSizeWidget _buildOrdersTabBar() {
    final tabs = ['pending', 'accepted', 'shipped'];
    return PreferredSize(
      preferredSize: const Size.fromHeight(60.0),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
            border: Border.all(color: Colors.grey.shade100),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: tabs.map((tab) {
              final isSelected = _activeOrdersTab == tab;
              return Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _activeOrdersTab = tab),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeInOut,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: isSelected ? kPrimaryColor : Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      tab.toUpperCase(),
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.grey.shade600,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNavigationBar(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        selectedItemColor: kPrimaryColor,
        unselectedItemColor: Colors.grey.shade400,
        showUnselectedLabels: true,
        backgroundColor: Colors.white,
        elevation: 0,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.list_alt), label: 'Orders'),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_bag_outlined),
            label: 'Stock',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart_sharp),
            label: 'Reports',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.store), label: 'Profile'),
        ],
      ),
    );
  }
}
