import 'package:kazahana/core/exports.dart';
import 'provider.dart';

class ViewPageContent extends StatelessWidget {
  const ViewPageContent(
    this.media, {
    super.key,
  });

  final AnilistMedia media;

  @override
  // TODO: Implement a return function to call the episodes from the provider selected and then open the video player widget after an episode is selected
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
                  SizedBox(
                    width: MediaQuery.of(context).size.width,
                    height: 60,
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<TenkaMetadata>(
                          hint: const Text('Select provider:'),
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
                            if (value == null) {
                              return;
                            } else {} //display all the results here. needs to have a return function made.
                          },
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
}
