import 'dart:async';
import 'package:kazahana/core/exports.dart';
import '../../../exports.dart';
import '../provider.dart';

class SearchBar extends StatefulWidget implements PreferredSizeWidget {
  const SearchBar({
    super.key,
  });

  @override
  State<SearchBar> createState() => _SearchBarState();

  @override
  // TODO: Do something about this
  // Size get preferredSize => Size.fromHeight(context.r.size(2.5));
  Size get preferredSize => const Size.fromHeight(50);
}

class _SearchBarState extends State<SearchBar> {
  late final TextEditingController textEditingController;
  String? lastInputText;
  int? lastInputTime;
  Timer? searchTimer;

  @override
  void initState() {
    super.initState();
    textEditingController = TextEditingController();
  }

  @override
  void dispose() {
    super.dispose();
    searchTimer?.cancel();
    textEditingController.dispose();
  }

  void onInputChange(
    final String input, {
    required final SearchPageProvider provider,
  }) {
    if (lastInputText == input) return;

    searchTimer?.cancel();
    searchTimer = Timer(
      const Duration(milliseconds: defaultInputTimeInterval),
      () => provider.search(textEditingController.text),
    );
    lastInputTime = DateTime.now().millisecondsSinceEpoch;
    lastInputText = input;
  }

  void onCloseButtonTap(final SearchPageProvider provider) {
    if (textEditingController.text.isNotEmpty) {
      textEditingController.clear();
      provider.reset();
      return;
    }

    Navigator.of(context).pop();
  }

  @override
  Widget build(final BuildContext context) => Consumer<SearchPageProvider>(
        builder: (
          final BuildContext context,
          final SearchPageProvider provider,
          final _,
        ) =>
            SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: context.r.scale(0.75),
              vertical: context.r.scale(0.5),
            ),
            child: SizedBox(
              height: context.r.scale(1.5),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(context.r.scale(0.25)),
                  // TODO
                  // color: Theme.of(context).appBarTheme.backgroundColor,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    SizedBox(width: context.r.scale(0.5)),
                    Icon(
                      Icons.search_rounded,
                      size: Theme.of(context).textTheme.bodyLarge?.fontSize,
                      color: Theme.of(context).textTheme.bodySmall?.color,
                    ),
                    SizedBox(width: context.r.scale(0.4)),
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(bottom: context.r.scale(0.2)),
                        child: TextField(
                          textAlignVertical: TextAlignVertical.center,
                          textCapitalization: TextCapitalization.words,
                          controller: textEditingController,
                          autofocus: true,
                          decoration: InputDecoration.collapsed(
                            hintText: context.t.searchAnAnimeOrManga,
                          ),
                          onChanged: (final String input) =>
                              onInputChange(input, provider: provider),
                        ),
                      ),
                    ),
                    SizedBox(width: context.r.scale(0.4)),
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(context.r.scale(1)),
                        child: Padding(
                          padding: EdgeInsets.all(context.r.scale(0.2)),
                          child: Icon(
                            Icons.close_rounded,
                            size:
                                Theme.of(context).textTheme.bodyLarge?.fontSize,
                            color: Theme.of(context).textTheme.bodySmall?.color,
                          ),
                        ),
                        onTap: () => onCloseButtonTap(provider),
                      ),
                    ),
                    SizedBox(width: context.r.scale(0.2)),
                  ],
                ),
              ),
            ),
          ),
        ),
      );

  static const int defaultInputTimeInterval = 500;
}
