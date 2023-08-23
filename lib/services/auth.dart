import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_functions/cloud_functions.dart';

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
  final FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;
  final FirebaseFunctions functions = FirebaseFunctions.instance;

  try {
    String? fcmToken = await firebaseMessaging.getToken();
    String? idToken = await FirebaseAuth.instance.currentUser?.getIdToken(true);

    if (fcmToken == null || idToken == null) {
      throw Exception("Either FCM token or ID token is null.");
    }

    var data = {
      'fcmToken': fcmToken,
      'idToken': idToken,
    };

    final HttpsCallable callable = functions.httpsCallable('updateFCMToken');
    final HttpsCallableResult response = await callable.call(data);

    if (response.data['result'] == 'FCM token updated successfully.') {
      print('FCM token sent to server successfully!');
    } else {
      print('Failed to send FCM token to server.');
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

  UserAESKey({required this.content, required this.iv});

  factory UserAESKey.fromMap(Map<String, dynamic> data) {
    return UserAESKey(
      content: data['content'] as String,
      iv: data['iv'] as String,
    );
  }
}
