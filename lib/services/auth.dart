import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_messaging/firebase_messaging.dart';

class AuthService {
  final userStream = FirebaseAuth.instance.authStateChanges();

  String get uid {
    return FirebaseAuth.instance.currentUser?.uid ?? "Not Logged In";
  }

  Future<void> anonLogin() async {
    try {
      await FirebaseAuth.instance.signInAnonymously();
      String? currentUserId = FirebaseAuth.instance.currentUser?.uid;
      if (currentUserId != null) {
        await sendFcmTokenToServer();
      }
    } on FirebaseAuthException catch (e) {
      print(e);
    }
  }

  Future<void> signOut() async {
    await FirebaseAuth.instance.signOut();
  }
}

Future<void> sendFcmTokenToServer() async {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  try {
    String? fcmToken = await _firebaseMessaging.getToken();
    String? idToken = await FirebaseAuth.instance.currentUser?.getIdToken();

    var body = {
      'fcmToken': fcmToken,
      'idToken': idToken,
    };

    final response = await http.post(
      Uri.parse(
          'https://us-central1-gentoo-update.cloudfunctions.net/updateFCMToken'),
      body: body,
    );

    if (response.statusCode == 200) {
      print('FCM token sent to server successfully!');
    } else {
      print('Failed to send FCM token to server: ${response.body}');
    }
  } catch (e) {
    print('An error occurred while sending FCM token to server: $e');
  }
}
