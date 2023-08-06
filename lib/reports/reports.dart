import 'package:flutter/material.dart';
import 'package:gentoo_update_flutter/shared/bottom_nav.dart';

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Reports"),
      ),
      bottomNavigationBar: const BottomNavBar(),
    );
  }
}
