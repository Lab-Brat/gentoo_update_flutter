import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final userStream = FirebaseAuth.instance.authStateChanges();
  static User? user = FirebaseAuth.instance.currentUser;
  static String uid = _getUID(user);

  Future<void> anonLogin() async {
    try {
      await FirebaseAuth.instance.signInAnonymously();
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
