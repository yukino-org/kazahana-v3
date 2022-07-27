import 'package:tenka/tenka.dart';
import '../translator/exports.dart';

extension TenkaTypeUtils on TenkaType {
  String getTitleCase(final Translations translations) {
    switch (this) {
      case TenkaType.anime:
        return translations.anime();

      case TenkaType.manga:
        return translations.manga();
    }
  }
}
