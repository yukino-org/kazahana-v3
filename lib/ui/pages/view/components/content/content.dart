import 'package:kazahana/core/exports.dart';
import 'package:kazahana/core/player/video_player.dart';
import 'provider.dart';

List<String> entries = ['A', 'B', 'C'];

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
                            } else {
                              entries = [
                                'Episode one',
                                'Episode two',
                                'Episode three'
                              ]; //placeholder values
                            }
                          },
                        ),
                      ),
                    ),
                  ),
                  const EpisodeList()
                ],
              ),
            ),
          ),
        ),
      );
}

class EpisodeList extends StatefulWidget {
  const EpisodeList({super.key});

  @override
  _EpisodeListState createState() => _EpisodeListState();
}

class _EpisodeListState extends State<EpisodeList> {
  late String selectedEntry;

  @override
  Widget build(final BuildContext context) => ListView.builder(
        shrinkWrap: true,
        itemCount: entries.length,
        itemBuilder: (final BuildContext context, final int index) => ListTile(
          title: Text(entries[index]),
          onTap: () {
            setState(() {
              selectedEntry = entries[index];
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (final BuildContext context) => const PlayerPage(),
                ),
              );
            });
          },
        ),
      );
}
