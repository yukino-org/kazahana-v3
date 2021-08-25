import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/extractor/animes/model.dart' as anime_model;
import '../../plugins/helpers/ui.dart';
import '../../plugins/helpers/utils/http.dart';
import '../../plugins/translator/translator.dart';

class SelectSourceWidget extends StatefulWidget {
  const SelectSourceWidget({
    required final this.sources,
    final Key? key,
    final this.selected,
  }) : super(key: key);

  final List<anime_model.EpisodeSource> sources;
  final anime_model.EpisodeSource? selected;

  @override
  _SelectSourceWidgetState createState() => _SelectSourceWidgetState();
}

class _SelectSourceWidgetState extends State<SelectSourceWidget> {
  final FocusNode focusNode = FocusNode();

  @override
  void dispose() {
    focusNode.dispose();

    super.dispose();
  }

  @override
  Widget build(final BuildContext context) => RawKeyboardListener(
        autofocus: true,
        focusNode: focusNode,
        onKey: (final RawKeyEvent event) {
          if (event is RawKeyUpEvent &&
              event.logicalKey == LogicalKeyboardKey.escape) {
            Navigator.of(context).pop();
          }
        },
        child: Dialog(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              vertical: 16,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 22,
                  ),
                  child: Text(
                    Translator.t.selectSource(),
                    style: Theme.of(context).textTheme.headline6,
                  ),
                ),
                const SizedBox(
                  height: 6,
                ),
                ...widget.sources
                    .map(
                      (final anime_model.EpisodeSource x) => Material(
                        type: MaterialType.transparency,
                        child: RadioListTile<anime_model.EpisodeSource>(
                          title: Text(
                            '${HttpUtils.domainFromURL(x.url)} (${x.quality.code})',
                          ),
                          value: x,
                          groupValue: widget.selected,
                          activeColor: Theme.of(context).primaryColor,
                          onChanged: (final anime_model.EpisodeSource? val) {
                            Navigator.of(context).pop(val);
                          },
                        ),
                      ),
                    )
                    .toList(),
                Align(
                  alignment: Alignment.centerRight,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(4),
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: remToPx(0.6),
                          vertical: remToPx(0.3),
                        ),
                        child: Text(
                          Translator.t.close(),
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                      ),
                      onTap: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
}
