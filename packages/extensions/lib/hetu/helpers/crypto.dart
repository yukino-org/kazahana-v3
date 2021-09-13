import 'dart:convert';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart' as crypto;

String decryptCryptoJsAES(
  final String salted,
  final String decrypter,
  final int length,
) {
  final Uint8List encrypted = base64.decode(salted);

  final Uint8List salt = encrypted.sublist(8, 16);
  final Uint8List data = Uint8List.fromList(decrypter.codeUnits + salt);
  List<int> keyIv = md5.convert(data).bytes;
  final BytesBuilder builtKeyIv = BytesBuilder()..add(keyIv);

  while (builtKeyIv.length < length) {
    keyIv = md5.convert(keyIv + data).bytes;
    builtKeyIv.add(keyIv);
  }

  final Uint8List requiredKeyIv = builtKeyIv.toBytes().sublist(0, length);
  final crypto.Encrypter algorithm = crypto.Encrypter(
    crypto.AES(
      crypto.Key.fromBase64(
        base64.encode(requiredKeyIv.sublist(0, 32)),
      ),
      mode: crypto.AESMode.cbc,
    ),
  );

  return algorithm.decrypt(
    crypto.Encrypted.fromBase64(base64.encode(encrypted.sublist(16))),
    iv: crypto.IV.fromBase64(base64.encode(requiredKeyIv.sublist(32))),
  );
}
