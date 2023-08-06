import 'package:gentoo_update_flutter/about/about.dart';
import 'package:gentoo_update_flutter/profile/profile.dart';
import 'package:gentoo_update_flutter/login/login.dart';
import 'package:gentoo_update_flutter/home/home.dart';

var appRoutes = {
  '/': (context) => const HomeScreen(),
  '/login': (context) => const LoginScreen(),
  '/profile': (context) => const ProfileScreen(),
  '/about': (context) => const AboutScreen(),
};
