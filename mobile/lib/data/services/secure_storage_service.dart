import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive/hive.dart';

class SecureStorageService {
  static const _storage = FlutterSecureStorage();
  static const _keyName = 'hive_encryption_key';

  static Future<Uint8List> getOrCreateEncryptionKey() async {
    final containsKey = await _storage.containsKey(key: _keyName);
    if (!containsKey) {
      final key = Hive.generateSecureKey();
      await _storage.write(key: _keyName, value: base64UrlEncode(key));
    }
    
    final keyString = await _storage.read(key: _keyName);
    return base64Url.decode(keyString!);
  }
}
