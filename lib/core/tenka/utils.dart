import 'package:tenka/tenka.dart';
import '../translator/exports.dart';

extension TenkaTypeUtils on TenkaType {
  String getTitleCase(final Translation translation) {
    switch (this) {
      case TenkaType.anime:
        return translation.anime;

      case TenkaType.manga:
        return translation.manga;
    }
  }
}
