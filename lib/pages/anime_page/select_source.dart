import 'package:flutter/material.dart';
import '../../core/utils.dart' as utils;
import '../../core/extractor/animes/model.dart' as anime_model;
import '../../plugins/translator/translator.dart';

class SelectSourceWidget extends StatelessWidget {
  final List<anime_model.EpisodeSource> sources;
  final anime_model.EpisodeSource? selected;

  const SelectSourceWidget({
    Key? key,
    required this.sources,
    this.selected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(
        vertical: 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
          ...sources
              .map(
                (x) => Material(
                  type: MaterialType.transparency,
                  child: RadioListTile<anime_model.EpisodeSource>(
                    title: Text(
                      '${utils.Fns.domainFromURL(x.url)} (${x.quality.code})',
                    ),
                    value: x,
                    groupValue: selected,
                    activeColor: Theme.of(context).primaryColor,
                    onChanged: (val) {
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
                    horizontal: utils.remToPx(0.6),
                    vertical: utils.remToPx(0.3),
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
    );
  }
}
