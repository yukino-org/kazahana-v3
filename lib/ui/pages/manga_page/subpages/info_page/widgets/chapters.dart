import 'package:extensions/extensions.dart';
import 'package:flutter/material.dart';
import 'package:utilx/utilities/utils.dart';
import '../../../../../../modules/helpers/ui.dart';
import '../../../../../../modules/translator/translator.dart';
import '../../../controller.dart';

class Chapters extends StatelessWidget {
  const Chapters({
    required final this.start,
    required final this.end,
    required final this.padding,
    required final this.controller,
    final Key? key,
  }) : super(key: key);

  final int start;
  final int end;
  final EdgeInsets padding;
  final MangaPageController controller;

  Widget buildChapterTitle(
    final BuildContext context,
    final ChapterInfo chapter,
  ) {
    final List<String> first = <String>[];
    final List<String> second = <String>[];

    if (chapter.title != null) {
      if (chapter.volume != null) {
        first.add('${Translator.t.volume()} ${chapter.volume}');
      }

      first.add('${Translator.t.chapter()} ${chapter.chapter}');
      second.add(chapter.title!);
    } else {
      first.add('${Translator.t.volume()} ${chapter.volume ?? '?'}');
      second.add('${Translator.t.chapter()} ${chapter.chapter}');
    }

    return RichText(
      text: TextSpan(
        children: <InlineSpan>[
          TextSpan(
            text: first.join(' & '),
            style: TextStyle(
              color: Theme.of(context).primaryColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          const TextSpan(text: '\n'),
          TextSpan(
            text: second.join(' '),
            style: TextStyle(
              fontSize: Theme.of(context).textTheme.headline6?.fontSize,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
        style: Theme.of(context).textTheme.bodyText1,
      ),
    );
  }

  @override
  Widget build(final BuildContext context) => MediaQuery.removePadding(
        removeTop: true,
        context: context,
        child: ListView(
          padding: padding,
          children: <Widget>[
            SizedBox(height: remToPx(1)),
            Text(
              Translator.t.chapters(),
              style: TextStyle(
                fontSize: Theme.of(context).textTheme.bodyText2?.fontSize,
                color: Theme.of(context)
                    .textTheme
                    .bodyText2
                    ?.color
                    ?.withOpacity(0.7),
              ),
            ),
            ...ListUtils.chunk<Widget>(
              controller.info.value!.sortedChapters
                  .sublist(start, end)
                  .asMap()
                  .map(
                    (
                      final int k,
                      final ChapterInfo x,
                    ) =>
                        MapEntry<int, Widget>(
                      k,
                      Expanded(
                        child: Card(
                          child: InkWell(
                            borderRadius: BorderRadius.circular(4),
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: remToPx(0.4),
                                vertical: remToPx(0.2),
                              ),
                              child: buildChapterTitle(context, x),
                            ),
                            onTap: () async {
                              controller.setCurrentChapterIndex(start + k);
                              await controller.goToPage(SubPages.reader);
                            },
                          ),
                        ),
                      ),
                    ),
                  )
                  .values
                  .toList(),
              MediaQuery.of(context).size.width > ResponsiveSizes.md ? 2 : 1,
              const Expanded(child: SizedBox.shrink()),
            ).map((final List<Widget> x) => Row(children: x)).toList(),
          ],
        ),
      );
}
