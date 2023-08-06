import 'package:flutter/material.dart';
import 'package:gentoo_update_flutter/services/auth.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: Column(
        children: [
          Text("Your UID: ${AuthService.uid}"),
          ElevatedButton(
              child: const Text('Sign Out'),
              onPressed: () async {
                await AuthService().signOut();
                Navigator.of(context)
                    .pushNamedAndRemoveUntil('/', (route) => false);
              }),
        ],
      ),
    );
  }
}
