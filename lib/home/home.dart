import 'package:flutter/material.dart';
import 'package:gentoo_update_flutter/login/login.dart';
import 'package:gentoo_update_flutter/reports/reports.dart';
import 'package:gentoo_update_flutter/services/auth.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: AuthService().userStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Text('loading');
        } else if (snapshot.hasError) {
          return const Center(
            child: Text('error'),
          );
        } else if (snapshot.hasData) {
          return const ReportsScreen();
        } else {
          return const LoginScreen();
        }
      },
    );
  }
}
