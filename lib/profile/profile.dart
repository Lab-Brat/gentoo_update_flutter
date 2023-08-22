import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gentoo_update_flutter/services/auth.dart';
import 'package:gentoo_update_flutter/services/decrypt.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfileScreen extends StatelessWidget {
  ProfileScreen({Key? key}) : super(key: key);
  final AuthService authService = AuthService();
  final Decryption decrypt = Decryption();
  final AESKeyManager aesKeyManager = AESKeyManager();

  Future<String?> getToken(String uid) async {
    DocumentSnapshot document =
        await FirebaseFirestore.instance.collection('tokens').doc(uid).get();
    return document['token_id'];
  }

  Future<String> getDecryptedToken(String uid) async {
    String? encryptedTokenId = await getToken(uid);

    if (encryptedTokenId == null) {
      throw Exception("Token not found");
    }

    UserAESKey userAESKey = await AESKeyManager().fetchUserAESKey();
    return Decryption().decryptWithUserKey(
        encryptedTokenId, userAESKey.content, userAESKey.iv, userAESKey.tag);
  }

  @override
  Widget build(BuildContext context) {
    final uid = authService.uid;
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
              return Text("Your UID: $uid");
            case 1:
              return FutureBuilder<String>(
                future: getDecryptedToken(uid),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  } else if (snapshot.hasError) {
                    return Text("Error: ${snapshot.error}");
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
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurpleAccent,
                ),
                onPressed: () async {
                  await AuthService().signOut();
                  Navigator.of(context)
                      .pushNamedAndRemoveUntil('/', (route) => false);
                },
                child: const Text('Sign Out'),
              );
            default:
              return Container();
          }
        },
      ),
    );
  }
}
