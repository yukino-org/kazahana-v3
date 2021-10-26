import 'package:fuzzy/data/result.dart';
import 'package:fuzzy/fuzzy.dart';

const String fuzzyDefinitions = '''
const FuzzySearcher: type = fun(terms: str, limit: num) -> List<Map>;
external fun createFuzzy(data: List<Map>, keys: List<Map>) -> FuzzySearcher;
''';

List<Map<dynamic, dynamic>> Function(String, int) createFuzzy(
  final List<dynamic> data,
  final List<dynamic> keys,
) {
  final Fuzzy<Map<dynamic, dynamic>> client = Fuzzy<Map<dynamic, dynamic>>(
    data.cast<Map<dynamic, dynamic>>(),
    options: FuzzyOptions<Map<dynamic, dynamic>>(
      keys: keys
          .cast<Map<dynamic, dynamic>>()
          .map(
            (final Map<dynamic, dynamic> x) =>
                WeightedKey<Map<dynamic, dynamic>>(
              name: x['key'] as String,
              getter: (final Map<dynamic, dynamic> data) =>
                  data[x['key']] as String,
              weight: (x['weight'] as int?)?.toDouble() ?? 1,
            ),
          )
          .toList(),
    ),
  );

  return (final String search, final int limit) {
    final List<Result<Map<dynamic, dynamic>>> result = client.search(search);

    final List<Map<dynamic, dynamic>> results = result
        .map(
          (final Result<Map<dynamic, dynamic>> x) => <dynamic, dynamic>{
            ...x.item,
            'fuzzyScore': x.score,
          },
        )
        .toList();

    return limit >= 0 && limit <= results.length
        ? results.sublist(0, limit)
        : results;
  };
}
