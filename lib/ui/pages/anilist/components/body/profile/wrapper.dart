import 'package:kazahana/core/exports.dart';
import '../../../../../exports.dart';
import '../../../provider.dart';
import 'body.dart';
import 'hero.dart';
import 'provider.dart';

class AnilistPageProfileBody extends StatefulWidget {
  const AnilistPageProfileBody({
    required this.provider,
    super.key,
  });

  final AnilistPageProvider provider;

  @override
  State<AnilistPageProfileBody> createState() => _AnilistPageProfileBodyState();
}

class _AnilistPageProfileBodyState extends State<AnilistPageProfileBody> {
  @override
  Widget build(final BuildContext context) =>
      ChangeNotifierProvider<AnilistPageProfileProvider>(
        create: (final _) =>
            AnilistPageProfileProvider(widget.provider)..initialize(),
        builder: (final BuildContext context, final _) =>
            Consumer<AnilistPageProfileProvider>(
          builder: (
            final BuildContext context,
            final AnilistPageProfileProvider provider,
            final _,
          ) =>
              NestedScrollView(
            headerSliverBuilder: (
              final BuildContext context,
              final bool innerBoxIsScrolled,
            ) =>
                <Widget>[
              AnilistPageProfileBodyHero(provider: provider),
              SliverOverlapAbsorber(
                handle:
                    NestedScrollView.sliverOverlapAbsorberHandleFor(context),
                sliver: SliverPersistentHeader(
                  pinned: true,
                  floating: true,
                  delegate: _AnilistControlsHeaderDelegate(provider),
                ),
              ),
            ],
            body: CustomScrollView(
              slivers: <Widget>[
                Builder(
                  builder: (final BuildContext context) =>
                      SliverOverlapInjector(
                    handle: NestedScrollView.sliverOverlapAbsorberHandleFor(
                      context,
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: AnilistPageProfileBodyBody(provider: provider),
                ),
              ],
            ),
          ),
        ),
      );
}

class _AnilistControlsHeaderDelegate extends SliverPersistentHeaderDelegate {
  const _AnilistControlsHeaderDelegate(this.provider);

  final AnilistPageProfileProvider provider;

  Future<void> showButtonOptionsModal<T>({
    required final BuildContext context,
    required final T value,
    required final List<T> values,
    required final Map<T, String> labels,
    required final void Function(T) onChange,
  }) async {
    await showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(context.r.size(1))),
      ),
      builder: (final BuildContext context) => Padding(
        padding: EdgeInsets.symmetric(vertical: context.r.size(0.5)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: values
              .map(
                (final T x) => RadioListTile<T>(
                  title: Text(labels[x]!),
                  value: x,
                  groupValue: value,
                  onChanged: (final T? type) {
                    if (type == null) return;
                    onChange(type);
                    Navigator.of(context).pop();
                  },
                ),
              )
              .toList(),
        ),
      ),
    );
  }

  Widget buildButton<T>({
    required final BuildContext context,
    required final T value,
    required final List<T> values,
    required final Map<T, String> labels,
    required final void Function(T) onChange,
  }) =>
      SizedBox(
        height: buttonHeight,
        child: TextButton(
          style: TextButton.styleFrom(
            backgroundColor: Theme.of(context).bottomAppBarTheme.color,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(context.r.size(0.25)),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              SizedBox(width: context.r.size(0.5)),
              Text(labels[value]!),
              const Icon(Icons.arrow_drop_down_rounded),
            ],
          ),
          onPressed: () async {
            await showButtonOptionsModal(
              context: context,
              value: value,
              values: values,
              labels: labels,
              onChange: onChange,
            );
          },
        ),
      );

  @override
  Widget build(final BuildContext context, final _, final __) => ColoredBox(
        color: Theme.of(context).scaffoldBackgroundColor,
        child: Column(
          children: <Widget>[
            SizedBox(height: verticalPaddingSize),
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: verticalPaddingSize,
              ),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: buildButton<AnilistMediaType>(
                      context: context,
                      value: provider.category.type,
                      values: AnilistMediaType.values,
                      labels: AnilistMediaType.values.asMap().map(
                            (final _, final AnilistMediaType x) =>
                                MapEntry<AnilistMediaType, String>(
                              x,
                              x.asTenkaType.getTitleCase(context.t),
                            ),
                          ),
                      onChange: (final AnilistMediaType value) {
                        provider.change(
                          provider.category.copyWith(type: value),
                        );
                      },
                    ),
                  ),
                  SizedBox(width: verticalPaddingSize),
                  Expanded(
                    child: buildButton<AnilistMediaListStatus>(
                      context: context,
                      value: provider.category.status,
                      values: AnilistMediaListStatus.values,
                      labels: AnilistMediaListStatus.values.asMap().map(
                            (final _, final AnilistMediaListStatus x) =>
                                MapEntry<AnilistMediaListStatus, String>(
                              x,
                              x.getTitleCase(context.t),
                            ),
                          ),
                      onChange: (final AnilistMediaListStatus value) {
                        provider.change(
                          provider.category.copyWith(status: value),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: verticalPaddingSize),
            const Divider(height: 1, thickness: 1),
          ],
        ),
      );

  @override
  bool shouldRebuild(final _AnilistControlsHeaderDelegate oldDelegate) => true;

  @override
  double get minExtent => fixedHeight;

  @override
  double get maxExtent => fixedHeight;

  static double get buttonHeight => RelativeSizeData.fromWindow().size(2);
  static double get verticalPaddingSize =>
      RelativeSizeData.fromWindow().size(0.3);

  static double get fixedHeight => buttonHeight + (verticalPaddingSize * 2) + 1;
}
