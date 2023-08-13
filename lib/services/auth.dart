import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math';

class AuthService {
  final userStream = FirebaseAuth.instance.authStateChanges();

  String get uid {
    return FirebaseAuth.instance.currentUser?.uid ?? "Not Logged In";
  }

  Future<void> anonLogin() async {
    try {
      await FirebaseAuth.instance.signInAnonymously();

      String token = _generateToken();
      User? user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        final currentTime = Timestamp.now();

        await FirebaseFirestore.instance
            .collection('tokens')
            .doc(user.uid)
            .set({
          'token_id': token,
          'create_date': currentTime,
          'last_used': currentTime,
          'use_times': 1,
        });
      }
    } on FirebaseAuthException catch (e) {
      print(e);
    }
  }

  Future<void> signOut() async {
    await FirebaseAuth.instance.signOut();
  }
}

String _generateToken() {
  const chars =
      'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
  Random random = Random.secure();

  return String.fromCharCodes(
    Iterable.generate(
      20,
      (_) => chars.codeUnitAt(
        random.nextInt(chars.length),
      ),
    ),
  );
}
