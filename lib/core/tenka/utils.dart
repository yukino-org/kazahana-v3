import 'package:tenka/tenka.dart';
import '../translator/exports.dart';

extension TenkaTypeUtils on TenkaType {
  String getTitleCase(final Translation translation) => switch (this) {
        TenkaType.anime => translation.anime,
        TenkaType.manga => translation.manga,
      };
}
