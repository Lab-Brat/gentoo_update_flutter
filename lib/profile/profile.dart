import 'package:flutter/material.dart';
import 'package:gentoo_update_flutter/services/auth.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  Future<String?> getToken(String uid) async {
    DocumentSnapshot document =
        await FirebaseFirestore.instance.collection('tokens').doc(uid).get();
    return document['token_id'];
  }

  @override
  Widget build(BuildContext context) {
    final uid = AuthService.uid;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16.0),
        itemCount: 3,
        separatorBuilder: (context, index) => const Divider(),
        itemBuilder: (context, index) {
          switch (index) {
            case 0:
              return Row(
                children: [
                  Expanded(child: Text("Your UID: $uid")),
                  IconButton(
                    icon: const Icon(Icons.copy),
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: uid));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('UID copied to clipboard')),
                      );
                    },
                  ),
                ],
              );
            case 1:
              return FutureBuilder<String?>(
                future: getToken(uid),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  } else if (snapshot.hasError) {
                    return const Text("Error fetching token");
                  } else {
                    return Row(
                      children: [
                        Expanded(child: Text("Your Token: ${snapshot.data}")),
                        IconButton(
                          icon: const Icon(Icons.copy),
                          onPressed: () {
                            Clipboard.setData(
                              ClipboardData(text: snapshot.data ?? ''),
                            );
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Token copied to clipboard'),
                              ),
                            );
                          },
                        ),
                      ],
                    );
                  }
                },
              );
            case 2:
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
