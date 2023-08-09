import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math';

class AuthService {
  final userStream = FirebaseAuth.instance.authStateChanges();
  static User? user = FirebaseAuth.instance.currentUser;
  static String uid = _getUID(user);

  Future<void> anonLogin() async {
    try {
      await FirebaseAuth.instance.signInAnonymously();

      String token = _generateToken();
      User? user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        await FirebaseFirestore.instance
            .collection('tokens')
            .doc(user.uid)
            .set({
          'token_id': token,
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

String _getUID(User? user) {
  if (user != null) {
    return user.uid;
  } else {
    String err = "TOKEN_NOT_FOUND";
    return err;
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
