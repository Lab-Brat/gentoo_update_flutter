import 'package:gentoo_update_flutter/services/auth.dart';
import 'package:flutter/foundation.dart';

class UserKeyProvider with ChangeNotifier {
  UserAESKey? _userAESKey;

  UserAESKey? get userAESKey => _userAESKey;

  void setUserAESKey(UserAESKey key) {
    _userAESKey = key;
    notifyListeners();
  }

  void clearUserAESKey() {
    _userAESKey = null;
    notifyListeners();
  }
}
