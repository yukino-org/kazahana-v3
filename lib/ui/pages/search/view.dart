import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/exports.dart';
import '../../widgets/exports.dart';
import 'components/exports.dart';
import 'provider.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({
    final Key? key,
  }) : super(key: key);

  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  @override
  Widget build(final BuildContext context) =>
      ChangeNotifierProvider<SearchPageProvider>(
        create: (final _) => SearchPageProvider(),
        child: Consumer<SearchPageProvider>(
          builder: (
            final BuildContext context,
            final SearchPageProvider provider,
            final _,
          ) =>
              Scaffold(
            appBar: const SearchBar(),
            body: SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: rem(0.75),
                vertical: rem(0.25),
              ),
              child: StatedBuilder(
                provider.results.state,
                waiting: (final _) => const SizedBox.shrink(),
                processing: (final _) => SizedBox(
                  height: MediaQuery.of(context).size.height / 1.5,
                  child: const Center(child: CircularProgressIndicator()),
                ),
                finished: (final _) => ResultsGrid(
                  type: provider.results.value.middle,
                  results: provider.results.value.last,
                ),
                failed: (final _) => Text(provider.results.error.toString()),
              ),
            ),
          ),
        ),
      );
}
