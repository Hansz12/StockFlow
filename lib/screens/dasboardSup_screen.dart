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

  const DashboardScreen({super.key, required this.isSupplier, required this.onToggleRole});

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
        orders: state.orders.where((o) => o.status.name == _activeOrdersTab).toList()
          ..sort((a, b) => b.timestamp.compareTo(a.timestamp)),
      ),
      InventoryView(
        inventory: state.inventory..sort((a, b) => a.name.compareTo(b.name)),
      ),
      ReportsView(
        orders: state.orders,
        inventory: state.inventory,
      ),
      const ProfileView(),
    ];
  }

  // --- WIDGET BUILDER ---

  String get _currentTitle {
    switch (_selectedIndex) {
      case 0: return 'Orders';
      case 1: return 'Stock';
      case 2: return 'Reports';
      case 3: return 'Profile';
      default: return 'Dashboard';
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
                const SizedBox(height: 20),
              ]),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNavigationBar(context),
    );
  }

  Widget _buildSliverHeader(BuildContext context) {
    return SliverAppBar(
      automaticallyImplyLeading: false,
      pinned: true,
      expandedHeight: 120.0,
      backgroundColor: kPrimaryColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
      ),
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.only(left: 16.0, bottom: 16.0),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _currentTitle,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold),
                ),
                Text(
                  _selectedIndex == 0
                      ? 'Manage incoming requests'
                      : 'Your business overview',
                  style:
                      TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 12),
                ),
              ],
            ),
            Container(
              margin: const EdgeInsets.only(right: 16),
              child: Row(
                children: [
                  Text('Supplier', style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.8))),
                  Switch.adaptive(
                    value: widget.isSupplier,
                    onChanged: (value) => widget.onToggleRole(value),
                    activeColor: Colors.white,
                    activeTrackColor: Colors.white.withOpacity(0.5),
                    inactiveThumbColor: Colors.blue.shade100,
                    inactiveTrackColor: Colors.blue.shade300,
                  ),
                  Text('Customer', style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.8))),
                ],
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
            boxBoxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
            border: Border.all(color: Colors.grey.shade100)
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
                      boxShadow: isSelected ? [
                        BoxShadow(
                          color: kPrimaryColor.withOpacity(0.4),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ] : null,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      tab.toUpperCase(),
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.grey.shade600,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
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
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        selectedItemColor: kPrimaryColor,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        backgroundColor: Colors.white,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.format_list_numbered), label: 'Orders'),
          BottomNavigationBarItem(
              icon: Icon(Icons.shopping_bag_outlined), label: 'Stock'),
          BottomNavigationBarItem(
              icon: Icon(Icons.bar_chart_sharp), label: 'Reports'),
          BottomNavigationBarItem(
              icon: Icon(Icons.person_outline), label: 'Profile'),
        ],
      ),
    );
  }
}