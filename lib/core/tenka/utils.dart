import 'package:tenka/tenka.dart';
import '../translator/exports.dart';

extension TenkaTypeUtils on TenkaType {
  String get titleCase {
    switch (this) {
      case TenkaType.anime:
        return Translator.t.anime();

      case TenkaType.manga:
        return Translator.t.manga();
    }
  }
}
