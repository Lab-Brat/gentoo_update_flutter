import 'package:flutter/material.dart';
import 'package:gentoo_update_flutter/services/auth.dart';
import 'package:gentoo_update_flutter/services/decrypt.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:gentoo_update_flutter/shared/provider.dart';

class ProfileScreen extends StatelessWidget {
  ProfileScreen({Key? key}) : super(key: key);
  final AuthService authService = AuthService();
  final Decryption decrypt = Decryption();

  Future<List<String?>> getTokenInfo(String uid) async {
    DocumentSnapshot document =
        await FirebaseFirestore.instance.collection('tokens').doc(uid).get();
    return [document['token_id'], document['token_id_iv']];
  }

  Future<String> getDecryptedToken(String uid, String decryptedAESKey) async {
    List<String?> tokenInfo = await getTokenInfo(uid);
    String? encryptedTokenId = tokenInfo[0];
    String tokenIV = tokenInfo[1] ?? "";

    if (encryptedTokenId == null) {
      throw Exception("Token not found");
    }

    return Decryption()
        .decryptWithUserKey(encryptedTokenId, decryptedAESKey, tokenIV);
  }

  @override
  Widget build(BuildContext context) {
    final uid = authService.uid;
    final userKey = Provider.of<UserKeyProvider>(context).userKey;
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
                future: getDecryptedToken(uid, userKey),
                builder:
                    (BuildContext context, AsyncSnapshot<String> snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else {
                    return Row(
                      children: <Widget>[
                        Expanded(child: Text('Your Token: ${snapshot.data}')),
                        IconButton(
                          icon: const Icon(Icons.copy, color: Colors.grey),
                          onPressed: () {
                            if (snapshot.data != null) {
                              Clipboard.setData(
                                  ClipboardData(text: snapshot.data!));
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Token copied to clipboard!'),
                                ),
                              );
                            }
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
