import 'package:flutter/material.dart';
import 'package:gentoo_update_flutter/routes.dart';
import 'package:gentoo_update_flutter/theme.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      routes: appRoutes,
      theme: appTheme,
    );
  }
}
