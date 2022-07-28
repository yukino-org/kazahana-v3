import 'dart:async';
import 'package:kazahana/core/exports.dart';

class SuperImposerEntry {
  const SuperImposerEntry._({
    required this.id,
    required this.builder,
  });

  factory SuperImposerEntry.create(final WidgetBuilder builder) =>
      SuperImposerEntry._(id: StringUtils.random(), builder: builder);

  final String id;
  final WidgetBuilder builder;
}

class SuperImposer extends StatefulWidget {
  const SuperImposer({
    super.key,
  });

  @override
  State<SuperImposer> createState() => _SuperImposerState();

  static final Map<String, SuperImposerEntry> entries =
      <String, SuperImposerEntry>{};

  static final StreamController<void> onChangeController =
      StreamController<void>.broadcast();

  static final Stream<void> onChange = onChangeController.stream;

  static void insert(final SuperImposerEntry entry) {
    entries[entry.id] = entry;
    onChangeController.add(null);
  }

  static void remove(final SuperImposerEntry entry) {
    entries.remove(entry.id);
    onChangeController.add(null);
  }
}

class _SuperImposerState extends State<SuperImposer> {
  StreamSubscription<void>? subscription;

  @override
  void initState() {
    super.initState();

    subscription = SuperImposer.onChange.listen((final _) {
      if (!mounted) return;
      setState(() {});
    });
  }

  @override
  void dispose() {
    subscription?.cancel();

    super.dispose();
  }

  @override
  Widget build(final BuildContext context) => Stack(
        children: SuperImposer.entries.values
            .map((final SuperImposerEntry x) => x.builder(context))
            .toList(),
      );
}
