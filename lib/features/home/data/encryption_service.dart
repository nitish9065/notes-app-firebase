import 'dart:convert';

import 'package:encrypt/encrypt.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class EncryptionService {
  final FlutterSecureStorage _storage;
  static const _encryptionKey = 'notes_encryption_key';

  EncryptionService(this._storage);

  Future<String> encrypt(String plainText) async {
    final key = await _getOrCreateKey();
    final b64key = Key.fromUtf8(
        base64Url.encode(Key.fromUtf8(key).bytes).substring(0, 32));
    // if you need to use the ttl feature, you'll need to use APIs in the algorithm itself
    final fernet = Fernet(b64key);
    final encrypter = Encrypter(fernet);
    return encrypter.encrypt(plainText).base64;
  }

  Future<String> decrypt(String encryptedText) async {
    final key = await _getOrCreateKey();
    final b64key = Key.fromUtf8(
        base64Url.encode(Key.fromUtf8(key).bytes).substring(0, 32));
    // if you need to use the ttl feature, you'll need to use APIs in the algorithm itself
    final fernet = Fernet(b64key);
    final encrypter = Encrypter(fernet);
    return encrypter.decrypt64(encryptedText);
  }

  Future<String> _getOrCreateKey() async {
    final existingKey = await _storage.read(key: _encryptionKey);
    if (existingKey != null) return existingKey;

    final newKey = Key.fromSecureRandom(32).base64;
    await _storage.write(key: _encryptionKey, value: newKey);
    return newKey;
  }
}
