import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/foundation.dart';

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
      print("Cloud Function getUserAESKey called!");
      print("result: $response");
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

class UserKeyProvider extends ChangeNotifier {
  static final UserKeyProvider _instance = UserKeyProvider._internal();

  static UserKeyProvider get instance => _instance;

  factory UserKeyProvider() {
    return _instance;
  }

  UserKeyProvider._internal();
  String _userKey = 'EMPTY_KEY';

  String get userKey => _userKey;

  void updateKey(UserAESKey newKey) {
    _userKey = newKey.content;
    notifyListeners();
  }
}
