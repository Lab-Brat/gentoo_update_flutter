import 'dart:convert';
import 'dart:typed_data';
import 'package:pointycastle/export.dart';
import 'package:convert/convert.dart';

class Decryption {
  final PaddedBlockCipher _cipher =
      PaddedBlockCipherImpl(PKCS7Padding(), CBCBlockCipher(AESEngine()));

  Uint8List _hexDecode(String data) {
    return Uint8List.fromList(hex.decode(data));
  }

  String decryptWithUserKey(
      String encryptedContentHex, String keyHex, String ivHex) {
    final key = _hexDecode(keyHex);
    final iv = _hexDecode(ivHex);
    final encryptedContent = _hexDecode(encryptedContentHex);

    final keyParam = KeyParameter(key);
    final params =
        PaddedBlockCipherParameters(ParametersWithIV(keyParam, iv), null);

    _cipher.init(false, params);

    final decryptedBytes = _cipher.process(encryptedContent);
    return utf8.decode(decryptedBytes);
  }
}
