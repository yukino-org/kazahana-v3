import 'package:kazahana/core/exports.dart';
import '../../exports.dart';

class AnilistMediaSlide extends StatefulWidget {
  const AnilistMediaSlide(
    this.media, {
    super.key,
  });

  final AnilistMedia media;

  @override
  State<AnilistMediaSlide> createState() => _AnilistMediaSlideState();
}

class _AnilistMediaSlideState extends State<AnilistMediaSlide>
    with AutomaticKeepAliveClientMixin {
  @override
  Widget build(final BuildContext context) {
    super.build(context);
    return Stack(
      children: <Widget>[
        Container(color: Theme.of(context).bottomAppBarTheme.color),
        Positioned.fill(
          child: FadeInImage(
            placeholder: MemoryImage(Placeholders.transparent1x1Image),
            image: NetworkImage(
              widget.media.bannerImage ?? widget.media.coverImageExtraLarge,
            ),
            fit: BoxFit.cover,
          ),
        ),
        if (widget.media.bannerImage == null)
          ClipRRect(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
              child: const SizedBox.expand(),
            ),
          ),
        Positioned.fill(
          child: Material(
            type: MaterialType.transparency,
            child: InkWell(
              onTap: () {
                Navigator.of(context)
                    .pusher
                    .pushToViewPageFromMedia(widget.media);
              },
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: <Color>[
                      Theme.of(context)
                          .bottomAppBarTheme
                          .color!
                          .withOpacity(0.25),
                      Theme.of(context).bottomAppBarTheme.color!,
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        Align(
          alignment: Alignment.bottomLeft,
          child: IgnorePointer(
            child: Padding(
              padding: EdgeInsets.all(HorizontalBodyPadding.size(context)),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(context.r.size(0.5)),
                      child: AspectRatio(
                        aspectRatio: AnilistMediaTile.coverRatio,
                        child: FadeInImage(
                          placeholder:
                              MemoryImage(Placeholders.transparent1x1Image),
                          image:
                              NetworkImage(widget.media.coverImageExtraLarge),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: context.r.size(0.5)),
                  Wrap(
                    spacing: context.r.size(0.25),
                    runSpacing: context.r.size(0.2),
                    alignment: WrapAlignment.center,
                    children: <Widget>[
                      AnilistMediaTile.buildFormatChip(
                        context: context,
                        media: widget.media,
                      ),
                      AnilistMediaTile.buildWatchtimeChip(
                        context: context,
                        media: widget.media,
                      ),
                      if (widget.media.averageScore != null)
                        AnilistMediaTile.buildRatingChip(
                          context: context,
                          media: widget.media,
                        ),
                      if (widget.media.startDate != null ||
                          widget.media.endDate != null)
                        AnilistMediaTile.buildAirdateChip(
                          context: context,
                          media: widget.media,
                        ),
                      if (widget.media.isAdult)
                        AnilistMediaTile.buildNSFWChip(
                          context: context,
                          media: widget.media,
                        ),
                    ],
                  ),
                  SizedBox(height: context.r.size(0.25)),
                  Text(
                    widget.media.titleUserPreferred,
                    style: Theme.of(context)
                        .textTheme
                        .headlineSmall!
                        .copyWith(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: context.r.size(0.25)),
                  if (widget.media.description != null)
                    Text(
                      widget.media.description!,
                      maxLines: 5,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  bool get wantKeepAlive => true;
}
