import 'package:flutter/material.dart';
import 'dashboard_screen.dart';
import 'customer_shop_screen.dart';

class RoleSwitcher extends StatefulWidget {
  const RoleSwitcher({super.key});

  @override
  State<RoleSwitcher> createState() => _RoleSwitcherState();
}

class _RoleSwitcherState extends State<RoleSwitcher> {
  bool isSupplier = true;

  void toggleRole(bool value) {
    setState(() {
      isSupplier = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Pass the toggle function down to the screens so they can switch the view
    if (isSupplier) {
      return DashboardScreen(
        isSupplier: true,
        onToggleRole: toggleRole,
      );
    } else {
      return CustomerShopScreen(
        isSupplier: false,
        onToggleRole: toggleRole,
      );
    }
  }
}