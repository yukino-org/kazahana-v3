import 'package:kazahana/core/exports.dart';
import 'provider.dart';

class ViewPageContent extends StatelessWidget {
  const ViewPageContent(
    this.media, {
    super.key,
  });

  final AnilistMedia media;

  @override
  // TODO: do this please sempai
  Widget build(final BuildContext context) =>
      ChangeNotifierProvider<ViewPageContentProvider>(
        create: (final _) => ViewPageContentProvider(media)..initialize(),
        builder: (final BuildContext context, final _) =>
            Consumer<ViewPageContentProvider>(
          builder: (
            final BuildContext context,
            final ViewPageContentProvider provider,
            final _,
          ) =>
              SafeArea(
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  DropdownButton<TenkaMetadata>(
                    items: provider.extensions
                        .map(
                          (final TenkaMetadata x) =>
                              DropdownMenuItem<TenkaMetadata>(
                            value: x,
                            child: Text(x.name),
                          ),
                        )
                        .toList(),
                    onChanged: (final TenkaMetadata? value) {
                      if (value == null) return;
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      );
}
