import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:gentoo_update_flutter/routes.dart';
import 'package:gentoo_update_flutter/theme.dart';
import 'package:provider/provider.dart';
import 'package:gentoo_update_flutter/shared/provider.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => UserKeyProvider(),
      child: const App(),
    ),
  );
}

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  final Future<FirebaseApp> _initialization = Firebase.initializeApp();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _initialization,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Text('error');
        }

        if (snapshot.connectionState == ConnectionState.done) {
          return ChangeNotifierProvider(
            create: (context) => UserKeyProvider(),
            child: MaterialApp(
              routes: appRoutes,
              theme: appTheme,
              debugShowCheckedModeBanner: false,
            ),
          );
        }

        return const Text('loading', textDirection: TextDirection.ltr);
      },
    );
  }
}
