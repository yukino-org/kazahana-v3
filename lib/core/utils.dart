import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:crypto/crypto.dart' show md5;
import 'package:encrypt/encrypt.dart' as crypto;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

double remToPx(double rem) => rem * 20;

enum LoadState { waiting, resolving, resolved, failed }

abstract class ResponsiveSizes {
  static int sm = 640;
  static int md = 768;
  static int lg = 1024;
  static int xl = 1280;
}

abstract class Palette {
  static const indigo = MaterialColor(0xFF6366F1, {
    50: Color(0xFFEEF2FF),
    100: Color(0xFFE0E7FF),
    200: Color(0xFFC7D2FE),
    300: Color(0xFFA5B4FC),
    400: Color(0xFF818CF8),
    500: Color(0xFF6366F1),
    600: Color(0xFF4F46E5),
    700: Color(0xFF4338CA),
    800: Color(0xFF3730A3),
    900: Color(0xFF312E81)
  });

  static const gray = MaterialColor(0xFF6366F1, {
    50: Color(0xFFFAFAFA),
    100: Color(0xFFF4F4F5),
    200: Color(0xFFE4E4E7),
    300: Color(0xFFD4D4D8),
    400: Color(0xFFA1A1AA),
    500: Color(0xFF71717A),
    600: Color(0xFF52525B),
    700: Color(0xFF3F3F46),
    800: Color(0xFF27272A),
    900: Color(0xFF18181B)
  });

  static final lightTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: Palette.indigo[500],
    primarySwatch: Palette.indigo,
    fontFamily: 'Poppins',
    visualDensity: VisualDensity.adaptivePlatformDensity,
  );

  static final darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: Palette.indigo[500],
    primarySwatch: Palette.indigo,
    backgroundColor: Palette.gray[800],
    scaffoldBackgroundColor: Palette.gray[900],
    cardColor: Palette.gray[800],
    dialogBackgroundColor: Palette.gray[800]!,
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      foregroundColor: Colors.white,
      backgroundColor: Palette.indigo[500],
    ),
    colorScheme: ColorScheme.dark(
      primary: Palette.indigo[500]!,
      secondary: Palette.indigo[400]!,
      background: Palette.gray[900]!,
    ),
    fontFamily: 'Poppins',
    visualDensity: VisualDensity.adaptivePlatformDensity,
  );
}

abstract class Crypto {
  static String decryptCryptoJsAES(String salted, String decrypter,
      [int length = 48]) {
    final encrypted = base64.decode(salted);

    final salt = encrypted.sublist(8, 16);
    final Uint8List data = Uint8List.fromList(decrypter.codeUnits + salt);
    List<int> keyIv = md5.convert(data).bytes;
    BytesBuilder builtKeyIv = BytesBuilder()..add(keyIv);

    while (builtKeyIv.length < length) {
      keyIv = md5.convert(keyIv + data).bytes;
      builtKeyIv.add(keyIv);
    }

    final requiredKeyIv = builtKeyIv.toBytes().sublist(0, length);
    final algorithm = crypto.Encrypter(
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
}

abstract class Http {
  static const userAgent =
      'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36';
}

abstract class Fns {
  static T random<T>(List<T> list) {
    return list[Random().nextInt(list.length)];
  }

  static bool isDarkContext(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark;
}

abstract class Assets {
  static String placeholderImage(bool dark) => dark
      ? 'assets/images/dark-placeholder-image.png'
      : 'assets/images/light-placeholder-image.png';
}
