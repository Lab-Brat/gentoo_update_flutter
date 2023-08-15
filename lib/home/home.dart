import 'package:flutter/material.dart';
import 'package:gentoo_update_flutter/login/login.dart';
import 'package:gentoo_update_flutter/reports/reports.dart';
import 'package:gentoo_update_flutter/profile/profile.dart';
import 'package:gentoo_update_flutter/services/auth.dart';
import 'package:gentoo_update_flutter/shared/bottom_nav.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final _pages = [
    ReportsScreen(),
    ProfileScreen(),
  ];

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

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
          return Scaffold(
            body: _pages[_currentIndex],
            bottomNavigationBar: BottomNavBar(
              currentIndex: _currentIndex,
              onTabTapped: _onTabTapped,
            ),
          );
        } else {
          return const LoginScreen();
        }
      },
    );
  }
}
