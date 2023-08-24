import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:gentoo_update_flutter/shared/provider.dart';
import 'package:logger/logger.dart';

class AuthService {
  final userStream = FirebaseAuth.instance.authStateChanges();
  final logger = Logger();
  final ProvideUserAESKey provideUserAesKey = ProvideUserAESKey();

  String get uid {
    return FirebaseAuth.instance.currentUser?.uid ?? "Not Logged In";
  }

  Future<void> anonLogin() async {
    try {
      await FirebaseAuth.instance.signInAnonymously();
      logger.i("Successfully signed in anonymously.");

      await Future.delayed(const Duration(seconds: 1));

      String? currentUserId = FirebaseAuth.instance.currentUser?.uid;
      if (currentUserId != null) {
        logger.i("Current user ID: $currentUserId");

        await sendFcmTokenToServer();

        final keyFetcher = ProvideUserAESKey();
        String? fetchedKey = await keyFetcher.fetchAndUpdateUserKey();
        if (fetchedKey == null) {
          logger.e("Failed to fetch the user key.");
          return;
        }

        logger.i("Authentication Flow ending for $uid");
      }
    } on FirebaseAuthException catch (e) {
      logger.e("Firebase Auth Error: ${e.message}");
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
