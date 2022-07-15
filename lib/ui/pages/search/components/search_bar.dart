import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tenka/tenka.dart';
import 'package:utilx/utils.dart';
import '../../../../core/exports.dart';
import '../provider.dart';

class SearchBar extends StatefulWidget implements PreferredSizeWidget {
  const SearchBar({
    final Key? key,
  }) : super(key: key);

  @override
  _SearchBarState createState() => _SearchBarState();

  @override
  Size get preferredSize => Size.fromHeight(rem(2.5));
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
    searchTimer?.cancel();
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

  Widget buildDropDown({
    required final BuildContext context,
    required final SearchPageProvider provider,
  }) =>
      DropdownButtonHideUnderline(
        child: DropdownButton<TenkaType>(
          value: provider.type,
          items: TenkaType.values
              .map(
                (final TenkaType x) => DropdownMenuItem<TenkaType>(
                  value: x,
                  child: Text(StringUtils.capitalize(x.name)),
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
      );

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
                    buildDropDown(context: context, provider: provider),
                    VerticalDivider(
                      indent: rem(0.25),
                      endIndent: rem(0.25),
                    ),
                    SizedBox(width: rem(0.25)),
                    Icon(
                      Icons.search,
                      size: Theme.of(context).textTheme.bodyText1?.fontSize,
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
                            hintText: getTextFieldPlaceholder(provider.type),
                          ),
                          onChanged: (final String input) =>
                              onInputChange(input, provider: provider),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );

  static const int defaultInputTimeInterval = 500;
}
