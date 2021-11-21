import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:utilx/utilities/utils.dart';
import '../../../../../../modules/helpers/ui.dart';
import '../../../../../../modules/trackers/myanimelist/myanimelist.dart';
import '../../../../../../modules/translator/translator.dart';
import '../../../../../components/material_tiles/dialog.dart';
import '../../../../../components/material_tiles/radio.dart';
import '../../../../../components/trackers/detailed_item.dart';

class EditModal extends StatefulWidget {
  const EditModal({
    required final this.media,
    required final this.callback,
    final Key? key,
  }) : super(key: key);

  final MyAnimeListMangaList media;
  final OnEditCallback callback;

  @override
  _EditModalState createState() => _EditModalState();
}

class _EditModalState extends State<EditModal> {
  late MyAnimeListMangaListStatus status =
      widget.media.status?.status ?? MyAnimeListMangaListStatus.planToRead;
  late int progress = widget.media.status?.read ?? 0;
  late int? progressVolumes = widget.media.status?.readVolumes;
  late int? score = widget.media.status?.score;
  late bool repeating = widget.media.status?.rereading ?? false;

  late TextEditingController progressController = TextEditingController(
    text: progress.toString(),
  );
  late TextEditingController progressVolumesController = TextEditingController(
    text: progressVolumes.toString(),
  );
  late TextEditingController scoreController = TextEditingController(
    text: score?.toString() ?? '',
  );
  late String previousScoreControllerText = scoreController.text;

  Future<void> updateMedia() async {
    await widget.media.update(
      status: status,
      score: score,
      read: progress,
      readVolumes: progressVolumes,
    );
    widget.callback(widget.media.toDetailedInfo());
  }

