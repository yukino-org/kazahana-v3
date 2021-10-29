import '../../database.dart';
import '../../objectbox/objectbox.g.dart';

export './schema.dart';

abstract class CredentialsBox {
  static Box<CredentialsSchema> get box =>
      Box<CredentialsSchema>(DatabaseManager.store);

  static CredentialsSchema get() =>
      box.query().build().findUnique() ?? CredentialsSchema();

  static Future<void> save(final CredentialsSchema value) async {
    await box.putAsync(value);
  }
}
