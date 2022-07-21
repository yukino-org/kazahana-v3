import '../../../core/exports.dart';
import '../../router/exports.dart';
import '../body_padding.dart';
import 'media_tile.dart';

class AnilistMediaSlide extends StatefulWidget {
  const AnilistMediaSlide(
    this.media, {
    final Key? key,
  }) : super(key: key);

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
        Container(color: Theme.of(context).bottomAppBarColor),
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
                      Theme.of(context).bottomAppBarColor.withOpacity(0.25),
                      Theme.of(context).bottomAppBarColor,
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
              padding: EdgeInsets.all(HorizontalBodyPadding.size),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(rem(0.5)),
                      child: FadeInImage(
                        placeholder:
                            MemoryImage(Placeholders.transparent1x1Image),
                        image: NetworkImage(widget.media.coverImageExtraLarge),
                      ),
                    ),
                  ),
                  SizedBox(height: rem(0.5)),
                  Wrap(
                    spacing: rem(0.25),
                    runSpacing: rem(0.2),
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
                  SizedBox(height: rem(0.25)),
                  Text(
                    widget.media.titleUserPreferred,
                    style: Theme.of(context)
                        .textTheme
                        .headline5!
                        .copyWith(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: rem(0.25)),
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
