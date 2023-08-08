import 'package:flutter/material.dart';
import 'package:gentoo_update_flutter/services/auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16.0),
        itemCount: 2,
        separatorBuilder: (context, index) => Divider(),
        itemBuilder: (context, index) {
          switch (index) {
            case 0:
              return Text("Your UID: ${AuthService.uid}");
            case 1:
              return ElevatedButton(
                child: const Text('Sign Out'),
                onPressed: () async {
                  await AuthService().signOut();
                  Navigator.of(context)
                      .pushNamedAndRemoveUntil('/', (route) => false);
                },
              );
            default:
              return Container();
          }
        },
      ),
    );
  }
}
