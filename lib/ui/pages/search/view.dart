import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tenka/tenka.dart';
import 'package:utilx/utils.dart';
import '../../../core/exports.dart';
import '../../widgets/exports.dart';
import 'provider.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({
    final Key? key,
  }) : super(key: key);

  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  late final TextEditingController textEditingController;

  @override
  void initState() {
    super.initState();

    textEditingController = TextEditingController();
  }

  @override
  void dispose() {
    textEditingController.dispose();

    super.dispose();
  }

  String getTextFieldPlaceholder(final TenkaType type) {
    switch (type) {
      case TenkaType.anime:
        return Translator.t.searchAnime();

      case TenkaType.manga:
        return Translator.t.searchManga();
    }
  }

  Widget buildResultsListTile(final TenkaType type, final dynamic result) {
    final String title;
    final String thumbnail;

    switch (type) {
      case TenkaType.anime:
        final KitsuAnime anime = result as KitsuAnime;
        title = anime.canonicalTitle;
        thumbnail = anime.posterImageOriginal;
        break;

      case TenkaType.manga:
        final KitsuManga manga = result as KitsuManga;
        title = manga.canonicalTitle;
        thumbnail = manga.posterImageOriginal;
        break;
    }

    return Padding(
      padding: EdgeInsets.only(bottom: rem(1)),
      child: InkWell(
        borderRadius: BorderRadius.circular(rem(0.25)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            ClipRRect(
              borderRadius: BorderRadius.circular(rem(0.25)),
              child: AspectRatio(
                aspectRatio: 3 / 4,
                child: Image.network(thumbnail, fit: BoxFit.cover),
              ),
            ),
            SizedBox(height: rem(0.25)),
            Flexible(
              child: Text(
                title,
                style: Theme.of(context).textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
        onTap: () {},
      ),
    );
  }

  @override
  Widget build(final BuildContext context) =>
      ChangeNotifierProvider<SearchPageProvider>(
        create: (final _) => SearchPageProvider(),
        child: Consumer<SearchPageProvider>(
          builder: (final _, final SearchPageProvider provider, final __) =>
              Scaffold(
            appBar: PreferredSize(
              preferredSize: Size.fromHeight(rem(2.5)),
              child: SafeArea(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: rem(0.75),
                    vertical: rem(0.5),
                  ),
                  child: SizedBox(
                    height: rem(1.5),
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(rem(0.25)),
                        color: Theme.of(context).appBarTheme.backgroundColor,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          SizedBox(width: rem(0.5)),
                          DropdownButtonHideUnderline(
                            child: DropdownButton<TenkaType>(
                              value: provider.type,
                              items: TenkaType.values
                                  .map(
                                    (final TenkaType x) =>
                                        DropdownMenuItem<TenkaType>(
                                      value: x,
                                      child:
                                          Text(StringUtils.capitalize(x.name)),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (final TenkaType? value) {
                                if (value == null || provider.type == value) {
                                  return;
                                }

                                provider.setType(value);
                                if (textEditingController.text.isEmpty) return;

                                provider.search(textEditingController.text);
                              },
                            ),
                          ),
                          VerticalDivider(
                            indent: rem(0.25),
                            endIndent: rem(0.25),
                          ),
                          SizedBox(width: rem(0.25)),
                          Icon(
                            Icons.search,
                            size:
                                Theme.of(context).textTheme.bodyText1?.fontSize,
                            color: Theme.of(context).textTheme.caption?.color,
                          ),
                          SizedBox(width: rem(0.4)),
                          Expanded(
                            child: Padding(
                              padding: EdgeInsets.only(bottom: rem(0.2)),
                              child: TextField(
                                textAlignVertical: TextAlignVertical.center,
                                textCapitalization: TextCapitalization.words,
                                controller: textEditingController,
                                autofocus: true,
                                decoration: InputDecoration.collapsed(
                                  hintText:
                                      getTextFieldPlaceholder(provider.type),
                                ),
                                onSubmitted: (final String value) {
                                  provider.search(value);
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            body: SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: rem(0.75),
                vertical: rem(0.25),
              ),
              child: StatedBuilder(
                provider.results.state,
                waiting: (final _) => const SizedBox.shrink(),
                processing: (final _) => const CircularProgressIndicator(),
                finished: (final _) => Column(
                  children: ListUtils.chunk(
                    provider.results.value.last
                        .map(
                          (final dynamic x) => buildResultsListTile(
                            provider.results.value.middle,
                            x,
                          ),
                        )
                        .toList(),
                    2,
                  )
                      .map(
                        (final List<Widget> x) => Row(
                          children: ListUtils.insertBetween(
                            x
                                .map((final Widget x) => Expanded(child: x))
                                .toList(),
                            SizedBox(width: rem(1)),
                          ),
                        ),
                      )
                      .toList(),
                ),
                failed: (final _) => Text(provider.results.error.toString()),
              ),
            ),
          ),
        ),
      );
}
