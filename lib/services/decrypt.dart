import 'dart:typed_data';
import 'dart:convert';
import 'package:convert/convert.dart';
import 'package:pointycastle/export.dart';

class Decryption {
  final _aesGcm = GCMBlockCipher(AESEngine());

  Uint8List _hexDecode(String data) {
    return Uint8List.fromList(hex.decode(data));
  }

  String decryptWithUserKey(String encryptedDataHex, String userKeyHex,
      String userNonceHex, String userTagHex) {
    return decrypt(encryptedDataHex, userKeyHex, userNonceHex, userTagHex);
  }

  String decrypt(
      String encryptedContentHex, String keyHex, String nonceHex, String tagHex,
      [Uint8List? associatedData]) {
    print("encryptedContentHex: $encryptedContentHex");
    print("keyHex: $keyHex");
    print("nonceHex: $nonceHex");
    print("tagHex: $tagHex");

    final key = _hexDecode(keyHex);
    final nonce = _hexDecode(nonceHex);

    // Combine encrypted content and tag
    final encryptedContentWithTag = _hexDecode(encryptedContentHex + tagHex);

    _aesGcm.init(
      false,
      AEADParameters(
        KeyParameter(key),
        128,
        nonce,
        associatedData ?? Uint8List(0),
      ),
    );

    final output = _aesGcm.process(encryptedContentWithTag);

    return utf8.decode(output);
  }
}
