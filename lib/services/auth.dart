import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:http/http.dart' as http;

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

class AESKeyManager {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFunctions _functions = FirebaseFunctions.instance;

  Future<UserAESKey> fetchUserAESKey() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception("User is not authenticated");
      }

      final HttpsCallable callable = _functions.httpsCallable('getUserAESKey');
      final response = await callable.call();
      final userAESKeyData = {
        'content': response.data['content'],
        'iv': response.data['iv'],
        'tag': response.data['tag']
      };

      return UserAESKey.fromMap(userAESKeyData);
    } catch (e) {
      print('Error fetching encrypted user AES key: $e');
      throw e;
    }
  }
}

class UserAESKey {
  final String content;
  final String iv;
  final String tag;

  UserAESKey({required this.content, required this.iv, required this.tag});

  factory UserAESKey.fromMap(Map<String, dynamic> data) {
    return UserAESKey(
      content: data['content'] as String,
      iv: data['iv'] as String,
      tag: data['tag'] as String,
    );
  }
}
