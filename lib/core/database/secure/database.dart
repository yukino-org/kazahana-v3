import 'dart:convert';
import 'package:encrypt/encrypt.dart';
import 'package:path/path.dart' as path;
import 'package:perks/perks.dart';
import '../../paths.dart';
import '../../utils/exports.dart';
import 'schema.dart';

abstract class SecureDatabase {
  static final Key key = Key.fromUtf8('ThIs_Is_HiGhLy_SeCuRe_KeY_nO_cAp');
  static final IV iv = IV.fromUtf8('ThIs_Is_HiGhLy_SeCuRe_Iv_No_CaP');
  static final Encrypter encrypter = Encrypter(AES(key, mode: AESMode.cbc));

  static final PerksFileAdapter adapter =
      PerksFileAdapter(path.join(Paths.docsDir.path, 'settings.json'));

  static late SecureSchema data;

  static Future<void> initialize() async {
    final String content = await adapter.read();
    data = content.isNotEmpty
        ? SecureSchema.fromJson(json.decode(decryptData(content)) as JsonMap)
        : SecureSchema();
  }

  static Future<void> save() async {
    await adapter.write(encryptData(json.encode(data.toJson())));
  }

  static String encryptData(final String data) =>
      encrypter.encrypt(data, iv: iv).base64;

  static String decryptData(final String data) =>
      encrypter.decrypt(Encrypted.fromBase64(data), iv: iv);
}
