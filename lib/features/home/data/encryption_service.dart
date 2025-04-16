import 'dart:convert';

import 'package:encrypt/encrypt.dart';

class EncryptionService {
  EncryptionService();

  Future<String> encrypt(String plainText, String key) async {
    final b64key = Key.fromUtf8(
        base64Url.encode(Key.fromUtf8(key).bytes).substring(0, 32));
    final fernet = Fernet(b64key);
    final encrypter = Encrypter(fernet);
    return encrypter.encrypt(plainText).base64;
  }

  Future<String> decrypt(String encryptedText, String key) async {
    final b64key = Key.fromUtf8(
        base64Url.encode(Key.fromUtf8(key).bytes).substring(0, 32));
    final fernet = Fernet(b64key);
    final encrypter = Encrypter(fernet);
    return encrypter.decrypt64(encryptedText);
  }
}
