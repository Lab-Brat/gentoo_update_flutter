import 'package:gentoo_update_flutter/about/about.dart';
import 'package:gentoo_update_flutter/profile/profile.dart';
import 'package:gentoo_update_flutter/login/login.dart';
import 'package:gentoo_update_flutter/home/home.dart';
import 'package:gentoo_update_flutter/reports/reports.dart';

var appRoutes = {
  '/': (context) => const HomeScreen(),
  '/login': (context) => const LoginScreen(),
  '/profile': (context) => const ProfileScreen(),
  '/reports': (context) => const ReportsScreen(),
  '/about': (context) => const AboutScreen(),
};