  @override
  Widget build(final BuildContext context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
        ),
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            vertical: remToPx(0.8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: remToPx(1.1),
                ),
                child: Text(
                  '${Translator.t.editing()} ${Translator.t.myAnimeList()}',
                  style: Theme.of(context).textTheme.headline6,
                ),
              ),
              SizedBox(
                height: remToPx(0.3),
              ),
              RadioMaterialTile<MyAnimeListMangaListStatus>(
                title: Text(Translator.t.status()),
                icon: const Icon(Icons.play_arrow),
                value: status,
                labels: MyAnimeListMangaListStatus.values.asMap().map(
                      (final int k, final MyAnimeListMangaListStatus status) =>
                          MapEntry<MyAnimeListMangaListStatus, String>(
                        status,
                        StringUtils.capitalize(status.pretty),
                      ),
                    ),
                onChanged: (final MyAnimeListMangaListStatus _status) {
                  setState(() {
                    status = _status;
                  });
                },
              ),
              SizedBox(
                height: remToPx(0.3),
              ),
              MaterialDialogTile(
                title: Text(Translator.t.chaptersRead()),
                icon: const Icon(Icons.sync_alt),
                subtitle: Text(
                  '$progress / ${widget.media.details?.totalChapters ?? '?'}',
                ),
                dialogBuilder: (
                  final BuildContext context,
                  final StateSetter setState,
                ) =>
                    widget.media.details?.totalChapters != null
                        ? Wrap(
                            children: <Widget>[
                              SliderTheme(
                                data: SliderThemeData(
                                  thumbShape: RoundSliderThumbShape(
                                    enabledThumbRadius: remToPx(0.4),
                                  ),
                                  showValueIndicator: ShowValueIndicator.always,
                                ),
                                child: Slider(
                                  label: progress.toString(),
                                  value: progress.toDouble(),
                                  max: widget.media.details!.totalChapters!
                                      .toDouble(),
                                  onChanged: (final double value) {
                                    setState(() {
                                      progress = value.toInt();
                                    });
                                  },
                                  onChangeEnd: (final double value) async {
                                    setState(() {
                                      progress = value.toInt();
                                    });

                                    if (mounted) {
                                      this.setState(() {});
                                    }
                                  },
                                ),
                              ),
                            ],
                          )
                        : Padding(
                            padding: EdgeInsets.only(
                              left: remToPx(1.1),
                              right: remToPx(1.1),
                              bottom: remToPx(0.8),
                            ),
                            child: TextField(
                              decoration: InputDecoration(
                                labelText: Translator.t.noOfEpisodes(),
                              ),
                              controller: progressController,
                              keyboardType: TextInputType.number,
                              inputFormatters: <TextInputFormatter>[
                                FilteringTextInputFormatter.digitsOnly,
                              ],
                              onChanged: (final String value) {
                                if (mounted && value.isNotEmpty) {
                                  this.setState(() {
                                    progress = int.parse(value);
                                  });
                                }
                              },
                            ),
                          ),
              ),
              SizedBox(
                height: remToPx(0.3),
              ),
              MaterialDialogTile(
                title: Text(Translator.t.volumesCompleted()),
                icon: const Icon(Icons.sync_alt),
                subtitle: Text(
                  '$progressVolumes / ${widget.media.details?.totalVolumes ?? '?'}',
                ),
                dialogBuilder: (
                  final BuildContext context,
                  final StateSetter setState,
                ) =>
                    widget.media.details?.totalVolumes != null
                        ? Wrap(
                            children: <Widget>[
                              SliderTheme(
                                data: SliderThemeData(
                                  thumbShape: RoundSliderThumbShape(
                                    enabledThumbRadius: remToPx(0.4),
                                  ),
                                  showValueIndicator: ShowValueIndicator.always,
                                ),
                                child: Slider(
                                  label: progressVolumes.toString(),
                                  value: progressVolumes?.toDouble() ?? 0,
                                  max: widget.media.details!.totalVolumes!
                                      .toDouble(),
                                  onChanged: (final double value) {
                                    setState(() {
                                      progressVolumes = value.toInt();
                                    });
                                  },
                                  onChangeEnd: (final double value) async {
                                    setState(() {
                                      progressVolumes = value.toInt();
                                    });

                                    if (mounted) {
                                      this.setState(() {});
                                    }
                                  },
                                ),
                              ),
                            ],
                          )
                        : Padding(
                            padding: EdgeInsets.only(
                              left: remToPx(1.1),
                              right: remToPx(1.1),
                              bottom: remToPx(0.8),
                            ),
                            child: TextField(
                              decoration: InputDecoration(
                                labelText: Translator.t.noOfEpisodes(),
                              ),
                              controller: progressVolumesController,
                              keyboardType: TextInputType.number,
                              inputFormatters: <TextInputFormatter>[
                                FilteringTextInputFormatter.digitsOnly,
                              ],
                              onChanged: (final String value) {
                                if (mounted && value.isNotEmpty) {
                                  this.setState(() {
                                    progressVolumes = int.parse(value);
                                  });
                                }
                              },
                            ),
                          ),
              ),
              SizedBox(
                height: remToPx(0.3),
              ),
              MaterialDialogTile(
                title: Text(Translator.t.score()),
                icon: const Icon(Icons.sync_alt),
                subtitle: Text(score?.toString() ?? ''),
                dialogBuilder: (
                  final BuildContext context,
                  final StateSetter setState,
                ) =>
                    Padding(
                  padding: EdgeInsets.only(
                    left: remToPx(1.1),
                    right: remToPx(1.1),
                    bottom: remToPx(0.8),
                  ),
                  child: TextField(
                    decoration: const InputDecoration(
                      labelText: '0 - 100',
                    ),
                    controller: scoreController,
                    keyboardType: TextInputType.number,
                    inputFormatters: <TextInputFormatter>[
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                    onChanged: (final String value) {
                      final int? parsed = int.tryParse(value);
                      if (value.isNotEmpty &&
                          parsed != null &&
                          (parsed < 0 || parsed > 100)) {
                        scoreController.value = TextEditingValue(
                          text: previousScoreControllerText,
                          selection: TextSelection.collapsed(
                            offset: previousScoreControllerText.length,
                          ),
                        );
                      } else {
                        previousScoreControllerText = value;

                        if (mounted) {
                          this.setState(() {
                            score = int.parse(value);
                          });
                        }
                      }
                    },
                  ),
                ),
              ),
              SizedBox(
                height: remToPx(0.3),
              ),
              Padding(
                padding: const EdgeInsets.all(8),
                child: Row(
                  children: <Widget>[
                    SizedBox(
                      width: remToPx(2.1),
                      child: Icon(
                        Icons.repeat,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                    SizedBox(width: remToPx(0.8)),
                    Text(
                      Translator.t.repeat(),
                      style: TextStyle(
                        fontSize:
                            Theme.of(context).textTheme.subtitle1?.fontSize,
                      ),
                    ),
                    const Expanded(
                      child: SizedBox.shrink(),
                    ),
                    IconButton(
                      splashRadius: remToPx(1),
                      onPressed: () {
                        setState(() {
                          repeating = !repeating;
                        });
                      },
                      icon: Icon(
                        repeating
                            ? Icons.check_box
                            : Icons.check_box_outline_blank_outlined,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                    SizedBox(width: remToPx(0.8)),
                  ],
                ),
              ),
              SizedBox(
                height: remToPx(0.3),
              ),
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: remToPx(1.1),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    InkWell(
                      borderRadius: BorderRadius.circular(4),
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: remToPx(0.6),
                          vertical: remToPx(0.3),
                        ),
                        child: Text(
                          Translator.t.save(),
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                      ),
                      onTap: () async {
                        await updateMedia();

                        if (mounted) {
                          Navigator.of(context).pop();
                        }
                      },
                    ),
                    SizedBox(
                      width: remToPx(0.7),
                    ),
                    InkWell(
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
                  ],
                ),
              ),
            ],
          ),
        ),
      );
}
