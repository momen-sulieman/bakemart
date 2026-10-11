import 'package:encrypt/encrypt.dart' as enc;

class QrEncryptionServices {
  // Must be exactly 32 characters long for AES-256
  static final _key = enc.Key.fromUtf8('my32charactersecretkeyformart2026');
  // Must be exactly 16 characters long
  static final _iv = enc.IV.fromUtf8('bakemart88initiv');

  // 1. Encrypt plain text ID to a Base64 String
  static String encryptId(String userId) {
    final encrypter = enc.Encrypter(enc.AES(_key));
    final encrypted = encrypter.encrypt(userId, iv: _iv);
    return encrypted.base64; // Safe string representation to put in QR
  }

  // 2. Decrypt Base64 String back to raw plain text ID
  static String decryptId(String base64Ciphertext) {
    final encrypter = enc.Encrypter(enc.AES(_key));
    final decrypted = encrypter.decrypt64(base64Ciphertext, iv: _iv);
    return decrypted;
  }
}