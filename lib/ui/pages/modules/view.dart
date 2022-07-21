import '../../../core/exports.dart';
import 'provider.dart';

class ModulesPage extends StatelessWidget {
  const ModulesPage({
    final Key? key,
  }) : super(key: key);

  VoidCallback createOnPressed({
    required final ModulesPageProvider provider,
    required final TenkaMetadata metadata,
  }) =>
      () {
        if (TenkaManager.repository.isInstalled(metadata)) {
          provider.uninstall(metadata);
          return;
        }
        provider.install(metadata);
      };

  Widget buildModuleTile({
    required final BuildContext context,
    required final ModulesPageProvider provider,
    required final TenkaMetadata metadata,
  }) {
    final bool isInstalling = provider.installing.contains(metadata.id);
    final bool isUninstalling = provider.uninstalling.contains(metadata.id);
    final bool isInstalled = TenkaManager.repository.isInstalled(metadata);

    final IconData icon;
    Color? iconColor;
    if (isInstalling) {
      icon = Icons.hourglass_bottom_rounded;
    } else if (isUninstalling) {
      icon = Icons.hourglass_bottom_rounded;
    } else if (isInstalled) {
      icon = Icons.done_rounded;
      iconColor = Theme.of(context).colorScheme.primary;
    } else {
      icon = Icons.add_rounded;
      iconColor = Theme.of(context).colorScheme.primary;
    }

    final VoidCallback? onPressed = isInstalling || isUninstalling
        ? null
        : createOnPressed(provider: provider, metadata: metadata);

    return ListTile(
      contentPadding: EdgeInsets.only(left: rem(0.75), right: rem(0.25)),
      leading: SizedBox(
        height: double.infinity,
        child: SizedBox.square(
          dimension: rem(1.5),
          child: Image.network(
            TenkaManager.repository.resolver
                .resolveURL((metadata.thumbnail as TenkaCloudDS).url),
          ),
        ),
      ),
      title: RichText(
        text: TextSpan(
          children: <InlineSpan>[
            TextSpan(text: metadata.name),
            if (metadata.nsfw)
              TextSpan(
                text: '  (${Translator.t.nsfw()})',
                style: Theme.of(context)
                    .textTheme
                    .overline
                    ?.copyWith(color: ColorPalettes.red.c500),
              ),
          ],
          style: Theme.of(context).textTheme.subtitle2,
        ),
      ),
      subtitle: Text(
        <String>[
          metadata.type.titleCase,
          Translator.t.by(metadata.author),
          'v${metadata.version}',
        ].join(' / '),
      ),
      trailing: IconButton(
        icon: Icon(icon, color: iconColor),
        onPressed: onPressed,
      ),
      onTap: onPressed,
    );
  }

  @override
  Widget build(final BuildContext context) =>
      ChangeNotifierProvider<ModulesPageProvider>(
        create: (final _) => ModulesPageProvider(),
        child: Consumer<ModulesPageProvider>(
          builder: (
            final BuildContext context,
            final ModulesPageProvider provider,
            final _,
          ) =>
              Scaffold(
            appBar: AppBar(title: Text(Translator.t.extensions())),
            body: SingleChildScrollView(
              child: Column(
                children: TenkaManager.repository.store.modules.values
                    .sortedBy((final TenkaMetadata x) => x.name)
                    .map(
                      (final TenkaMetadata x) => buildModuleTile(
                        context: context,
                        provider: provider,
                        metadata: x,
                      ),
                    )
                    .toList(),
              ),
            ),
          ),
        ),
      );
}
