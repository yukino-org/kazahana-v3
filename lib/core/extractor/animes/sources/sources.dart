import './model.dart';
import './sbplay_org.dart' as sbplay_org;
import './streamtape_com.dart' as streamtape_com;
import '../../model.dart';

abstract class SourceRetrievers {
  static final Map<String, SourceRetriever> sources = mapName(<SourceRetriever>[
    sbplay_org.SbPlayOrg(),
    streamtape_com.StreamTapeCom(),
  ]);

  static SourceRetriever? match(final String url) {
    for (final SourceRetriever src in sources.values) {
      if (src.validate(url)) {
        return src;
      }
    }
    return null;
  }
}
